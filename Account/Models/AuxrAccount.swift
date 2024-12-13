import SwiftUI

class AuxrAccount: ObservableObject, Identifiable, Codable, Equatable, Hashable {
  var ID: String
  @Published var Username: String = ""
  @Published var AppleMusicConnected: Bool = false
  @Published var DisplayName: String = ""
  @Published var ReferralCode: String = ""
  @Published var PrivateMode: Bool = false
  @Published var HideLikes: Bool = false
  @Published var HideChannels: Bool = false
  @Published var Channels: [AuxrChannel] = []
  @Published var Friends: [AuxrFriend] = []
  @Published var Likes: [AuxrSong] = []
  @Published var GlobalLikesIndex: Int = 0
  @Published var FriendRequests: [AuxrRequest] = []
  @Published var RoomRequests: [AuxrRequest] = []
  @Published var LikeNotifications: [AuxrRequest] = []
  @Published var Inbox: Set<AuxrRequest> = Set<AuxrRequest>()
  @Published var Points: Int = 0
  @Published var SongsQueued: Int = 0
  @Published var ChannelsCreated: Int = 0
  @Published var ChannelsJoined: Int = 0
  
  func hash(into hasher: inout Hasher){
    hasher.combine(self.ID)
  }
  
  static func ==(LHS: AuxrAccount, RHS: AuxrAccount) -> Bool { return LHS.ID == RHS.ID }
  
  init(Username: String, ID: String){
    self.Username = Username.lowercased()
    self.ID = ID
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.ID = try container.decode(String.self, forKey: .ID)
    self.Username = try container.decode(String.self, forKey: .Username)
    self.AppleMusicConnected = try container.decode(Bool.self, forKey: .AppleMusicConnected)
    do
    {
      self.DisplayName = try container.decode(String.self, forKey: .DisplayName)
    }
    catch _
    {
      self.DisplayName = ""
    }
    self.ReferralCode = try container.decode(String.self, forKey: .ReferralCode)
    do
    {
      self.PrivateMode = try container.decode(Bool.self, forKey: .PrivateMode)
    }
    catch _
    {
      self.PrivateMode = false
    }
    do
    {
      self.HideLikes = try container.decode(Bool.self, forKey: .HideLikes)
    }
    catch _
    {
      self.HideLikes = false
    }
    do
    {
      self.HideChannels = try container.decode(Bool.self, forKey: .HideChannels)
    }
    catch _
    {
      self.HideChannels = false
    }
    do
    {
      let ChannelsDictionary = try container.decode([String: AuxrChannel].self, forKey: .Channels)
      self.Channels = Array(ChannelsDictionary.values)
    }
    catch _
    {
      self.Channels = []
    }
    do
    {
      let FriendsDictionary = try container.decode([String: AuxrFriend].self, forKey: .Friends)
      self.Friends = Array(FriendsDictionary.values)
    }
    catch _
    {
      self.Friends = []
    }
    do
    {
      let LikesDictionary = try container.decode([String: AuxrSong].self, forKey: .Likes)
      self.Likes = Array(LikesDictionary.values)
    }
    catch _
    {
      self.Likes = []
    }
    do
    {
      self.GlobalLikesIndex = try container.decode(Int.self, forKey: .GlobalLikesIndex)
    }
    catch _
    {
      self.GlobalLikesIndex = 0
    }
    do
    {
      let FriendRequestsDictionary = try container.decode([String: AuxrRequest].self, forKey: .FriendRequests)
      self.FriendRequests = Array(FriendRequestsDictionary.values)
    }
    catch _
    {
      self.FriendRequests = []
    }
    do
    {
      let RoomRequestsDictionary = try container.decode([String: AuxrRequest].self, forKey: .RoomRequests)
      self.RoomRequests = Array(RoomRequestsDictionary.values)
    }
    catch _
    {
      self.RoomRequests = []
    }
    do
    {
      let LikeNotificationsDictionary = try container.decode([String: AuxrRequest].self, forKey: .LikeNotifications)
      self.LikeNotifications = Array(LikeNotificationsDictionary.values)
    }
    catch _
    {
      self.LikeNotifications = []
    }
    do
    {
      self.Inbox = computeInbox()
    }
    catch _
    {
      self.Inbox = []
    }
    do
    {
      self.Points = try container.decode(Int.self, forKey: .Points)
    }
    catch _
    {
      self.Points = 0
    }
    do
    {
      self.SongsQueued = try container.decode(Int.self, forKey: .SongsQueued)
    }
    catch _
    {
      self.SongsQueued = 0
    }
    do
    {
      self.ChannelsJoined = try container.decode(Int.self, forKey: .ChannelsJoined)
    }
    catch _
    {
      self.ChannelsJoined = 0
    }
    do
    {
      self.ChannelsCreated = try container.decode(Int.self, forKey: .ChannelsCreated)
    }
    catch
    {
      self.ChannelsCreated = 0
    }
  }
  
  func Copy(account: AuxrAccount){
    self.ID = account.ID
    self.Username = account.Username
    self.AppleMusicConnected = AppleMusicConnected
    self.DisplayName = account.DisplayName
    self.ReferralCode = account.ReferralCode
    self.PrivateMode = account.PrivateMode
    self.HideLikes = account.HideLikes
    self.HideChannels = account.HideChannels
    self.Channels = account.Channels
    self.Friends = account.Friends
    self.Likes = account.Likes
    self.GlobalLikesIndex = account.GlobalLikesIndex
    self.FriendRequests = account.FriendRequests
    self.RoomRequests = account.RoomRequests
    self.LikeNotifications = account.LikeNotifications
    self.Inbox = computeInbox()
    self.Points = account.Points
    self.SongsQueued = account.SongsQueued
    self.ChannelsJoined = account.ChannelsJoined
    self.ChannelsCreated = account.ChannelsCreated
  }
  
  func computeInbox() -> Set<AuxrRequest> {
    return Set(self.FriendRequests).union(self.RoomRequests).union(self.LikeNotifications).filter { !$0.isSender(pai: self.ID) }
  }
  
  func didSendRequest(request: AuxrRequest) -> Bool {
    switch(request.type){
    case .room:
      return RoomRequests.contains(where: { $0.isReceiver(pai: request.Receiver) && $0.room_id == request.room_id })
    case .friend:
      return FriendRequests.contains(where: { $0.isReceiver(pai: request.Receiver)})
    case .like:
      return LikeNotifications.contains(where: { $0.isReceiver(pai: request.Receiver) && $0.song_id == request.song_id })
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.ID, forKey: .ID)
    try container.encode(self.Username, forKey: .Username)
    try container.encode(self.AppleMusicConnected, forKey: .AppleMusicConnected)
    try container.encode(self.DisplayName, forKey: .DisplayName)
    try container.encode(self.ReferralCode, forKey: .ReferralCode)
    try container.encode(self.PrivateMode, forKey: .PrivateMode)
    try container.encode(self.HideLikes, forKey: .HideLikes)
    try container.encode(self.HideChannels, forKey: .HideChannels)
    try container.encode(self.Channels, forKey: .Channels)
    try container.encode(self.Friends, forKey: .Friends)
    try container.encode(self.Likes, forKey: .Likes)
    try container.encode(self.GlobalLikesIndex, forKey: .GlobalLikesIndex)
    try container.encode(self.FriendRequests, forKey: .FriendRequests)
    try container.encode(self.RoomRequests, forKey: .RoomRequests)
    try container.encode(self.LikeNotifications, forKey: .LikeNotifications)
    try container.encode(self.Inbox, forKey: .Inbox)
    try container.encode(self.Points, forKey: .Points)
    try container.encode(self.SongsQueued, forKey: .SongsQueued)
    try container.encode(self.ChannelsJoined, forKey: .ChannelsJoined)
    try container.encode(self.ChannelsCreated, forKey: .ChannelsCreated)
  }
  
  var description: String {
    do
    {
      let Encoder = JSONEncoder()
      let JSON = try Encoder.encode(self)
      return String(data: JSON, encoding: .utf8)!
    }
    catch let error{ return error.localizedDescription }
  }
  
  private enum CodingKeys: String, CodingKey {
    case ID,
         Username,
         AppleMusicConnected,
         DisplayName,
         Channels,
         Friends,
         ReferralCode,
         PrivateMode,
         HideLikes,
         HideChannels,
         FriendRequests,
         RoomRequests,
         Likes,
         GlobalLikesIndex,
         LikeNotifications,
         Inbox,
         Points,
         SongsQueued,
         ChannelsCreated,
         ChannelsJoined
  }
}
