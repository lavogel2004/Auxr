import SwiftUI
import OSLog

enum RoomOnboardingError: String, CaseIterable, Identifiable {
  case nicknameInput,
       roomInput,
       passwordInput,
       roomLimit,
       getRoom,
       joinRoom,
       connectAppleMusicAccount,
       appleMusicAuthorization,
       appleMusicSubscription,
       unknown,
       none
  var id: Self { self }
}

class RoomOnboardingManager {
  init(){}
  
  // MARK: Create Loader Handler
  @MainActor
  func CreateRoom(User: User, Room: Room, AppleMusic: AppleMusic) async -> RoomOnboardingError {
    switch(Room.MusicService){
    case "AppleMusic":
      if(AppleMusic.Authorized == .notDetermined){ return RoomOnboardingError.connectAppleMusicAccount }
      if(AppleMusic.Authorized == .restricted || AppleMusic.Authorized == .denied){ return RoomOnboardingError.appleMusicAuthorization }
      if(AppleMusic.Subscription == AppleMusicSubscriptionStatus.notActive ||
         AppleMusic.Subscription == AppleMusicSubscriptionStatus.notChecked){
        return RoomOnboardingError.appleMusicSubscription
      }
    default:
      if(AppleMusic.Authorized == .notDetermined){ return RoomOnboardingError.connectAppleMusicAccount }
      if(AppleMusic.Authorized == .restricted || AppleMusic.Authorized == .denied){
        return RoomOnboardingError.appleMusicAuthorization
      }
    }
    
    if(Room.Name.isEmpty){ return RoomOnboardingError.roomInput }
    if(User.Nickname.isEmpty){ return RoomOnboardingError.nicknameInput }
    
    var validPasscode = false
    repeat{
      Room.Passcode = Room.GeneratePasscode()
      validPasscode = await FirebaseManager.isValidPasscode(Passcode: Room.Passcode)
    }while(!validPasscode)
    validPasscode = false

    FirebaseManager.StoreRoom(Room: Room)
    
    return RoomOnboardingError.none
  }
  
  // MARK: Join Loader Handler
  func JoinRoom(User: User, Room: Room, AppleMusic: AppleMusic) async throws -> RoomOnboardingError {
    do
    {
      if(User.Nickname.isEmpty){ return RoomOnboardingError.nicknameInput }
      Logger.room.log("Joined")
      let RoomToJoin = try await FirebaseManager.JoinRoom(Passcode: Room.Passcode, User: User)
      try await Room.ReplaceAll(Room: RoomToJoin)
      if(Room.Guests.count >= Room.maxUsers){
        try await FirebaseManager.RemoveGuest(Room: Room, User: User)
        return RoomOnboardingError.roomLimit
      }
      Logger.room.log("MusicService: \(Room.MusicService)")
      if(Room.MusicService == "AppleMusic" &&
         AppleMusic.Authorized == .notDetermined){
        try await AppleMusic.Authorize()
        Logger.room.log("Authorized: \(AppleMusic.Authorized )")
        if(AppleMusic.Authorized == .notDetermined){ return RoomOnboardingError.connectAppleMusicAccount }
        if(AppleMusic.Authorized == .restricted || AppleMusic.Authorized == .denied){
          return RoomOnboardingError.appleMusicAuthorization
        }
      }
      else{
        try await FirebaseManager.RemoveGuest(Room: Room, User: User)
        if(AppleMusic.Authorized == .notDetermined){ return RoomOnboardingError.connectAppleMusicAccount }
        if(AppleMusic.Authorized == .restricted || AppleMusic.Authorized == .denied){
          return RoomOnboardingError.appleMusicAuthorization
        }
      }
    }
    catch FirebaseError.notFound{ return RoomOnboardingError.passwordInput }
    catch FirebaseError.decode{ return RoomOnboardingError.getRoom }
    catch _ { return RoomOnboardingError.unknown }
    
    if let account = User.Account{
      do
      {
        try await AccountManager.addPoints(account: account, p: 1)
      }
      catch _ {}
    }
    
    return RoomOnboardingError.none
  }
  
  func ConvertRoomOnboardingErrorToChannelError(rError: RoomOnboardingError) -> ChannelError{
    var Error: ChannelError = ChannelError.none
    switch(rError){
    case RoomOnboardingError.nicknameInput: Error = ChannelError.nicknameInput
    case RoomOnboardingError.roomInput: Error = ChannelError.roomInput
    case RoomOnboardingError.passwordInput: Error = ChannelError.passwordInput
    case RoomOnboardingError.roomLimit: Error = ChannelError.roomInput
    case RoomOnboardingError.getRoom: Error = ChannelError.getRoom
    case RoomOnboardingError.joinRoom: Error = ChannelError.joinRoom
    case RoomOnboardingError.connectAppleMusicAccount: Error = ChannelError.connectAppleMusicAccount
    case RoomOnboardingError.appleMusicAuthorization: Error = ChannelError.appleMusicAuthorization
    case RoomOnboardingError.appleMusicSubscription: Error = ChannelError.appleMusicSubscription
    case RoomOnboardingError.unknown: Error = ChannelError.unknown
    case RoomOnboardingError.none: Error = ChannelError.none
    }
    return Error
  }
}
