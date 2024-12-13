import Firebase
import CodableFirebase
import OSLog

enum FirebaseError: Error { case notFound, decode }

class FirebaseManager {
  static var reference = Database.database().reference()
  static var roomReferenced: Bool = false
  
  // MARK: User Firebase Handlers
  static func StoreUser(User: User){
    do
    {
      try self.reference.child("users").child(User.ID).setValue(FirebaseEncoder().encode(User))
    }
    catch _ {}
  }
  
  @MainActor
  static func UpdateUserInRoom(User: User, Room: Room) async throws {
    if(Room.Creator(User: User)){
      let ref = self.reference.child("rooms").child(Room.ID).child("Creator").child("InRoom")
      try await ref.setValue(User.InRoom)
    }
    if(Room.Host(User: User)){
      let ref = self.reference.child("rooms").child(Room.ID).child("Host").child("InRoom")
      try await ref.setValue(User.InRoom)
    }
    if(Room.Guest(User: User)){
      let ref = self.reference.child("rooms").child(Room.ID).child("Guests").child(User.ID).child("InRoom")
      try await ref.setValue(User.InRoom)
    }
  }
  
  @MainActor
  static func UpdateUserPlayPausePermission(User: User, Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("Guests").child(User.ID).child("PlayPausePermission")
    try await ref.setValue(User.PlayPausePermission)
  }
  
  @MainActor
  static func UpdateUserSkipPermission(User: User, Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("Guests").child(User.ID).child("SkipPermission")
    try await ref.setValue(User.SkipPermission)
  }
  
  @MainActor
  static func UpdateUserRemovePermission(User: User, Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("Guests").child(User.ID).child("RemovePermission")
    try await ref.setValue(User.RemovePermission)
  }
  
  // MARK: Room Firebase Handlers
  static func StoreRoom(Room: Room){
    do
    {
      Room.timestamp = Int(NSDate().timeIntervalSince1970)
      try self.reference.child("rooms").child(Room.ID).setValue(FirebaseEncoder().encode(Room))
    }
    catch _ {}
  }
  
  @MainActor
  static func GetRoomUpdates(room: Room, completion: @escaping (_ Room: Room,_ String: String) -> Void){
    guard !FirebaseManager.roomReferenced else{ return }
    let ref = self.reference.child("rooms").child(room.ID)
    FirebaseManager.roomReferenced = true
    ref.observe(.value, with: { snapshot in
      do
      {
        if let snp = snapshot.value{
          let rm = try FirebaseDecoder().decode(Room.self, from: snp)
          completion(rm, "success")
        }
      }
      catch let error
      {
        print(error)
        completion(room, error.localizedDescription)
      }
    })
  }
  
  static func RemoveObservers(Room: Room){
    self.roomReferenced = false
    self.reference.child("rooms").child(Room.ID).removeAllObservers()
  }
  
  @MainActor
  static func isValidPasscode(Passcode: String) async -> Bool {
    do
{
      try await FirebaseManager.FetchRoom(Passcode: Passcode)
      return false
    }
    catch { return true }
  }
  
  @MainActor
  @discardableResult
  static func FetchRoom(Passcode: String) async throws -> Room {
    let ref = self.reference.child("rooms")
    let qry = ref.queryOrdered(byChild: "Passcode").queryEqual(toValue: Passcode)
    let snapshot = await qry.observeSingleEventAndPreviousSiblingKey(of: .value)
    if !snapshot.0.exists(){ throw FirebaseError.notFound }
    if let room = snapshot.0.value{
      do
      {
        let rm_tpl = try FirebaseDecoder().decode([String: Room].self, from: room)
        if let room = rm_tpl.first{ return room.value }
        else{ throw FirebaseError.decode }
      }
      catch{ throw FirebaseError.decode }
    }
    else{ throw FirebaseError.notFound }
  }
  
  @MainActor
  @discardableResult
  static func FetchRoomByID(ID: String) async throws -> Room {
    let ref = self.reference.child("rooms")
    let qry = ref.queryOrdered(byChild: "ID").queryEqual(toValue: ID)
    let snapshot = await qry.observeSingleEventAndPreviousSiblingKey(of: .value)
    if !snapshot.0.exists(){ throw FirebaseError.notFound }
    if let room = snapshot.0.value{
      do
      {
        let rm_tpl = try FirebaseDecoder().decode([String: Room].self, from: room)
        if let room = rm_tpl.first{ return room.value }
        else{ throw FirebaseError.decode }
      }
      catch{ throw FirebaseError.decode }
    }
    else{ throw FirebaseError.notFound }
  }
  
  @MainActor
  static func JoinRoom(Passcode: String, User: User) async throws -> Room {
    let rm = try await FetchRoom(Passcode: Passcode)
    if(!rm.Guest(User: User)){
      Logger.room.log("Guest \(User.ID) added")
      let new_rm = try await AddGuest(Room: rm, User: User)
      return new_rm
    }
    Logger.room.log("Guest already in room")
    return rm
  }
  
  @MainActor
  static func JoinRoom(room_id: String, User: User) async throws -> Room {
    let rm = try await FetchRoomByID(ID: room_id)
    if(!rm.Guest(User: User)){
      Logger.room.log("Guest \(User.ID) added")
      let new_rm = try await AddGuest(Room: rm, User: User)
      return new_rm
    }
    Logger.room.log("Guest already in room")
    return rm
  }

  @MainActor
  static func JoinChannel(Passcode: String, User: User) async throws -> Room {
    let rm = try await FetchRoom(Passcode: Passcode)
    if let account = User.Account{
      if(rm.Creator.pai == account.ID){
        let _ = try await UpdateCreator(Room: rm, User: User)
      }
      if(rm.Host.pai == account.ID){
        let new_rm = try await UpdateHost(Room: rm, User: User)
        return new_rm
      }
      else if let i: Int = rm.Guests.firstIndex(where: {
        $0.pai  == account.ID }){
        User.ID = rm.Guests[i].ID
        rm.Guests[i].Nickname = User.Nickname
        let ref = self.reference.child("rooms").child(rm.ID).child("Guests").child(User.ID)
        try await ref.setValue(FirebaseEncoder().encode(User))
        return rm
      }
      else{
        let ref = self.reference.child("rooms").child(rm.ID).child("Guests").child(User.ID)
        try await ref.setValue(FirebaseEncoder().encode(User))
        return rm
      }
    }
    return rm
  }
    
  
  @MainActor
  static func DeleteRoom(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID)
    try await ref.removeValue()
  }
  
  @MainActor
  static func AddGuest(Room: Room, User: User) async throws -> Room {
    let ref = self.reference.child("rooms").child(Room.ID).child("Guests").child(User.ID)
    try await ref.setValue(FirebaseEncoder().encode(User))
    Room.Guests.append(User)
    return Room
  }
  
  @MainActor
  static func SwapHost(Passcode: String, User: User) async throws {
    let rm = try await FetchRoom(Passcode: Passcode)
    rm.SwappingHost = true
    try await UpdateSwappingHost(Room: rm)
    let tmpUser1: User = User
    let tmpUser2: User = rm.Host
    let host_rm_ref = try await UpdateSwapHost(Room: rm, User: User)
    if let i: Int = rm.Guests.firstIndex(where : { $0.pai == tmpUser1.pai }){
      let guest_ref = self.reference.child("rooms").child(host_rm_ref.ID).child("Guests").child(host_rm_ref.Guests[i].ID)
      try await guest_ref.removeValue()
      let new_rm = try await AddGuest(Room: rm, User: tmpUser2)
      try await rm.ReplaceAll(Room: new_rm)
    }
    else if let i: Int = rm.Guests.firstIndex(where: { $0.token == tmpUser1.token }){
      let guest_ref = self.reference.child("rooms").child(host_rm_ref.ID).child("Guests").child(host_rm_ref.Guests[i].ID)
      try await guest_ref.removeValue()
      let new_rm = try await AddGuest(Room: rm, User: tmpUser2)
      try await rm.ReplaceAll(Room: new_rm)
    }
    else{
      try await rm.ReplaceAll(Room: rm)
      rm.SwappingHost = false
      try await UpdateSwappingHost(Room: rm)
    }
    try await rm.ReplaceAll(Room: rm)
    rm.SwappingHost = false
    try await UpdateSwappingHost(Room: rm)
  }
  
  @MainActor
  static func UpdateCreator(Room: Room, User: User) async throws -> Room {
    let ref = self.reference.child("rooms").child(Room.ID).child("Creator")
    try await ref.setValue(FirebaseEncoder().encode(User))
    User.ID = Room.Creator.ID
    Room.Creator.Nickname = User.Nickname
    Room.Creator = User
    return Room
  }
  
  @MainActor
  static func UpdateSwapHost(Room: Room, User: User) async throws -> Room {
    let ref = self.reference.child("rooms").child(Room.ID).child("Host")
    try await ref.setValue(FirebaseEncoder().encode(User))
    Room.Host = User
    return Room
  }

  static func setHostToCreator(room: Room) async throws {
    let ref = self.reference.child("rooms")
    let childUpdates = ["/\(room.ID)/Host/": try FirebaseEncoder().encode(room.Creator),
                        "/\(room.ID)/Guests/\(room.Creator.ID)": nil] as [String : Any?]
    try await ref.updateChildValues(childUpdates as [AnyHashable : Any])
  }

  @MainActor
  static func UpdateHost(Room: Room, User: User) async throws -> Room {
    let ref = self.reference.child("rooms").child(Room.ID).child("Host")
    try await ref.setValue(FirebaseEncoder().encode(User))
    User.ID = Room.Host.ID
    Room.Host.Nickname = User.Nickname
    Room.Host = User
    return Room
  }
  
  @MainActor
  static func UpdateRoomName(Room: Room, Name: String) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("Name")
    try await ref.setValue(Name)
  }
  
  @MainActor
  static func UpdatePasscode(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("Passcode")
    try await ref.setValue(Room.Passcode)
  }
  
  @MainActor
  static func UpdateSwappingHost(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("SwappingHost")
    try await ref.setValue(Room.SwappingHost)
  }
  
  @MainActor
  static func UpdateRoomRefreshing(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("Refreshing")
    try await ref.setValue(Room.Refreshing)
  }
  
  @MainActor
  static func UpdateRoomGlobalPlaylistIndex(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("GlobalPlaylistIndex")
    try await ref.setValue(Room.GlobalPlaylistIndex + 1)
  }
  
  @MainActor
  static func UpdateRoomGlobalPlaylistIndex2(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("GlobalPlaylistIndex2")
    try await ref.setValue(Room.GlobalPlaylistIndex2 - 1)
  }
  
  @MainActor
  static func UpdateRoomVoteCount(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("GlobalVoteCount")
    try await ref.setValue(Room.GlobalVoteCount + 1)
  }
  
  @MainActor
  static func UpdateRoomVoting(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("Voting")
    try await ref.setValue(Room.Voting)
  }
  
  @MainActor
  static func UpdateAddSong(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("AddSong")
    try await ref.setValue(Room.AddSong)
  }
  
  @MainActor
  static func RemoveGuest(Room: Room, User: User) async throws {
    Logger.room.log("Guest \(User.ID) removed")
    if(!User.pai.isEmpty){
      if let i: Int = Room.Guests.firstIndex(where: { $0.pai == User.pai}){
        User.ID = Room.Guests[i].ID
        let ref = self.reference.child("rooms").child(Room.ID).child("Guests").child(User.ID)
        try await ref.removeValue()
      }
    }
    else{
      let ref = self.reference.child("rooms").child(Room.ID).child("Guests").child(User.ID)
      try await ref.removeValue()
    }
  }
  
  @MainActor
  static func UpdatePlaylistQueue(Room: Room) async throws {
    var songIndices = Set<Int>()
    for song in Room.Playlist.Queue.sorted(){
      let ref = self.reference.child("rooms").child(Room.ID).child("Playlist").child("Queue").child(song.ID)
      if(!songIndices.contains(song.Index)){
        songIndices.insert(song.Index)
        try await ref.setValue(FirebaseEncoder().encode(song))
        if let i = Room.Playlist.History.firstIndex(where: { $0.ID == song.ID }){
          let historySong = Room.Playlist.History.sorted()[i]
          let h_ref = self.reference.child("rooms").child(Room.ID).child("Playlist").child("History").child(historySong.ID)
          try await h_ref.setValue(FirebaseEncoder().encode(historySong))
        }
      }
      else{
        try await ref.removeValue()
        if let i: Int = Room.Playlist.History.firstIndex(where: { $0.ID == song.ID }){
          let historySong: AuxrSong = Room.Playlist.History.sorted()[i]
          let h_ref = self.reference.child("rooms").child(Room.ID).child("Playlist").child("History").child(historySong.ID)
          try await h_ref.removeValue()
        }
      }
    }
  }
  
  @MainActor
  static func UpdateRoomControlled(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("Controlled")
    try await ref.setValue(Room.Controlled)
  }
  
  @MainActor
  static func UpdateRoomGuestControlled(Room: Room) async throws {
    if(!Room.Guests.isEmpty){
      for guest in Room.Guests{
        guest.Controlled = true
        let ref = self.reference.child("rooms").child(Room.ID).child("Guests").child(guest.ID).child("Controlled")
        try await ref.setValue(guest.Controlled)
      }
    }
  }
  
  @MainActor
  static func UpdateSongControlled(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("SongControlled")
    try await ref.setValue(Room.SongControlled)
  }
  
  @MainActor
  static func UpdateRoomUpNext(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("UpNext")
    try await ref.setValue(Room.UpNext)
  }
  
  @MainActor
  static func UpdateRoomPlaySong(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("PlaySong")
    try await ref.setValue(Room.PlaySong)
  }
  
  @MainActor
  static func UpdateRoomSkipSong(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("SkipSong")
    try await ref.setValue(Room.SkipSong)
  }
  
  @MainActor
  static func UpdateRoomSharePermission(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("SharePermission")
    try await ref.setValue(Room.SharePermission)
  }
  
  @MainActor
  static func UpdateRoomBecomeHostPermission(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("BecomeHostPermission")
    try await ref.setValue(Room.BecomeHostPermission)
  }
  
  @MainActor
  static func UpdatePlayPausePermission(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("PlayPausePermission")
    try await ref.setValue(Room.PlayPausePermission)
  }
  
  @MainActor
  static func UpdateSkipPermission(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("SkipPermission")
    try await ref.setValue(Room.SkipPermission)
  }
  
  @MainActor
  static func UpdateRemovePermission(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("RemovePermission")
    try await ref.setValue(Room.RemovePermission)
  }
  
  @MainActor
  static func UpdateVoteModePermission(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("VoteModePermission")
    try await ref.setValue(Room.VoteModePermission)
  }
  
  // MARK: Playlist Firebase Handlers
  @MainActor
  static func AddSongToPlaylistLocalAdd(Room: Room, AuxrSong: AuxrSong, account: AuxrAccount?) async throws {
    var ref = self.reference.child("rooms").child(Room.ID).child("Playlist").child("LocalAdd").child(AuxrSong.ID)
    try await ref.setValue(FirebaseEncoder().encode(AuxrSong))
    ref = self.reference.child("rooms").child(Room.ID).child("timestamp")
    try await ref.setValue(Int(NSDate().timeIntervalSince1970))
    if let acct = account {
      try await AccountManager.incrementSongsQueued(account: acct)
    }
  }
  
  @MainActor
  static func ClearPlaylistLocalAdd(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("Playlist").child("LocalAdd")
    try await ref.removeValue()
  }
  
  @MainActor
  static func AddSongToPlaylistQueue(Room: Room, AuxrSong: AuxrSong) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("Playlist").child("Queue").child(AuxrSong.ID)
    try await ref.setValue(FirebaseEncoder().encode(AuxrSong))
  }
  
  @MainActor
  static func RemoveSongFromPlaylistQueue(Room: Room, AuxrSong: AuxrSong) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("Playlist").child("Queue").child(AuxrSong.ID)
    try await ref.removeValue()
  }
  
  @MainActor
  static func UpdatePlaylistQueueSong(Room: Room, AuxrSong: AuxrSong) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("Playlist").child("Queue").child(AuxrSong.ID)
    try await ref.setValue(FirebaseEncoder().encode(AuxrSong))
  }
  
  @MainActor
  static func UpdatePlaylistQueue2Songs(Room: Room, AuxrSong1: AuxrSong, AuxrSong2: AuxrSong) async throws {
    let ref_1 = self.reference.child("rooms").child(Room.ID).child("Playlist").child("Queue").child(AuxrSong1.ID)
    let ref_2 = self.reference.child("rooms").child(Room.ID).child("Playlist").child("Queue").child(AuxrSong2.ID)
    try await ref_1.setValue(FirebaseEncoder().encode(AuxrSong1))
    try await ref_2.setValue(FirebaseEncoder().encode(AuxrSong2))
  }
  
  @MainActor
  static func AddSongToUserPlaylistVotes(User: User, Room: Room, AuxrSong: AuxrSong) async throws {
    if(Room.Host(User: User)){
      let ref = self.reference.child("rooms").child(Room.ID).child("Host").child("Votes").child(AuxrSong.ID)
      try await ref.setValue(FirebaseEncoder().encode(AuxrSong))
    }
    
    if(Room.Guest(User: User)){
      let ref = self.reference.child("rooms").child(Room.ID).child("Guests").child(User.ID).child("Votes").child(AuxrSong.ID)
      try await ref.setValue(FirebaseEncoder().encode(AuxrSong))
    }
  }
  
  @MainActor
  static func RemoveSongFromUserPlaylistVotes(User: User, Room: Room, AuxrSong: AuxrSong) async throws {
    if(Room.Host(User: User)){
      let ref = self.reference.child("rooms").child(Room.ID).child("Host").child("Votes").child(AuxrSong.ID)
      try await ref.removeValue()
    }
    
    if(Room.Guest(User: User)){
      let ref = self.reference.child("rooms").child(Room.ID).child("Guests").child(User.ID).child("Votes").child(AuxrSong.ID)
      try await ref.removeValue()
    }
  }
  
  @MainActor
  static func AddSongToPlaylistHistory(Room: Room, AuxrSong: AuxrSong) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("Playlist").child("History").child(AuxrSong.ID)
    try await ref.setValue(FirebaseEncoder().encode(AuxrSong))
  }
  
  @MainActor
  static func UpdatePlaylistHistorySong(Room: Room, AuxrSong: AuxrSong) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("Playlist").child("History").child(AuxrSong.ID)
    try await ref.setValue(FirebaseEncoder().encode(AuxrSong))
  }
  
  @MainActor
  static func RemoveSongFromPlaylistHistory(Room: Room, AuxrSong: AuxrSong) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("Playlist").child("History").child(AuxrSong.ID)
    try await ref.removeValue()
  }
  
  @MainActor
  static func UpdatePlaylistTotalPlaytime(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("Playlist").child("TotalPlaytime")
    try await ref.setValue(Room.Playlist.TotalPlaytime)
  }
  
  @MainActor
  static func UpdatePlaylistQueueInitializing(Room: Room) async throws {
    let ref = self.reference.child("rooms").child(Room.ID).child("Playlist").child("QueueInitializing")
    try await ref.setValue(Room.Playlist.QueueInitializing)
  }
}
