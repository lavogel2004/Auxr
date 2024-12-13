import Firebase
import FirebaseStorage
import FirebaseAuth
import CodableFirebase

class AccountManager {
  static let current_user_id = Auth.auth().currentUser?.uid
  static let accounts_ref = Database.database().reference().child("accounts")
  static let images_ref = Storage.storage().reference().child("images")
  static var observing = false // Only allows 1 account observer
  static var image_cache: [String: UIImage] = [:]
  
  static func storeProfilePicture(account: AuxrAccount, image: UIImage){
    image_cache.removeValue(forKey: "\(account.ID)/profile.jpg")
    let profile_ref = self.images_ref.child("\(account.ID)/profile.jpg")
    if let imageData = image.jpegData(compressionQuality: 0.8){
      profile_ref.putData(imageData, metadata: nil){ (metadata, error) in
        if let error = error {
          print("Error uploading image: \(error)")
          return
        }
        image_cache.removeValue(forKey: "\(account.ID)/profile.jpg")
      }
    }
  }
  
  static func deleteProfilePicture(account_id: String) async throws {
    let profile_ref = self.images_ref.child("\(account_id)/profile.jpg")
    image_cache.removeValue(forKey: "\(account_id)/profile.jpg")
    try await profile_ref.delete()
  }
  
  static func getProfilePicture(account_id: String) async throws -> UIImage? {
    return try await withCheckedThrowingContinuation { continuation in
      if let value = image_cache["\(account_id)/profile.jpg"]{
        return continuation.resume(returning: value)
      }
      let profile_ref = images_ref.child("\(account_id)/profile.jpg")
      profile_ref.getData(maxSize: 10 * 1024 * 1024){ (data, error) in
        if let error = error {
          if let errorCode = StorageErrorCode(rawValue: error._code){
            if errorCode == .objectNotFound {
              print("Profile picture not found for \(account_id)")
            }
            else{
              print("Error downloading image: \(error)")
            }
          }
        }
        if let imageData = data{
          if let image = UIImage(data: imageData){
            image_cache["\(account_id)/profile.jpg"] = image
            return continuation.resume(returning: image)
          }
          else{
            print("Error converting to UIImage")
          }
        }
        else{
          print("Data not Valid")
        }
        if let _ = UIImage(systemName: "person.fill"){
          return continuation.resume(returning: nil)
        }
      }
    }
  }
  
  static func isLoggedIn() -> Bool { return Auth.auth().currentUser != nil }
  
  static func login(user: User) async throws -> Bool {
    return try await withCheckedThrowingContinuation { continuation in
      if isLoggedIn(){
        Task{
          if let currUser = Auth.auth().currentUser {
            do
{
              let account = try await AccountManager.getAccount(account_id: currUser.uid)
              await MainActor.run {
                user.SetAccount(Account: account)
                self.observeAccount(account: account)
                continuation.resume(returning: true)
              }
            }
            catch
            {
              // Account which was previously logged in no longer exists
              continuation.resume(returning: false)
            }
          }
        }
      }
      else{
        continuation.resume(returning: false)
      }
    }
  }
  
  static func login(username: String, password: String, user: User) async throws -> Void {
    return try await withCheckedThrowingContinuation { continuation in
      Auth.auth().signIn(withEmail: username + "@auxr.app", password: password){ authResult, error in
        if let error_unwrapped = error {
          return continuation.resume(throwing: error_unwrapped)
        }
        if let res = authResult {
          Task{
            do
            {
              let account = try await self.getAccount(account_id: res.user.uid)
              await user.SetAccount(Account: account)
              self.observeAccount(account: account)
              continuation.resume()
            }
            catch
            {
              continuation.resume(throwing: error)
            }
          }
        }
        else{
          continuation.resume(throwing: "Error logging in" as! Error)
        }
      }
    }
  }
  
  static func removeObservers(account: AuxrAccount){
    self.observing = false
    self.accounts_ref.child(account.ID).removeAllObservers()
  }
  
  static func logout(user: User){
    do
    {
      try Auth.auth().signOut()
      if let acct = user.Account {
        self.removeObservers(account: acct)
      }
      user.RemoveAccount()
    }
    catch
    {
      print("Error logging out")
    }
  }
  
  static func deleteAccount(account: AuxrAccount) async throws {
    if let user = Auth.auth().currentUser {
      self.removeObservers(account: account)
      do
      {
        try await deleteProfilePicture(account_id: account.ID)
      }
      catch
      {
        print("Profile picture not found")
      }
      
      for friend in account.Friends {
        do
        {
          try await self.removeFriend(friendID: friend.ID)
        }
        catch
        {
          print("Error deleting friend: Friend ID: \(friend.ID)")
        }
      }
      
      let all_requests = account.RoomRequests + account.FriendRequests + account.LikeNotifications
      for request in all_requests {
        do
        {
          try await self.deleteRequest(request: request)
        }
        catch
        {
          print("Error deleting: Request ID: \(request.ID)")
        }
      }
      
      for channel in account.Channels {
        do
        {
          let room = try await FirebaseManager.FetchRoomByID(ID: channel.ID)
          if room.Creator.pai == account.ID {
            try await self.deleteChannel(room: room)
          }
          else if room.Host.pai == account.ID {
            try await FirebaseManager.setHostToCreator(room: room)
          }
          else{
            if let usr = room.Guests.first(where: { $0.pai == account.ID}){
              try await FirebaseManager.RemoveGuest(Room: room, User: usr)
            }
          }
        }
        catch
        {
          print("Error leaving channel: \(channel.ID)")
        }
      }
      let ref = self.accounts_ref.child(account.ID)
      try await ref.removeValue()
      try await user.delete()
    }
  }
  
  static func createAccount(username: String, password: String, user: User) async throws -> Void {
    return try await withCheckedThrowingContinuation { continuation in
      Auth.auth().createUser(withEmail: username + "@auxr.app", password: password){ authResult, error in
        if let error_unwrapped = error {
          return continuation.resume(throwing: error_unwrapped)
        }
        if let res = authResult {
          Task{
            do
            {
              let new_account = AuxrAccount(Username: username, ID: res.user.uid)
              try await storeAccount(account: new_account)
              await user.SetAccount(Account: new_account)
              continuation.resume()
            }
            catch
            {
              continuation.resume(throwing: error)
            }
          }
        }
        else{
          continuation.resume(throwing: "Error creating account" as! Error)
        }
      }
    }
  }
  
  private static func storeAccount(account: AuxrAccount) async throws -> Void {
    return try await withCheckedThrowingContinuation { continuation in
      do
      {
        try self.accounts_ref.child(account.ID).setValue(FirebaseEncoder().encode(account))
        continuation.resume()
      }
      catch
      {
        continuation.resume(throwing: error)
      }
    }
  }
  
  static func getAccount(account_id: String) async throws -> AuxrAccount {
    return try await withCheckedThrowingContinuation { continuation in
      self.accounts_ref.child(account_id).observeSingleEvent(of: .value){ snapshot, error in
        if let snp = snapshot.value {
          do
          {
            let acct = try FirebaseDecoder().decode(AuxrAccount.self, from: snp)
            continuation.resume(returning: acct)
          }
          catch let error
          {
            continuation.resume(throwing: error)
          }
        }
        else{
          continuation.resume(throwing: "Account not found" as! Error)
        }
      }
    }
  }
  
  static func observeAccount(account: AuxrAccount){
    guard !self.observing else{ return }
    self.observing = true
    let ref = self.accounts_ref.child(account.ID)
    ref.observe(.value, with: { snapshot in
      do
      {
        if let snp = snapshot.value{
          print("Account Updated")
          let acct = try FirebaseDecoder().decode(AuxrAccount.self, from: snp)
          //user.setAccount(account: acct)
          account.Copy(account: acct)
        }
      }
      catch let error
      {
        print(error)
      }
    })
  }
  
  static func searchAccounts(query_string: String) async throws -> [AuxrAccount] {
    guard !query_string.isEmpty else{ return [AuxrAccount]() }
    let search_on = "Username"
    var accounts_set = Set<AuxrAccount>()
    var query = self.accounts_ref.queryOrdered(byChild: search_on).queryStarting(atValue: query_string).queryEnding(atValue: query_string + "\u{f8ff}")
    var snapshot = await query.observeSingleEventAndPreviousSiblingKey(of: .value)
    if let accounts_dict = snapshot.0.value as? [String: Any]{
      for account in accounts_dict.keys {
        do
        {
          accounts_set.insert(try FirebaseDecoder().decode(AuxrAccount.self, from: accounts_dict[account] as Any))
        }
        catch
        {
          print(error)
        }
      }
    }
    
    let query_string_lowercased = query_string.lowercased()
    query = self.accounts_ref.queryOrdered(byChild: search_on).queryStarting(atValue: query_string_lowercased).queryEnding(atValue: query_string_lowercased + "\u{f8ff}")
    snapshot = await query.observeSingleEventAndPreviousSiblingKey(of: .value)
    if let accounts_dict = snapshot.0.value as? [String: Any]{
      for account in accounts_dict.keys {
        do
        {
          accounts_set.insert(try FirebaseDecoder().decode(AuxrAccount.self, from: accounts_dict[account] as Any))
        }
        catch
        {
          print(error)
        }
      }
    }
    if let curr_user = self.current_user_id {
      accounts_set = accounts_set.filter { $0.ID != curr_user }
    }
    return Array(accounts_set)
  }
  
  @MainActor
  static func sendFriendRequest(account_id: String, user: User) async throws {
    if let acct = user.Account {
      if acct.FriendRequests.contains(where: {$0.isSender(pai: account_id)}){
        return // Already recieved
      }
      if acct.FriendRequests.contains(where: { $0.isReceiver(pai: account_id) }){
        return // already sent
      }
      if acct.Friends.contains(where: { $0.ID == account_id }){
        return // Already friends
      }
      let request = AuxrRequest(type: .friend, Sender: user.pai, Receiver: account_id, params: nil, Responded: false)
      let encoded_request = try FirebaseEncoder().encode(request)
      let childUpdates = ["/\(user.pai)/FriendRequests/\(request.ID)": encoded_request,
                          "/\(account_id)/FriendRequests/\(request.ID)/": encoded_request]
      try await self.accounts_ref.updateChildValues(childUpdates)
      acct.FriendRequests.append(request)
    }
    else{ return }
  }
  
  @MainActor
  static func acceptFriendRequest(request: AuxrRequest, user: User) async throws {
    if user.pai == request.Sender {
      return // sent from self
    }
    let childUpdates = ["/\(request.Sender)/FriendRequests/\(request.ID)": nil,
                        "/\(request.Sender)/Friends/\(request.Receiver)": try FirebaseEncoder().encode(AuxrFriend(userID: request.Receiver)),
                        "/\(request.Receiver)/FriendRequests/\(request.ID)/": nil,
                        "/\(request.Receiver)/Friends/\(request.Sender)": try FirebaseEncoder().encode(AuxrFriend(userID: request.Sender))] as [String : Any?]
    try await self.accounts_ref.updateChildValues(childUpdates as [AnyHashable : Any])
  }
  
  @MainActor
  static func denyFriendRequest(request: AuxrRequest) async throws {
    let childUpdates = ["/\(request.Sender)/FriendRequests/\(request.ID)": nil,
                        "/\(request.Receiver)/FriendRequests/\(request.ID)/": nil] as [String : Any?]
    try await self.accounts_ref.updateChildValues(childUpdates as [AnyHashable : Any])
  }
  
  @MainActor
  static func removeFriend(friendID: String) async throws {
    if let curr_id = current_user_id {
      let childUpdates = ["/\(curr_id)/Friends/\(friendID)": nil,
                          "/\(friendID)/Friends/\(curr_id)/": nil] as [String : Any?]
      try await self.accounts_ref.updateChildValues(childUpdates as [AnyHashable : Any])
    }
  }
  
  static func updateDisplayName(account: AuxrAccount, displayName: String) async throws {
    let ref = self.accounts_ref.child(account.ID).child("DisplayName")
    try await ref.setValue(FormatTextFieldInputKeepWhitespace(Input: displayName))
  }
  
  @MainActor
  static func updatePassword(new_password: String) async throws {
    return try await withCheckedThrowingContinuation { continuation in
      Auth.auth().currentUser?.updatePassword(to: new_password){ error in
        if let err = error {
          continuation.resume(throwing: err)
        }
        else{
          continuation.resume()
        }
      }
    }
  }
  
  static func updatePrivateMode(account: AuxrAccount) async throws {
    let ref = self.accounts_ref.child(account.ID).child("PrivateMode")
    try await ref.setValue(account.PrivateMode)
  }
  
  static func updateHideLikes(account: AuxrAccount) async throws {
    let ref = self.accounts_ref.child(account.ID).child("HideLikes")
    try await ref.setValue(account.HideLikes)
  }
  
  static func updateHideChannels(account: AuxrAccount) async throws {
    let ref = self.accounts_ref.child(account.ID).child("HideChannels")
    try await ref.setValue(account.HideChannels)
  }
  
  static func updateAppleMusicConnected(account: AuxrAccount, appleMusicConnected: Bool) async throws {
    let ref = self.accounts_ref.child(account.ID).child("AppleMusicConnected")
    try await ref.setValue(appleMusicConnected)
  }
  
  @MainActor
  static func addChannel(account: AuxrAccount, channel: AuxrChannel) async throws {
    let ref = self.accounts_ref.child(account.ID).child("Channels").child(channel.ID)
    try await ref.setValue(FirebaseEncoder().encode(channel))
  }
  
  @MainActor
  static func updateChannel(account: AuxrAccount, room: Room) async throws {
    if let i: Int = account.Channels.firstIndex(where: { $0.RoomData.roomID == room.ID }){
      account.Channels[i].RoomData.ReplaceAll(Room: room)
      let ref = self.accounts_ref.child(account.ID).child("Channels").child(account.Channels[i].ID)
      try await ref.setValue(FirebaseEncoder().encode(account.Channels[i]))
    }
  }
  
  @MainActor
  static func deleteChannel(room: Room) async throws {
    var childUpdates = [String: Any?]()
    childUpdates["/\(room.Creator.pai)/Channels/\(room.ID)"] = nil as Any?
    childUpdates["/\(room.Host.pai)/Channels/\(room.ID)"] = nil as Any?
    room.Guests.forEach { guest in
      childUpdates["/\(guest.pai)/Channels/\(room.ID)"] = nil as Any?
    }
    try await self.accounts_ref.updateChildValues(childUpdates as [AnyHashable : Any])
    try await FirebaseManager.DeleteRoom(Room: room)
  }
  
  static func deleteRequest(request: AuxrRequest) async throws {
    var request_path = ""
    switch(request.type){
    case .room:
      request_path = "RoomRequests"
    case .friend:
      request_path = "FriendRequests"
    case .like:
      request_path = "LikeNotifications"
    }
    let childUpdates = ["/\(request.Sender)/\(request_path)/\(request.ID)": nil,
                        "/\(request.Receiver)/\(request_path)/\(request.ID)/": nil] as [String : Any?]
    try await self.accounts_ref.updateChildValues(childUpdates as [AnyHashable : Any])
  }
  
  static func clearInbox(account: AuxrAccount) async throws {
    var childUpdates = [String: Any?]()
    for req in account.Inbox {
      switch(req.type){
      case .room:
        childUpdates["/\(req.Sender)/RoomRequests/\(req.ID)"] = nil as Any?
        childUpdates["/\(req.Receiver)/RoomRequests/\(req.ID)/"] = nil as Any?
      case .friend:
        childUpdates["/\(req.Sender)/FriendRequests/\(req.ID)"] = nil as Any?
        childUpdates["/\(req.Receiver)/FriendRequests/\(req.ID)/"] = nil as Any?
      case .like:
        childUpdates["/\(req.Sender)/LikeNotifications/\(req.ID)"] = nil as Any?
        childUpdates["/\(req.Receiver)/LikeNotifications/\(req.ID)/"] = nil as Any?
      }
    }
    try await self.accounts_ref.updateChildValues(childUpdates as [AnyHashable : Any])
  }

  static func leaveChannel(account_id: String, room: Room) async throws {
    let childUpdates = ["/\(account_id)/Channels/\(room.ID)": nil] as [String : Any?]
    try await self.accounts_ref.updateChildValues(childUpdates as [AnyHashable : Any])
  }
  
  static func updateChannelLikes(account: AuxrAccount, room: Room, like: AuxrSong) async throws {
    if let i: Int = account.Channels.firstIndex(where: { $0.RoomData.roomID == room.ID }){
      let ref = self.accounts_ref.child(account.ID).child("Channels").child(account.Channels[i].ID).child("Likes").child(like.ID)
      try await ref.setValue(FirebaseEncoder().encode(like))
    }
  }
  
  static func updateChannelVotes(account: AuxrAccount, room: Room, vote: AuxrSong) async throws {
    if let i: Int = account.Channels.firstIndex(where: { $0.RoomData.roomID == room.ID }){
      let ref = self.accounts_ref.child(account.ID).child("Channels").child(account.Channels[i].ID).child("Votes").child(vote.ID)
      try await ref.setValue(FirebaseEncoder().encode(vote))
    }
  }
  
  static func deleteChannelLikes(account: AuxrAccount, room: Room) async throws {
    if let i: Int = account.Channels.firstIndex(where: { $0.RoomData.roomID == room.ID }){
      let ref = self.accounts_ref.child(account.ID).child("Channels").child(account.Channels[i].ID).child("Likes")
      try await ref.removeValue()
    }
  }
  
  static func deleteChannelVotes(account: AuxrAccount, room: Room) async throws {
    if let i: Int = account.Channels.firstIndex(where: { $0.RoomData.roomID == room.ID }){
      let ref = self.accounts_ref.child(account.ID).child("Channels").child(account.Channels[i].ID).child("Votes")
      try await ref.removeValue()
    }
  }
  
  static func addPoints(account: AuxrAccount, p: Int) async throws {
    let ref = self.accounts_ref.child(account.ID).child("Points")
    try await ref.setValue(account.Points+p)
  }
  
  static func subtractPoints(account: AuxrAccount, p: Int) async throws {
    let ref = self.accounts_ref.child(account.ID).child("Points")
    try await ref.setValue(account.Points-p)
  }
  
  @MainActor
  static func sendRoomInvite(room_id: String, recieving_account: String, sending_account: AuxrAccount) async throws {
    let request = AuxrRequest(type: .room, Sender: sending_account.ID, Receiver: recieving_account, params: ["room_id": room_id], Responded: false)
    if sending_account.didSendRequest(request: request){
      return // already sent
    }
    let encoded_request = try FirebaseEncoder().encode(request)
    let childUpdates = ["/\(sending_account.ID)/RoomRequests/\(request.ID)": encoded_request,
                        "/\(recieving_account)/RoomRequests/\(request.ID)/": encoded_request]
    try await self.accounts_ref.updateChildValues(childUpdates)
  }
  
  @MainActor
  static func acceptRoomInvite(request: AuxrRequest, account: AuxrAccount) async throws {
    if request.type != .room {
      return
    }
    let childUpdates = ["/\(request.Sender)/RoomRequests/\(request.ID)": nil,
                        "/\(request.Receiver)/RoomRequests/\(request.ID)/": nil] as [String : Any?]
    try await self.accounts_ref.updateChildValues(childUpdates as [AnyHashable : Any])
  }
  
  @MainActor
  static func denyRoomInvite(request: AuxrRequest, account: AuxrAccount) async throws {
    let childUpdates = ["/\(request.Sender)/RoomRequests/\(request.ID)": nil,
                        "/\(request.Receiver)/RoomRequests/\(request.ID)/": nil] as [String : Any?]
    try await self.accounts_ref.updateChildValues(childUpdates as [AnyHashable : Any])
  }
  
  static func sendLikeNotification(song: AuxrSong, sending_account: AuxrAccount) async throws {
    for friend in sending_account.Friends{
      let request = AuxrRequest(type: .like, Sender: sending_account.ID, Receiver: friend.ID, params: ["song_id": song.AppleMusic], Responded: false)
      let encoded_request = try FirebaseEncoder().encode(request)
      if sending_account.didSendRequest(request: request){
        return // already sent
      }
      let childUpdates = ["/\(sending_account.ID)/LikeNotifications/\(request.ID)": nil,
                          "/\(friend.ID)/LikeNotifications/\(request.ID)/": encoded_request]
      try await self.accounts_ref.updateChildValues(childUpdates as [AnyHashable : Any])
    }
    try await addAccountLikes(account: sending_account, like: song)
  }
  
  static func dismissLikeNotification(request: AuxrRequest) async throws {
    let childUpdates = ["/\(request.Sender)/LikeNotifications/\(request.ID)": nil,
                        "/\(request.Receiver)/LikeNotifications/\(request.ID)/": nil] as [String : Any?]
    try await self.accounts_ref.updateChildValues(childUpdates as [AnyHashable : Any])
  }
  
  static func addAccountLikes(account: AuxrAccount, like: AuxrSong) async throws {
    if(!account.Likes.contains(where: { $0.AppleMusic == like.AppleMusic })){
      let newSong:AuxrSong = AuxrSong()
      newSong.ID = like.ID
      newSong.AppleMusic = like.AppleMusic
      newSong.Title = like.Title
      newSong.Artist = like.Artist
      newSong.Album = like.Album
      newSong.Duration = newSong.Duration
      newSong.QueuedBy = newSong.QueuedBy
      newSong.Index = account.GlobalLikesIndex+1
      try await updateGlobalLikesIndex(account: account)
      let ref = self.accounts_ref.child(account.ID).child("Likes").child(newSong.ID)
      try await ref.setValue(FirebaseEncoder().encode(newSong))
    }
  }
  
  static func deleteAccountLikes(account: AuxrAccount, like: AuxrSong) async throws {
    let ref = self.accounts_ref.child(account.ID).child("Likes").child(like.ID)
    try await ref.removeValue()
  }
  
  static func updateGlobalLikesIndex(account: AuxrAccount) async throws {
    let ref = self.accounts_ref.child(account.ID).child("GlobalLikesIndex")
    try await ref.setValue(account.GlobalLikesIndex + 1)
  }
  
  static func incrementSongsQueued(account: AuxrAccount) async throws {
    let ref = self.accounts_ref.child(account.ID).child("SongsQueued")
    try await ref.setValue(ServerValue.increment(1))
  }

  static func incrementChannelsCreated(account: AuxrAccount) async throws {
    let ref = self.accounts_ref.child(account.ID).child("ChannelsCreated")
    try await ref.setValue(ServerValue.increment(1))
  }

  static func incrementChannelsJoined(account: AuxrAccount) async throws {
    let ref = self.accounts_ref.child(account.ID).child("ChannelsJoined")
    try await ref.setValue(ServerValue.increment(1))
  }
}
