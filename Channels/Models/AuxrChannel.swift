import SwiftUI

class RoomMetadata: ObservableObject, Identifiable, Codable {
  @Published var ID = UUID().uuidString
  @Published var roomID: String = ""
  var timestamp: Int = 0
  
  init(){}
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.ID = try container.decode(String.self, forKey: .ID)
    self.roomID = try container.decode(String.self, forKey: .roomID)
  }
  
  func ReplaceAll(Room: Room){
    self.roomID = Room.ID
    self.timestamp = Room.timestamp
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.ID, forKey: .ID)
    try container.encode(self.roomID, forKey: .roomID)
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
         roomID
  }
}

class AuxrChannel: ObservableObject, Identifiable, Codable, Equatable, Comparable, Hashable {
  @Published var ID: String
  @Published var RoomData: RoomMetadata = RoomMetadata()
  @Published var Likes: [AuxrSong] = []
  @Published var Votes: [AuxrSong] = []
  @Published var updated: Bool = false
  var timestamp: Int = 0
  
  static func ==(LHS: AuxrChannel, RHS: AuxrChannel) -> Bool { return LHS.RoomData.ID == RHS.RoomData.ID }
  static func !=(LHS: AuxrChannel, RHS: AuxrChannel) -> Bool { return LHS.RoomData.ID != RHS.RoomData.ID }
  static func <(LHS: AuxrChannel, RHS: AuxrChannel) -> Bool { return LHS.timestamp < RHS.timestamp }
  static func >(LHS: AuxrChannel, RHS: AuxrChannel) -> Bool { return LHS.timestamp > RHS.timestamp }
  
  init(ID: String){
    self.ID = ID
  }
  
  func hash(into hasher: inout Hasher){
    hasher.combine(self.ID)
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.ID = try container.decode(String.self, forKey: .ID)
    do
    {
      self.RoomData = try container.decode(RoomMetadata.self, forKey: .RoomData)
    }
    catch _
    {
      self.RoomData = RoomMetadata()
    }
    do
    {
      let LikesDictionary = try container.decode([String:AuxrSong].self, forKey: .Likes)
      self.Likes = Array(LikesDictionary.values)
    }
    catch _
    {
      self.Likes = []
    }
    do
    {
      let VotesDictionary = try container.decode([String:AuxrSong].self, forKey: .Votes)
      self.Votes = Array(VotesDictionary.values)
    }
    catch _
    {
      self.Votes = []
    }
    do
    {
      self.updated = try container.decode(Bool.self, forKey: .updated)
    }
    catch _
    {
      self.updated = false
    }
    do
    {
      self.timestamp = try container.decode(Int.self, forKey: .timestamp)
    }
    catch _
    {
      self.timestamp = 0
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.ID, forKey: .ID)
    try container.encode(self.RoomData, forKey: .RoomData)
    try container.encode(self.Likes, forKey: .Likes)
    try container.encode(self.Votes, forKey: .Votes)
    try container.encode(self.updated, forKey: .updated)
    try container.encode(self.timestamp, forKey: .timestamp)
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
         RoomData,
         Likes,
         Votes,
         updated,
         timestamp
  }
}
