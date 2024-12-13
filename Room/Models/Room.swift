import SwiftUI
import CodableFirebase
import OSLog

class Room: ObservableObject, Identifiable, Codable, CustomStringConvertible {
  init(){}
  
  @Published var ID = UUID().uuidString
  @Published var Name: String = ""
  @Published var Creator: User = User()
  @Published var Host: User = User()
  @Published var Guests: [User] = []
  @Published var MusicService: String = "AppleMusic"
  @Published var SharePermission: Bool = true
  @Published var BecomeHostPermission: Bool = false
  @Published var SwappingHost: Bool = false
  @Published var Playlist: AuxrPlaylist = AuxrPlaylist()
  @Published var Refreshing: Bool = false
  @Published var GlobalPlaylistIndex: Int = 0
  @Published var GlobalPlaylistIndex2: Int = -1
  @Published var GlobalVoteCount: Int = 0
  @Published var Voting: Bool = false
  @Published var Passcode: String = ""
  @Published var AddSong: Bool = false
  @Published var Controlled: Bool = false
  @Published var SongControlled: Bool = false
  @Published var UpNext: Bool = false
  @Published var PlaySong: Bool = false
  @Published var SkipSong: Bool = false
  @Published var PlayPausePermission: Bool = false
  @Published var SkipPermission: Bool = false
  @Published var RemovePermission: Bool = false
  @Published var VoteModePermission: Bool = true
  @Published var InFirstTime: Bool = true
  var maxUsers: Int = 100
  var timestamp: Int = 0
  private var version: String = "2.0.0"
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    self.ID = try container.decode(String.self, forKey: .ID)
    do {
      self.Name = try container.decode(String.self, forKey: .Name)
    }
    catch _
    {
      self.Name = ""
    }
    do
    {
      self.Creator = try container.decode(User.self, forKey: .Creator)
    }
    catch _
    {
      self.Creator = User()
    }
    do {
      self.Host = try container.decode(User.self, forKey: .Host)
    }
    catch _
    {
      self.Host = User()
    }
    do
    {
      let GuestsDictionary = try container.decode([String: User].self, forKey: .Guests)
      self.Guests = Array(GuestsDictionary.values)
    }
    catch _
    {
      self.Guests = []
    }
    do
    {
        self.MusicService = try container.decode(String.self, forKey: .MusicService)
    }
    catch _
    {
        self.MusicService = "AppleMusic"
    }
    catch _
    {
      self.MusicService = ""
    }
    do
    {
      self.SharePermission = try container.decode(Bool.self, forKey: .SharePermission)
    }
    catch _
    {
      self.SharePermission = false
    }
    do
    {
      self.BecomeHostPermission = try container.decode(Bool.self, forKey: .BecomeHostPermission)
    }
    catch _
    {
      self.BecomeHostPermission = false
    }
    do
    {
      self.SwappingHost = try container.decode(Bool.self, forKey: .SwappingHost)
    }
    catch _
    {
      self.SwappingHost = false
    }
    do
    {
      self.Playlist = try container.decode(AuxrPlaylist.self, forKey: .Playlist)
    }
    catch _
    {
      self.Playlist = AuxrPlaylist()
    }
    do
    {
      self.Refreshing = try container.decode(Bool.self, forKey: .Refreshing)
    }
    catch _
    {
      self.Refreshing = false
    }
    do
    {
      self.GlobalPlaylistIndex = try container.decode(Int.self, forKey: .GlobalPlaylistIndex)
    }
    catch _
    {
      self.GlobalPlaylistIndex = 0
    }
    do
    {
      self.GlobalPlaylistIndex2 = try container.decode(Int.self, forKey: .GlobalPlaylistIndex2)
    }
    catch _
    {
      self.GlobalPlaylistIndex2 = 0
    }
    do
    {
      self.GlobalVoteCount = try container.decode(Int.self, forKey: .GlobalVoteCount)
    }
    catch _
    {
      self.GlobalVoteCount = 0
    }
    do
    {
      self.Voting = try container.decode(Bool.self, forKey: .Voting)
    }
    catch _
    {
      self.Voting = false
    }
    do
    {
      self.Passcode = try container.decode(String.self, forKey: .Passcode)
    }
    catch _
    {
      self.Passcode = ""
    }
    do
    {
      self.PlaySong = try container.decode(Bool.self, forKey: .PlaySong)
    }
    catch _
    {
      self.PlaySong = false
    }
    do
    {
      self.SkipSong = try container.decode(Bool.self, forKey: .SkipSong)
    }
    catch _
    {
      self.SkipSong = false
    }
    do
    {
      self.Controlled = try container.decode(Bool.self, forKey: .Controlled)
    }
    catch _
    {
      self.Controlled = false
    }
    do
    {
      self.SongControlled = try container.decode(Bool.self, forKey: .SongControlled)
    }
    catch _
    {
      self.SongControlled = false
    }
    do
    {
      self.UpNext = try container.decode(Bool.self, forKey: .UpNext)
    }
    catch _
    {
      self.UpNext = false
    }
    do
    {
      self.PlayPausePermission = try container.decode(Bool.self, forKey: .PlayPausePermission)
    }
    catch _
    {
      self.PlayPausePermission = false
    }
    do
    {
      self.SkipPermission = try container.decode(Bool.self, forKey: .SkipPermission)
    }
    catch _
    {
      self.SkipPermission = false
    }
    do
    {
      self.RemovePermission = try container.decode(Bool.self, forKey: .RemovePermission)
    }
    catch _
    {
      self.RemovePermission = false
    }
    do
    {
      self.VoteModePermission = try container.decode(Bool.self, forKey: .VoteModePermission)
    }
    catch _
    {
      self.VoteModePermission = true
    }
    do
    {
      self.maxUsers = try container.decode(Int.self, forKey: .maxUsers)
    }
    catch _
    {
      self.maxUsers = 100
    }
    do
    {
      self.timestamp = try container.decode(Int.self, forKey: .timestamp)
    }
    catch _
    {
      self.timestamp = 0
    }
    do
    {
      self.version = try container.decode(String.self, forKey: .version)
    }
    catch _
    {
      self.version = "unknown"
    }
  }
  
  // MARK: Generate Room Passcode
  func GeneratePasscode() -> String {
    let AlphaNumerics = "ABCDEFGHJKMNPQRSTUVWXYZ123456789"
    let Numbers = "0123456789"
    var AlphaNumericsString = String((0..<3).map{ _ in AlphaNumerics.randomElement()! })
    let NumericString = String((0..<1).map{ _ in Numbers.randomElement()! })
    let random = Int.random(in: 0..<AlphaNumericsString.count)
    AlphaNumericsString.insert(contentsOf: NumericString, at: AlphaNumericsString.index(AlphaNumericsString.startIndex, offsetBy: random))
    return AlphaNumericsString
  }
  
  // MARK: Room Status Checkers
  func Host(User: User) -> Bool { return User == self.Host }
  func Guest(User: User) -> Bool { return Guests.contains(User) }
  func Creator(User: User) -> Bool { return User == self.Creator }
  
  // MARK: Disconnect From Room
  @MainActor
  func Disconnect(User: User, AppleMusic: AppleMusic, Router: Router) async throws {
    Logger.room.log("Disconnected")
    do
    {
      FirebaseManager.RemoveObservers(Room: self)
      if(self.Host(User: User)){
        try await FirebaseManager.DeleteRoom(Room: self)
      }
      else{
        try await FirebaseManager.RemoveGuest(Room: self, User: User)
      }
      if(User.pai.isEmpty){
        Task{ try await SystemReset(User: User, Room: self, AppleMusic: AppleMusic) }
        Router.popToRoot()
      }
      else{
        Router.popToAccount()
      }
    }
    catch _ {}
  }
  
  // MARK: Disconnect From Channel
  @MainActor
  func ChannelDisconnect(User: User, AppleMusic: AppleMusic) async throws {
    Logger.room.log("Disconnected")
    Task{
      try await AppleMusic.Reset()
      try await AppleMusic.PlayerReset()
    }
    FirebaseManager.RemoveObservers(Room: self)
    try await self.Reset()
  }
  
  // MARK: Update General Room Values
  @MainActor
  func GeneralReplace(Room: Room) async throws {
    self.ID = Room.ID
    self.Name = Room.Name
    self.Creator = Room.Creator
    self.Host = Room.Host
    self.Guests = Room.Guests
    self.MusicService = Room.MusicService
    self.Refreshing = Room.Refreshing
    self.GlobalPlaylistIndex = Room.GlobalPlaylistIndex
    self.GlobalPlaylistIndex2 = Room.GlobalPlaylistIndex2
    self.GlobalVoteCount = Room.GlobalVoteCount
    self.Voting = Room.Voting
    self.Controlled = Room.Controlled
    self.SongControlled = Room.SongControlled
    self.UpNext = Room.UpNext
    self.PlaySong = Room.PlaySong
    self.SkipSong = Room.SkipSong
    self.SharePermission = Room.SharePermission
    self.BecomeHostPermission = Room.BecomeHostPermission
    self.PlayPausePermission = Room.PlayPausePermission
    self.SkipPermission = Room.SkipPermission
    self.RemovePermission = Room.RemovePermission
    self.VoteModePermission = Room.VoteModePermission
    self.maxUsers = Room.maxUsers
    self.timestamp = Room.timestamp
  }
  
  // MARK: Update All Room Values
  @MainActor
  func ReplaceAll(Room: Room) async throws {
    self.ID = Room.ID
    self.Name = Room.Name
    self.Creator = Room.Creator
    self.Host = Room.Host
    self.Guests = Room.Guests
    self.MusicService = Room.MusicService
    self.Playlist = Room.Playlist
    self.Refreshing = Room.Refreshing
    self.GlobalPlaylistIndex = Room.GlobalPlaylistIndex
    self.GlobalPlaylistIndex2 = Room.GlobalPlaylistIndex2
    self.GlobalVoteCount = Room.GlobalVoteCount
    self.Voting = Room.Voting
    self.Passcode = Room.Passcode
    self.Controlled = Room.Controlled
    self.SongControlled = Room.SongControlled
    self.PlaySong = Room.PlaySong
    self.SkipSong = Room.SkipSong
    self.SharePermission = Room.SharePermission
    self.BecomeHostPermission = Room.BecomeHostPermission
    self.PlayPausePermission = Room.PlayPausePermission
    self.SkipPermission = Room.SkipPermission
    self.RemovePermission = Room.RemovePermission
    self.VoteModePermission = Room.VoteModePermission
    self.maxUsers = Room.maxUsers
    self.timestamp = Room.timestamp
  }
  
  // MARK: Room Refresh
  @MainActor
  func Refresh(AppleMusic: AppleMusic, User: User) async throws {
    self.Refreshing = true
    try await FirebaseManager.UpdateRoomRefreshing(Room: self)
    if(self.Controlled){
      self.Controlled = false
      try await FirebaseManager.UpdateRoomControlled(Room: self)
    }
    
    if(self.SongControlled){
      self.SongControlled = false
      try await FirebaseManager.UpdateSongControlled(Room: self)
    }
    
    if(self.Playlist.QueueInitializing){
      self.Playlist.QueueInitializing = false
      try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: self)
    }
    
    try await FirebaseManager.UpdatePlaylistQueue(Room: self)
    
    if(self.SkipSong){
      self.SkipSong = false
      try await FirebaseManager.UpdateRoomSkipSong(Room: self)
    }
    
    self.Playlist.TotalPlaytime = self.Playlist.QueueTotalPlaytime(Room: self)
    try await FirebaseManager.UpdatePlaylistTotalPlaytime(Room: self)
    
    if(self.Host(User: User)){
      if(self.PlaySong && AppleMusic.player.state.playbackStatus == .playing){
        try await AppleMusic.QueueControl(Room: self)
        try await AppleMusic.BackgroundTaskFetch(Room: self)
      }
    }
    
    self.Refreshing = false
    try await FirebaseManager.UpdateRoomRefreshing(Room: self)
    
    // MARK: Refresh Notification
    if(!self.Host.InRoom){
      NotificationManager.SendWakeupHostNotification(
        hostFcmToken: self.Host.token,
        queueAction: "refresh",
        completion: { success, error in
          if(!success){ print("ERROR: " + error) }
        }
      )
    }
  }
  
  // MARK: Scene Phase Handler
  @MainActor
  func ScenePhaseHandler(phase: ScenePhase, User: User, AppleMusic: AppleMusic){
    switch(phase){
    case .background:
      Task{
        AppleMusic.UserRecommended.GeneratingRandom = false
        AppleMusic.UserRecommended.GeneratingSimilar = false
        if(self.Host(User: User) && User.InRoom){
          if(self.MusicService == "AppleMusic"){ try await AppleMusic.BackgroundTaskFetch(Room: self) }
        }
        User.InRoom = false
        try await FirebaseManager.UpdateUserInRoom(User: User, Room: self)
        if let userAccount: AuxrAccount = User.Account{
          let _ = try await User.StoreChannelLikesVotes(User: User, Account: userAccount, Room: self)
        }
      }
    case .inactive:
      Task{
        AppleMusic.UserRecommended.GeneratingRandom = false
        AppleMusic.UserRecommended.GeneratingSimilar = false
        if(self.Host(User: User) && User.InRoom){
          if(self.MusicService == "AppleMusic"){ try await AppleMusic.BackgroundTaskFetch(Room: self) }
        }
        User.InRoom = false
        try await FirebaseManager.UpdateUserInRoom(User: User, Room: self)
        if let userAccount: AuxrAccount = User.Account{
          let _ = try await User.StoreChannelLikesVotes(User: User, Account: userAccount, Room: self)
        }
      }
    case .active:
      Task{
        User.InRoom = true
        try await FirebaseManager.UpdateUserInRoom(User: User, Room: self)
        if(self.Host(User: User) && User.InRoom){
          if(self.MusicService == "AppleMusic"){ try await AppleMusic.BackgroundTaskFetch(Room: self) }
          if(self.Controlled){
            self.Controlled  = false
            try await FirebaseManager.UpdateRoomControlled(Room: self)
          }
        }
        if let userAccount: AuxrAccount = User.Account{
          let _ = try await User.StoreChannelLikesVotes(User: User, Account: userAccount, Room: self)
        }
      }
    @unknown default:
      return
    }
  }
  
  // MARK: Room Reset
  @MainActor
  func Reset() async throws {
    self.ID = UUID().uuidString
    self.Name = ""
    self.Creator = User()
    self.Host = User()
    self.Guests = []
    self.MusicService = ""
    self.SharePermission = true
    self.BecomeHostPermission = false
    self.SwappingHost = false
    self.Playlist = try await self.Playlist.Reset()
    self.Refreshing = false
    self.GlobalPlaylistIndex = 0
    self.GlobalPlaylistIndex2 = -1
    self.GlobalVoteCount = 0
    self.Voting = false
    self.Passcode = ""
    self.AddSong = false
    self.Controlled = false
    self.SongControlled = false
    self.UpNext = false
    self.PlaySong = false
    self.SkipSong = false
    self.PlayPausePermission = false
    self.SkipPermission = false
    self.RemovePermission = false
    self.VoteModePermission = true
    self.InFirstTime = true
  }
  
  var description: String {
    do
    {
      let encoder = JSONEncoder()
      encoder.outputFormatting = .prettyPrinted
      let json = try encoder.encode(self)
      return String(data: json, encoding: .utf8)!
    }
    catch let error{ return error.localizedDescription }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(self.ID, forKey: .ID)
    try container.encode(self.Name, forKey: .Name)
    try container.encode(self.Creator, forKey: .Creator)
    try container.encode(self.Host, forKey: .Host)
    try container.encode(self.Guests, forKey: .Guests)
    try container.encode(self.MusicService, forKey: .MusicService)
    try container.encode(self.SharePermission, forKey: .SharePermission)
    try container.encode(self.BecomeHostPermission, forKey: .BecomeHostPermission)
    try container.encode(self.SwappingHost, forKey: .SwappingHost)
    try container.encode(self.Playlist, forKey: .Playlist)
    try container.encode(self.Refreshing, forKey: .Refreshing)
    try container.encode(self.GlobalPlaylistIndex, forKey: .GlobalPlaylistIndex)
    try container.encode(self.GlobalPlaylistIndex2, forKey: .GlobalPlaylistIndex2)
    try container.encode(self.GlobalVoteCount, forKey: .GlobalVoteCount)
    try container.encode(self.Voting, forKey: .Voting)
    try container.encode(self.Passcode, forKey: .Passcode)
    try container.encode(self.Controlled, forKey: .Controlled)
    try container.encode(self.SongControlled, forKey: .SongControlled)
    try container.encode(self.UpNext, forKey: .UpNext)
    try container.encode(self.PlaySong, forKey: .PlaySong)
    try container.encode(self.SkipSong, forKey: .SkipSong)
    try container.encode(self.PlayPausePermission, forKey: .PlayPausePermission)
    try container.encode(self.SkipPermission, forKey: .SkipPermission)
    try container.encode(self.RemovePermission, forKey: .RemovePermission)
    try container.encode(self.VoteModePermission, forKey: .VoteModePermission)
    try container.encode(self.maxUsers, forKey: .maxUsers)
    try container.encode(self.timestamp, forKey: .timestamp)
    try container.encode(self.version, forKey: .version)
  }
  
  private enum CodingKeys: String, CodingKey {
    case ID,
         Name,
         Creator,
         Host,
         Guests,
         MusicService,
         SharePermission,
         BecomeHostPermission,
         SwappingHost,
         Playlist,
         Refreshing,
         GlobalPlaylistIndex,
         GlobalPlaylistIndex2,
         GlobalVoteCount,
         Voting,
         Passcode,
         Controlled,
         SongControlled,
         UpNext,
         PlaySong,
         SkipSong,
         PlayPausePermission,
         SkipPermission,
         RemovePermission,
         VoteModePermission,
         maxUsers,
         timestamp,
         version
  }
}
