import SwiftUI
import OSLog

enum ChannelError: String, CaseIterable, Identifiable {
  case nicknameInput, roomInput, passwordInput, roomLimit, getRoom, joinRoom, connectAppleMusicAccount, appleMusicAuthorization, appleMusicSubscription, unknown, none
  var id: Self { self }
}

class ChannelsManager {
  init(){}
  
  // MARK: Create Loader Handler
  @MainActor
  func CreateChannel(User: User, Room: Room, AppleMusic: AppleMusic) async -> ChannelError {
    
    switch(Room.MusicService){
    case "AppleMusic":
      if let account: AuxrAccount = User.Account{
        if(User.Nickname.isEmpty){ User.Nickname = (!account.DisplayName.isEmpty) ? account.DisplayName : account.Username }
      }
      if(AppleMusic.Authorized == .notDetermined){ return ChannelError.connectAppleMusicAccount }
      if(AppleMusic.Authorized == .restricted || AppleMusic.Authorized == .denied){ return ChannelError.appleMusicAuthorization }
      if(AppleMusic.Subscription == AppleMusicSubscriptionStatus.notActive ||
         AppleMusic.Subscription == AppleMusicSubscriptionStatus.notChecked){
        return ChannelError.appleMusicSubscription
      }
    default:
      if(AppleMusic.Authorized == .notDetermined){ return ChannelError.connectAppleMusicAccount }
      if(AppleMusic.Authorized == .restricted || AppleMusic.Authorized == .denied){ return ChannelError.appleMusicAuthorization }
    }
    
    if(Room.Name.isEmpty){ return ChannelError.roomInput }
    
    var validPasscode = false
    repeat{
      Room.Passcode = Room.GeneratePasscode()
      validPasscode = await FirebaseManager.isValidPasscode(Passcode: Room.Passcode)
    }while(!validPasscode)
    validPasscode = false
    
    FirebaseManager.StoreRoom(Room: Room)
    if let account: AuxrAccount = User.Account{
      let channel = AuxrChannel(ID: Room.ID)
      let roomRoomData = RoomMetadata()
      roomRoomData.ReplaceAll(Room: Room)
      channel.RoomData = roomRoomData
      channel.timestamp = Int(NSDate().timeIntervalSince1970)
      do
      {
        try await AccountManager.incrementChannelsCreated(account: account)
        try await AccountManager.addChannel(account: account, channel: channel)
      }
      catch _ {}
      do
      {
        try await AccountManager.addPoints(account: account, p: 1)
      }
      catch _ {}
    }
    return ChannelError.none
  }
  
  // MARK: Join Loader Handler
  @MainActor
  func JoinChannel(User: User, Room: Room, Passcode: String, AppleMusic: AppleMusic) async throws -> ChannelError {
    do
    {
      Logger.room.log("Joined")
      if let account: AuxrAccount = User.Account{
        User.Nickname = (!account.DisplayName.isEmpty) ? account.DisplayName : account.Username
      }
      let RoomToJoin = try await FirebaseManager.JoinChannel(Passcode: Passcode, User: User)
      try await Room.ReplaceAll(Room: RoomToJoin)
      if(!RoomToJoin.Creator.pai.isEmpty){
        if let account: AuxrAccount = User.Account{
          if let i: Int = account.Channels.firstIndex(where: { $0.RoomData.roomID == RoomToJoin.ID }){
            account.Channels[i].RoomData.ReplaceAll(Room: RoomToJoin)
          }
          else{
            let channel = AuxrChannel(ID: RoomToJoin.ID)
            let roomData = RoomMetadata()
            roomData.ReplaceAll(Room: RoomToJoin)
            channel.RoomData = roomData
            channel.timestamp = Int(NSDate().timeIntervalSince1970)
            do
            {
              try await AccountManager.incrementChannelsJoined(account: account)
              try await AccountManager.addChannel(account: account, channel: channel)
            }
            catch _ {}
            do
            {
              try await AccountManager.addPoints(account: account, p: 1)
            }
            catch _ {}
          }
        }
      }
      if(Room.Guests.count >= Room.maxUsers){
        try await FirebaseManager.RemoveGuest(Room: Room, User: User)
        return ChannelError.roomLimit
      }
      Logger.room.log("MusicService: \(Room.MusicService)")
    }
    catch FirebaseError.notFound{ return ChannelError.passwordInput }
    catch FirebaseError.decode{ return ChannelError.getRoom }
    catch _ { return ChannelError.unknown }
    if(User.Nickname.isEmpty){ return ChannelError.nicknameInput }
    return ChannelError.none
  }
  
  func ConvertChannelErrorToRoomOnboardingError(cError: ChannelError) -> RoomOnboardingError {
    var Error: RoomOnboardingError = RoomOnboardingError.none
    switch(cError){
    case ChannelError.nicknameInput: Error = RoomOnboardingError.nicknameInput
    case ChannelError.roomInput: Error = RoomOnboardingError.roomInput
    case ChannelError.passwordInput: Error = RoomOnboardingError.passwordInput
    case ChannelError.roomLimit: Error = RoomOnboardingError.roomInput
    case ChannelError.getRoom: Error = RoomOnboardingError.getRoom
    case ChannelError.joinRoom: Error = RoomOnboardingError.joinRoom
    case ChannelError.connectAppleMusicAccount: Error = RoomOnboardingError.connectAppleMusicAccount
    case ChannelError.appleMusicAuthorization: Error = RoomOnboardingError.appleMusicAuthorization
    case ChannelError.appleMusicSubscription: Error = RoomOnboardingError.appleMusicSubscription
    case ChannelError.unknown: Error = RoomOnboardingError.unknown
    case ChannelError.none: Error = RoomOnboardingError.none
    }
    return Error
  }
}
