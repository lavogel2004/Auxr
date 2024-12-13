import SwiftUI
import CodableFirebase

class AuxrPlaylist: ObservableObject, Identifiable, Codable {
  init(){}
  
  @Published var ID = UUID().uuidString
  @Published var Queue: [AuxrSong] = []
  @Published var VoteQueue: [AuxrSong] = []
  @Published var LocalAdd: [AuxrSong] = []
  @Published var History: [AuxrSong] = []
  @Published var TotalPlaytime: String = ""
  @Published var QueueInitializing: Bool = false
  let TMR = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.ID = try container.decode(String.self, forKey: .ID)
    do
    {
      let QueueDictionary = try container.decode([String:AuxrSong].self, forKey: .Queue)
      self.Queue = Array(QueueDictionary.values)
    }
    catch _
    {
      self.Queue = []
    }
    do
    {
      let VoteQueueDictionary = try container.decode([String:AuxrSong].self, forKey: .VoteQueue)
      self.VoteQueue = Array(VoteQueueDictionary.values)
    }
    catch _
    {
      self.VoteQueue = []
    }
    do
    {
      let LocalAddDictionary = try container.decode([String:AuxrSong].self, forKey: .LocalAdd)
      self.LocalAdd = Array(LocalAddDictionary.values)
    }
    catch _
    {
      self.LocalAdd = []
    }
    do
    {
      let HistoryDictionary = try container.decode([String:AuxrSong].self, forKey: .History)
      self.History = Array(HistoryDictionary.values)
    }
    catch _
    {
      self.History = []
    }
    self.TotalPlaytime = try container.decode(String.self, forKey: .TotalPlaytime)
    self.QueueInitializing = try container.decode(Bool.self, forKey: .QueueInitializing)
  }
  
  // MARK: Move Local Add To Queue
  @MainActor
  func MoveLocalAdd(Room: Room) async throws {
    do
    {
      for song in Room.Playlist.LocalAdd.sorted(){
        Room.Playlist.Queue.append(song)
        try await FirebaseManager.AddSongToPlaylistQueue(Room: Room, AuxrSong: song)
      }
      Room.Playlist.TotalPlaytime = Room.Playlist.QueueTotalPlaytime(Room: Room)
      try await FirebaseManager.UpdatePlaylistTotalPlaytime(Room: Room)
      Room.Playlist.LocalAdd = []
      try await FirebaseManager.ClearPlaylistLocalAdd(Room: Room)
    }
  }
  
  // MARK: Queue Total Playtime
  func QueueTotalPlaytime(Room: Room) -> String {
    var TotalSeconds: Double = 0.0
    for song in Array(Set(Room.Playlist.Queue.sorted())){ TotalSeconds += song.Duration }
    return ConvertSecondsToString(s: TotalSeconds)
  }
  
  // MARK: Auxr Playlist Reset
  @MainActor
  func Reset() async throws -> AuxrPlaylist {
    self.ID = UUID().uuidString
    self.Queue = []
    self.VoteQueue = []
    self.LocalAdd = []
    self.History = []
    self.TotalPlaytime = ""
    self.QueueInitializing = false
    return self
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    
    try container.encode(self.ID, forKey: .ID)
    try container.encode(self.Queue, forKey: .Queue)
    try container.encode(self.VoteQueue, forKey: .VoteQueue)
    try container.encode(self.LocalAdd, forKey: .LocalAdd)
    try container.encode(self.History, forKey: .History)
    try container.encode(self.TotalPlaytime, forKey: .TotalPlaytime)
    try container.encode(self.QueueInitializing, forKey: .QueueInitializing)
  }
  
  private enum CodingKeys: String, CodingKey {
    case ID,
         Queue,
         VoteQueue,
         LocalAdd,
         History,
         TotalPlaytime,
         QueueInitializing
  }
}
