import SwiftUI

enum AuxrRequestType: String, Codable, CaseIterable, Identifiable {
  case friend, room, like
  var id: Self { self }
}

class AuxrRequest: ObservableObject, Identifiable, Codable, Comparable, Equatable, Hashable {
  var type: AuxrRequestType
  @Published var ID: String = UUID().uuidString
  @Published var Sender: String
  @Published var Receiver: String
  @Published var room_id: String?
  @Published var song_id: String?
  @Published var Responded: Bool
  var timestamp: Int =  0
  
  static func == (LHS: AuxrRequest, RHS: AuxrRequest) -> Bool { LHS.ID == RHS.ID }
  static func != (LHS: AuxrRequest, RHS: AuxrRequest) -> Bool { return LHS.ID != RHS.ID }
  static func <(LHS: AuxrRequest, RHS: AuxrRequest) -> Bool { return LHS.timestamp > RHS.timestamp }
  static func >(LHS: AuxrRequest, RHS: AuxrRequest) -> Bool { return LHS.timestamp < RHS.timestamp }
  
  func hash(into hasher: inout Hasher){
    hasher.combine(self.ID)
  }
  
  init(type: AuxrRequestType, Sender: String, Receiver: String, params: [String:Any]?, Responded: Bool){
    self.type = type
    self.Sender = Sender
    self.Receiver = Receiver
    if let p = params {
      if let room_id = p["room_id"] as? String {
        self.room_id = room_id
      }
      if let song_id = p["song_id"] as? String {
        self.song_id = song_id
      }
    }
    self.Responded = Responded
    self.timestamp = Int(NSDate().timeIntervalSince1970)
  }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.type = try container.decode(AuxrRequestType.self, forKey: .type)
    self.ID = try container.decode(String.self, forKey: .ID)
    self.Sender = try container.decode(String.self, forKey: .Sender)
    self.Receiver = try container.decode(String.self, forKey: .Receiver)
    if(self.type == AuxrRequestType.room){ self.room_id = try container.decode(String.self, forKey: .room_id) }
    if(self.type == AuxrRequestType.like){ self.song_id = try container.decode(String.self, forKey: .song_id) }
    self.Responded = try container.decode(Bool.self, forKey: .Responded)
    self.timestamp = try container.decode(Int.self, forKey: .timestamp)
  }
  
  func isSender(pai: String) -> Bool{ return self.Sender == pai }
  func isReceiver(pai: String) -> Bool{ return self.Receiver == pai }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.ID, forKey: .ID)
    try container.encode(self.type, forKey: .type)
    try container.encode(self.Sender, forKey: .Sender)
    try container.encode(self.Receiver, forKey: .Receiver)
    try container.encode(self.room_id, forKey: .room_id)
    try container.encode(self.song_id, forKey: .song_id)
    try container.encode(self.Responded, forKey: .Responded)
    try container.encode(self.timestamp, forKey: .timestamp)
  }
  
  private enum CodingKeys: String, CodingKey {
    case ID,
         type,
         Sender,
         Receiver,
         room_id,
         song_id,
         Responded,
         timestamp
  }
}
