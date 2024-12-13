import SwiftUI

class AuxrSong: ObservableObject, Identifiable, Codable, Comparable, Hashable {
  init(){}
  
  @Published var ID: String = UUID().uuidString
  @Published var AppleMusic: String = ""
  @Published var Title: String = ""
  @Published var Artist: String = ""
  @Published var Album: String = ""
  @Published var Duration: Double = 0.0
  @Published var QueuedBy: String = ""
  @Published var Index: Int = 0
  @Published var Upvotes: Int = 0
  
  static func ==(LHS: AuxrSong, RHS: AuxrSong) -> Bool { return LHS.Index == RHS.Index }
  static func !=(LHS: AuxrSong, RHS: AuxrSong) -> Bool { return LHS.Index != RHS.Index }
  static func <(LHS: AuxrSong, RHS: AuxrSong) -> Bool { return LHS.Index < RHS.Index }
  static func >(LHS: AuxrSong, RHS: AuxrSong) -> Bool { return LHS.Index > RHS.Index }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.ID = try container.decode(String.self, forKey: .ID)
    self.AppleMusic = try container.decode(String.self, forKey: .AppleMusic)
    self.Title = try container.decode(String.self, forKey: .Title)
    self.Artist = try container.decode(String.self, forKey: .Artist)
    self.Album = try container.decode(String.self, forKey: .Album)
    self.Duration = try container.decode(Double.self, forKey: .Duration)
    self.QueuedBy = try container.decode(String.self, forKey: .QueuedBy)
    self.Index = try container.decode(Int.self, forKey: .Index)
    self.Upvotes = try container.decode(Int.self, forKey: .Upvotes)
  }
  
  func hash(into hasher: inout Hasher){
    hasher.combine(self.ID)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(self.ID, forKey: .ID)
    try container.encode(self.AppleMusic, forKey: .AppleMusic)
    try container.encode(self.Title, forKey: .Title)
    try container.encode(self.Artist, forKey: .Artist)
    try container.encode(self.Album, forKey: .Album)
    try container.encode(self.Duration, forKey: .Duration)
    try container.encode(self.QueuedBy, forKey: .QueuedBy)
    try container.encode(self.Index, forKey: .Index)
    try container.encode(self.Upvotes, forKey: .Upvotes)
  }
  
  private enum CodingKeys: String, CodingKey {
    case ID,
         AppleMusic,
         Title,
         Artist,
         Album,
         Duration,
         QueuedBy,
         Index,
         Upvotes
  }
}
