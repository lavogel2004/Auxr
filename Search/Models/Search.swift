import SwiftUI

enum SearchFilter: String, CaseIterable, Identifiable {
  case songs, albums, artists
  var id: Self { self }
}

class Search {
  init(){}
  
  // MARK: Search Music Handler
  @MainActor
  func SearchMusic(Room: Room, AppleMusic: AppleMusic, Input: String, Filter: SearchFilter) async throws {
    if(Room.MusicService == "AppleMusic"){ Task{ try await AppleMusic.Search(Input: Input, Filter: Filter, Background: false) } }
  }
  
  // MARK: Check If Searched
  func Searched(Room: Room, AppleMusic: AppleMusic) -> Bool {
    if(Room.MusicService == "AppleMusic"){
      if(!AppleMusic.SongSearchResult.isEmpty || !AppleMusic.AlbumSearchResult.isEmpty){ return true }
    }
    return false
  }
  
  // MARK: Clear Search Results
  func Reset(Room: Room, AppleMusic: AppleMusic){
    if(Room.MusicService == "AppleMusic"){
      AppleMusic.SongSearchResult = []
      AppleMusic.AlbumSearchResult = []
      AppleMusic.ArtistSearchResult = []
    }
  }
}
