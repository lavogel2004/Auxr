import SwiftUI
import MusicKit

enum AuxrRecommendNode: String, CaseIterable, Identifiable {
  case queue, library, history, likes, votes, similarSongs, song, artist, album, similarArtists, topSongs, topAlbums, latestRelease, relatedAlbums, track, rerun, none
  var id: Self { self }
}

class AuxrRecommendLayer {
  enum depth: String, CaseIterable, Identifiable {
    case first, second, third, fourth, none
    var id: Self { self }
  }
  var depth: depth = AuxrRecommendLayer.depth.none
  var total: Double = 100.0
  var layerItems: [PriorityItem<AuxrRecommendNode>]
  
  init(depth: depth, total: Double, layerItems: [PriorityItem<AuxrRecommendNode>]){
    self.depth = depth
    self.total = total
    self.layerItems = layerItems
  }
}

class AuxrRecommend: ObservableObject, Identifiable {
  @Published var GeneratingRandom: Bool = false
  @Published var GeneratingSimilar: Bool = false
  @Published var MostFrequentArtistNames: [String] = []
  @Published var MostFrequentAlbumNames: [String] = []
  @Published var MostFrequentArtists: [Artist] = []
  @Published var MostFrequentAlbums: [Album] = []
  @Published var Songs: [Song] = []
  @Published var SimilarSongs: [Song] = []
  
  @Published var QueuePercentage: Double = 0.0
  @Published var LibraryPercentage: Double = 0.0
  @Published var HistoryPercentage: Double = 0.0
  @Published var LikesPercentage: Double = 0.0
  @Published var VotesPercentage: Double = 0.0
  @Published var DefaultPercentage: Double = 0.0
  
  @Published var SongPercentage: Double = 50.0
  @Published var ArtistPercentage: Double = 50.0
  @Published var AlbumPercentage: Double = 50.0
  
  @Published var SimilarArtistsPercentage: Double = 60.0
  @Published var TopSongsPercentage: Double = 15.0
  @Published var TopAlbumsPercentage: Double = 15.0
  @Published var LatestReleasePercentage: Double = 10.0
  
  @Published var RelatedAlbumsPercentage: Double = 50.0
  @Published var TrackPercentage: Double = 50.0
  
  init(){}
  
  func initEntryLayer(QueuePercentage: Double, LibraryPercentage: Double, HistoryPercentage: Double, LikesPercentage: Double, VotesPercentage: Double, DefaultPercentage: Double) -> AuxrRecommendNode? {
    let EntryLayer = AuxrRecommendLayer(
      depth: AuxrRecommendLayer.depth.first,
      total: 100.0,
      layerItems:
        [
          PriorityItem(item: AuxrRecommendNode.queue, percentage: QueuePercentage),
          PriorityItem(item: AuxrRecommendNode.library, percentage: LibraryPercentage),
          PriorityItem(item: AuxrRecommendNode.history, percentage: HistoryPercentage),
          PriorityItem(item: AuxrRecommendNode.likes, percentage: LikesPercentage),
          PriorityItem(item: AuxrRecommendNode.votes, percentage: VotesPercentage),
          PriorityItem(item: AuxrRecommendNode.none, percentage: DefaultPercentage)
        ]
    )
    return GetRandomPriorityItem(from: EntryLayer.layerItems)
  }
  
  func initSecondLayer(SongPercentage: Double, ArtistPercentage: Double) -> AuxrRecommendNode? {
    let SecondLayer = AuxrRecommendLayer(
      depth: AuxrRecommendLayer.depth.second,
      total: 100.0,
      layerItems:
        [
          PriorityItem(item: AuxrRecommendNode.song, percentage: SongPercentage),
          PriorityItem(item: AuxrRecommendNode.artist, percentage: ArtistPercentage)
        ]
    )
    return GetRandomPriorityItem(from: SecondLayer.layerItems)
  }
  
  func initSongLayer(ArtistPercentage: Double, AlbumPercentage: Double) -> AuxrRecommendNode? {
    let SongLayer = AuxrRecommendLayer(
      depth: AuxrRecommendLayer.depth.second,
      total: 100.0,
      layerItems:
        [
          PriorityItem(item: AuxrRecommendNode.artist, percentage: ArtistPercentage),
          PriorityItem(item: AuxrRecommendNode.album, percentage: AlbumPercentage)
        ]
    )
    return GetRandomPriorityItem(from: SongLayer.layerItems)
  }
  
  func initArtistLayer(SimilarArtistsPercentage: Double, TopSongsPercentage: Double, TopAlbumsPercentage: Double, LatestReleasePercentage: Double) -> AuxrRecommendNode? {
    let ArtistLayer = AuxrRecommendLayer(
      depth: AuxrRecommendLayer.depth.second,
      total: 100.0,
      layerItems:
        [
          PriorityItem(item: AuxrRecommendNode.similarArtists, percentage: SimilarArtistsPercentage),
          PriorityItem(item: AuxrRecommendNode.topSongs, percentage: TopSongsPercentage),
          PriorityItem(item: AuxrRecommendNode.topAlbums, percentage: TopAlbumsPercentage),
          PriorityItem(item: AuxrRecommendNode.latestRelease, percentage: LatestReleasePercentage),
        ]
    )
    return GetRandomPriorityItem(from: ArtistLayer.layerItems)
  }
  
  func initAlbumLayer(RelatedAlbumsPercentage: Double, TrackPercentage: Double) -> AuxrRecommendNode? {
    let AlbumLayer = AuxrRecommendLayer(
      depth: AuxrRecommendLayer.depth.third,
      total: 100.0,
      layerItems:
        [
          PriorityItem(item: AuxrRecommendNode.relatedAlbums, percentage: RelatedAlbumsPercentage),
          PriorityItem(item: AuxrRecommendNode.track, percentage: TrackPercentage)
        ]
    )
    return GetRandomPriorityItem(from: AlbumLayer.layerItems)
  }
  
  func initDefaultLayer(QueuePercentage: Double, LibraryPercentage: Double, HistoryPercentage: Double, LikesPercentage: Double, VotesPercentage: Double, TopSongsPercentage: Double, TopAlbumsPercentage: Double) -> AuxrRecommendNode? {
    let TopChartLayer = AuxrRecommendLayer(
      depth: AuxrRecommendLayer.depth.fourth,
      total: 100.0,
      layerItems:
        [
          PriorityItem(item: AuxrRecommendNode.queue, percentage: QueuePercentage),
          PriorityItem(item: AuxrRecommendNode.library, percentage: LibraryPercentage),
          PriorityItem(item: AuxrRecommendNode.history, percentage: HistoryPercentage),
          PriorityItem(item: AuxrRecommendNode.likes, percentage: LikesPercentage),
          PriorityItem(item: AuxrRecommendNode.votes, percentage: VotesPercentage),
          PriorityItem(item: AuxrRecommendNode.topSongs, percentage: TopSongsPercentage),
          PriorityItem(item: AuxrRecommendNode.topAlbums, percentage: TopAlbumsPercentage)
        ]
    )
    return GetRandomPriorityItem(from: TopChartLayer.layerItems)
  }
  
  func selectLayerNode(layer: AuxrRecommendLayer) -> AuxrRecommendNode? { return GetRandomPriorityItem(from: layer.layerItems) }
  
  func initLayerFlow() -> [AuxrRecommendNode]{
    var flow: [AuxrRecommendNode] = []
    
    if let entryPoint = self.initEntryLayer(
      QueuePercentage: self.QueuePercentage,
      LibraryPercentage: self.LibraryPercentage,
      HistoryPercentage: self.HistoryPercentage,
      LikesPercentage: self.LikesPercentage,
      VotesPercentage: self.VotesPercentage,
      DefaultPercentage: self.DefaultPercentage){
      flow.append(entryPoint)
      if let secondLayerChoice = self.initSecondLayer(
        SongPercentage: self.SongPercentage,
        ArtistPercentage: self.ArtistPercentage){
        flow.append(secondLayerChoice)
        if(secondLayerChoice == AuxrRecommendNode.song){
          if let rootSongLayerChoice = self.initSongLayer(
            ArtistPercentage: self.ArtistPercentage,
            AlbumPercentage: self.AlbumPercentage){
            flow.append(rootSongLayerChoice)
            if(rootSongLayerChoice == AuxrRecommendNode.artist){
              if let artistLayerChoice = initArtistLayer(SimilarArtistsPercentage: self.SimilarArtistsPercentage, TopSongsPercentage: self.TopSongsPercentage, TopAlbumsPercentage: self.TopAlbumsPercentage, LatestReleasePercentage: self.LatestReleasePercentage){
                flow.append(artistLayerChoice)
                if(artistLayerChoice == AuxrRecommendNode.similarArtists){
                  if let artistLayerChoice = initArtistLayer(SimilarArtistsPercentage: 0.0, TopSongsPercentage: 45.0, TopAlbumsPercentage: 50.0, LatestReleasePercentage: 5.0){
                    flow.append(artistLayerChoice)
                    if(artistLayerChoice == AuxrRecommendNode.topSongs){
                      flow.append(AuxrRecommendNode.song)
                    }
                    if(artistLayerChoice == AuxrRecommendNode.topAlbums){
                      if let albumLayerChoice = initAlbumLayer(RelatedAlbumsPercentage: 30.0, TrackPercentage: 70.0){
                        if(albumLayerChoice == AuxrRecommendNode.relatedAlbums){
                          flow.append(albumLayerChoice)
                          if let albumLayerChoice = initAlbumLayer(RelatedAlbumsPercentage: 30.0, TrackPercentage: 70.0){
                            if(albumLayerChoice == AuxrRecommendNode.track){
                              flow.append(albumLayerChoice)
                            }
                          }
                        }
                        if(albumLayerChoice == AuxrRecommendNode.track){
                          flow.append(albumLayerChoice)
                        }
                      }
                    }
                    if(artistLayerChoice == AuxrRecommendNode.latestRelease){
                      if let albumLayerChoice = initAlbumLayer(RelatedAlbumsPercentage: 30.0, TrackPercentage: 70.0){
                        if(albumLayerChoice == AuxrRecommendNode.track){
                          flow.append(albumLayerChoice)
                        }
                      }
                    }
                  }
                }
                if(artistLayerChoice == AuxrRecommendNode.topSongs){
                  flow.append(AuxrRecommendNode.song)
                }
                if(artistLayerChoice == AuxrRecommendNode.latestRelease){
                  if let albumLayerChoice = initAlbumLayer(RelatedAlbumsPercentage: 30.0, TrackPercentage: 70.0){
                    if(albumLayerChoice == AuxrRecommendNode.track){
                      flow.append(albumLayerChoice)
                    }
                  }
                }
              }
            }
            if(rootSongLayerChoice == AuxrRecommendNode.album){
              if let albumLayerChoice = initAlbumLayer(RelatedAlbumsPercentage: self.RelatedAlbumsPercentage, TrackPercentage: self.TrackPercentage){
                if(albumLayerChoice == AuxrRecommendNode.relatedAlbums){
                  if let albumLayerChoice = initAlbumLayer(RelatedAlbumsPercentage: 30.0, TrackPercentage: 70.0){
                    flow.append(albumLayerChoice)
                  }
                }
                if(albumLayerChoice == AuxrRecommendNode.track){
                  flow.append(albumLayerChoice)
                }
              }
            }
          }
        }
        if(secondLayerChoice == AuxrRecommendNode.artist){
          if let artistLayerChoice = initArtistLayer(SimilarArtistsPercentage: self.SimilarArtistsPercentage, TopSongsPercentage: self.TopSongsPercentage, TopAlbumsPercentage: self.TopAlbumsPercentage, LatestReleasePercentage: self.LatestReleasePercentage){
            flow.append(artistLayerChoice)
            if(artistLayerChoice == AuxrRecommendNode.similarArtists){
              if let artistLayerChoice = initArtistLayer(SimilarArtistsPercentage: 0.0, TopSongsPercentage: 45.0, TopAlbumsPercentage: 50.0, LatestReleasePercentage: 5.0){
                flow.append(artistLayerChoice)
                if(artistLayerChoice == AuxrRecommendNode.topSongs){
                  flow.append(AuxrRecommendNode.song)
                }
                if(artistLayerChoice == AuxrRecommendNode.topAlbums){
                  if let albumLayerChoice = initAlbumLayer(RelatedAlbumsPercentage: 30.0, TrackPercentage: 70.0){
                    if(albumLayerChoice == AuxrRecommendNode.relatedAlbums){
                      flow.append(albumLayerChoice)
                      if let albumLayerChoice = initAlbumLayer(RelatedAlbumsPercentage: 30.0, TrackPercentage: 70.0){
                        if(albumLayerChoice == AuxrRecommendNode.track){
                          flow.append(albumLayerChoice)
                        }
                      }
                    }
                    if(albumLayerChoice == AuxrRecommendNode.track){
                      flow.append(albumLayerChoice)
                    }
                  }
                }
                if(artistLayerChoice == AuxrRecommendNode.latestRelease){
                  if let albumLayerChoice = initAlbumLayer(RelatedAlbumsPercentage: 0.0, TrackPercentage: 100.0){
                    if(albumLayerChoice == AuxrRecommendNode.track){
                      flow.append(albumLayerChoice)
                    }
                  }
                }
              }
            }
            if(artistLayerChoice == AuxrRecommendNode.topAlbums){
              if let albumLayerChoice = initAlbumLayer(RelatedAlbumsPercentage: 0.0, TrackPercentage: 70.0){
                if(albumLayerChoice == AuxrRecommendNode.relatedAlbums){
                  flow.append(albumLayerChoice)
                  if let albumLayerChoice = initAlbumLayer(RelatedAlbumsPercentage: 30.0, TrackPercentage: 70.0){
                    if(albumLayerChoice == AuxrRecommendNode.track){
                      flow.append(albumLayerChoice)
                    }
                  }
                }
                if(albumLayerChoice == AuxrRecommendNode.track){
                  flow.append(albumLayerChoice)
                }
              }
            }
            if(artistLayerChoice == AuxrRecommendNode.topSongs){
              flow.append(AuxrRecommendNode.song)
            }
            if(artistLayerChoice == AuxrRecommendNode.latestRelease){
              if let albumLayerChoice = initAlbumLayer(RelatedAlbumsPercentage: 30.0, TrackPercentage: 70.0){
                if(albumLayerChoice == AuxrRecommendNode.track){
                  flow.append(albumLayerChoice)
                }
              }
            }
          }
        }
      }
    }
    return flow
  }
  
  func initSimilarSongsFlow() -> [AuxrRecommendNode]{
    return [AuxrRecommendNode.similarSongs, AuxrRecommendNode.song, AuxrRecommendNode.album, AuxrRecommendNode.track]
  }
  
  @MainActor
  func Reset() async throws -> AuxrRecommend {
    self.GeneratingRandom = false
    self.GeneratingSimilar = false
    self.MostFrequentArtistNames = []
    self.MostFrequentAlbumNames = []
    self.MostFrequentArtists = []
    self.MostFrequentAlbums = []
    self.Songs = []
    self.SimilarSongs = []
    self.QueuePercentage = 0.0
    self.LibraryPercentage = 0.0
    self.HistoryPercentage = 0.0
    self.LikesPercentage = 0.0
    self.VotesPercentage = 0.0
    self.DefaultPercentage = 0.0
    return self
  }
}
