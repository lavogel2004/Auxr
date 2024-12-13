import SwiftUI
import MusicKit
import MediaPlayer
import StoreKit
import WebKit

enum AppleMusicSubscriptionStatus: String, CaseIterable, Identifiable {
  case active, notActive, notChecked, error
  var id: Self { self }
}

class UserPlaylist: Identifiable, Equatable, Comparable {
  init(){}
  
  @Published var ID = UUID().uuidString
  var Title: String = ""
  var PersistentID: MPMediaEntityPersistentID? = nil
  var AM_Songs: [String] = []
  var Artists: [String] = []
  var Albums: [String] = []
  var Art: MPMediaItemArtwork? = nil
  
  static func ==(LHS: UserPlaylist, RHS: UserPlaylist) -> Bool { return LHS.ID == RHS.ID }
  static func !=(LHS: UserPlaylist, RHS: UserPlaylist) -> Bool { return LHS.ID != RHS.ID }
  static func <(LHS: UserPlaylist, RHS: UserPlaylist) -> Bool { return LHS.Title < RHS.Title }
  static func >(LHS: UserPlaylist, RHS: UserPlaylist) -> Bool { return LHS.Title > RHS.Title }
}

class AppleMusic: ObservableObject {
  @Published var Authorized: MusicAuthorization.Status = .notDetermined
  @Published var Subscription: AppleMusicSubscriptionStatus = AppleMusicSubscriptionStatus.notChecked
  @Published var CheckedForSubscription: Bool = false
  @Published var UserMusicLibrary: MusicLibrary = MusicLibrary.shared
  @Published var UserLibraryPlaylists: [UserPlaylist] = []
  @Published var AccountLikes: [Song] = []
  var UserRecommended: AuxrRecommend = AuxrRecommend()
  @Published var SongSearchResult: MusicItemCollection<Song> = []
  @Published var AlbumSearchResult: MusicItemCollection<Album> = []
  @Published var ArtistSearchResult: MusicItemCollection<Artist> = []
  @Published var AlbumTracks: MusicItemCollection<Track> = []
  var BackgroundSongSearchResult: MusicItemCollection<Song> = []
  var BackgroundAlbumSearchResult: MusicItemCollection<Album> = []
  var BackgroundArtistSearchResult: MusicItemCollection<Artist> = []
  var BackgroundAlbumTracks: MusicItemCollection<Track> = []
  @Published var RecentSearches: [String] = []
  @Published var Queue: [Song] = []
  @Published var InRoomQueue: Bool = true
  @Published var ChannelCodes: [String] = ["TH9V","6Z2G"]
  
  let player: ApplicationMusicPlayer = ApplicationMusicPlayer.shared
  
  // MARK: Authorize 'Media & Apple Music' Access
  @MainActor
  func Authorize() async throws {
    switch(self.Authorized){
    case .notDetermined:
      let AuthorizationStatusRequest = await MusicAuthorization.request()
      UpdateAuthorizationStatus(with: AuthorizationStatusRequest)
    case .denied, .restricted:
      return
    default:
      fatalError("no button should be displayed for current authorization status: \(self.Authorized).")
    }
  }
  func UpdateAuthorizationStatus(with AuthorizationStatus: MusicAuthorization.Status){
    self.Authorized = AuthorizationStatus
  }
  
  // MARK: Check Apple Music Subscription
  @MainActor
  func CheckSubscription(completion: @escaping (Bool) -> Void){
    self.CheckedForSubscription = true
    let cloudServiceController = SKCloudServiceController()
    cloudServiceController.requestCapabilities { (capabilities, error) in
      if let error = error{
        print("Error checking subscription status: \(error.localizedDescription)")
        self.Subscription = AppleMusicSubscriptionStatus.error
        completion(false)
        return
      }
      if capabilities.contains(.musicCatalogPlayback){
        self.Subscription = AppleMusicSubscriptionStatus.active
        completion(true)
      }
      else{
        self.Subscription = AppleMusicSubscriptionStatus.notActive
        completion(false)
        if let url = URL(string: "music://music.apple.com/subscribe"){ UIApplication.shared.open(url) }
      }
    }
  }
  
  // MARK: Search Apple Muisc Catalog
  @MainActor
  func Search(Input: String, Filter: SearchFilter, Background: Bool) async throws {
    var req = MusicCatalogSearchRequest(term: Input, types: [Song.self, Album.self, Artist.self])
    if(!Background){ req.limit = 25 }
    else{ req.limit = 15 }
    do
    {
      let res = try await req.response()
      switch(Filter){
      case SearchFilter.songs:
        if(!Background){ self.SongSearchResult = res.songs }
        else{ self.BackgroundSongSearchResult = res.songs }
      case SearchFilter.albums:
        if(!Background){ self.AlbumSearchResult = res.albums }
        else{ self.BackgroundAlbumSearchResult = res.albums }
      case SearchFilter.artists:
        if(!Background){ self.ArtistSearchResult = res.artists }
        else{ self.BackgroundArtistSearchResult = res.artists }
      }
    }
    catch _ {}
  }
  
  // MARK: Retrieve Album Info
  @MainActor
  func GetAlbumTracks(Album: Album, Background: Bool) async throws {
    let album = try await Album.with([.artists, .tracks])
    if(!Background){ self.AlbumTracks = album.tracks ?? [] }
    else{ self.BackgroundAlbumTracks = album.tracks ?? [] }
  }
  
  // MARK: Convert Auxr Song into MusicKit.Song
  func ConvertSong(AuxrSong: AuxrSong) async throws -> Song? {
    do
    {
      let req = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(rawValue: AuxrSong.AppleMusic))
      let res = try await req.response()
      if let res_song = res.items.first{ return res_song }
    }
    catch _ {}
    return nil
  }
  
  // MARK: Convert Playback Store Song ID into MusicKit.Song
  func ConvertSongID(SongID: String) async throws -> Song? {
    do
    {
      let req = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(rawValue: SongID))
      let res = try await req.response()
      if let res_song = res.items.first{ return res_song }
    }
    catch _ {}
    return nil
  }
  
  // MARK: Convert Artist Name into MusicKit.Artist
  func ConvertArtistID(ArtistID: String) async throws -> Artist? {
    do
    {
      let req = MusicCatalogResourceRequest<Artist>(matching: \.id, equalTo: MusicItemID(rawValue: ArtistID))
      let res = try await req.response()
      if let res_artist = res.items.first{ return res_artist }
      return nil
    }
    catch _ {}
    return nil
  }
  
  // MARK: Update Player Queue to Room Queue
  @MainActor
  func PlayerUpdateQueue(Room: Room) async throws {
    do
    {
      self.player.queue.entries = []
      self.Queue = []
      var queueSize = 2
      for song in Room.Playlist.Queue.sorted(){
        guard let AM_Song = try await self.ConvertSong(AuxrSong: song)
        else{ return }
        self.Queue.append(AM_Song)
        if(queueSize > 0){ queueSize -= 1 }
        else{ break }
      }
      
      self.player.queue = ApplicationMusicPlayer.Queue(for: self.Queue, startingAt: self.Queue.first)
      self.player.state.repeatMode = MusicPlayer.RepeatMode.none
    }
    catch _ {}
  }
  
  // MARK: Initialize Player
  @MainActor
  func PlayerInit(Room: Room) async throws {
    do
    {
      try await self.PlayerUpdateQueue(Room: Room)
      try await self.player.prepareToPlay()
      try await self.player.play()
      
      if(!Room.Playlist.Queue.isEmpty){
        Room.Playlist.History.append(Room.Playlist.Queue.sorted()[0])
        try await FirebaseManager.AddSongToPlaylistHistory(Room: Room, AuxrSong: Room.Playlist.Queue.sorted()[0])
      }
      Room.Playlist.QueueInitializing = false
      try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: Room)
    }
  }
  
  // MARK: Player Play Handler
  @MainActor
  func PlayerPlay() async throws {
    do
    {
      try await self.player.prepareToPlay()
      try await self.player.play()
    }
    catch _ {}
  }
  
  // MARK: Player Pause Handler
  @MainActor
  func PlayerPause() async throws {
    do
    {
      self.player.pause()
    }
  }
  
  // MARK: Player Skip Handler
  @MainActor
  func PlayerSkip(Room: Room) async throws {
    do
    {
      if(!Room.Playlist.QueueInitializing){
        if(Room.Playlist.Queue.count > 1){
          Room.Playlist.QueueInitializing = true
          try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: Room)
          let currSong = Room.Playlist.Queue.sorted()[0]
          try await FirebaseManager.RemoveSongFromPlaylistQueue(Room: Room, AuxrSong: currSong)
          try await self.PlayerUpdateQueue(Room: Room)
          if(!Room.PlaySong){
            Room.PlaySong = true
            try await FirebaseManager.UpdateRoomPlaySong(Room: Room)
          }
          try await self.player.prepareToPlay()
          try await self.player.play()
          if(!Room.Playlist.Queue.isEmpty){
            Room.Playlist.History.append(Room.Playlist.Queue.sorted()[0])
            try await FirebaseManager.AddSongToPlaylistHistory(Room: Room, AuxrSong: Room.Playlist.Queue.sorted()[0])
          }
          if(Room.SkipSong){
            Room.SkipSong = false
            try await FirebaseManager.UpdateRoomSkipSong(Room: Room)
            if(Room.Controlled){
              Room.Controlled = false
              try await FirebaseManager.UpdateRoomControlled(Room: Room)
            }
          }
          Room.Playlist.TotalPlaytime = Room.Playlist.QueueTotalPlaytime(Room: Room)
          try await FirebaseManager.UpdatePlaylistTotalPlaytime(Room: Room)
          Room.Playlist.QueueInitializing = false
          try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: Room)
        }
      }
    }
    catch _ {}
  }
  
  // MARK: Remote Command Center Handler
  @MainActor
  func RemoteCommandCenterState(Room: Room) async throws {
    if(!Room.Playlist.QueueInitializing){
      let networkStatus: NetworkStatus = CheckNetworkStatus()
      if(networkStatus == NetworkStatus.reachable){
        if(self.player.state.playbackStatus == .paused){
          Room.PlaySong = false
          try await FirebaseManager.UpdateRoomPlaySong(Room: Room)
          Room.Controlled = false
          try await FirebaseManager.UpdateRoomControlled(Room: Room)
        }
        if(self.player.state.playbackStatus == .playing){
          Room.PlaySong = true
          try await FirebaseManager.UpdateRoomPlaySong(Room: Room)
          Room.Controlled = false
          try await FirebaseManager.UpdateRoomControlled(Room: Room)
        }
      }
    }
  }
  
  // MARK: Queue Control
  @MainActor
  func QueueControl(Room: Room) async throws {
    Room.Playlist.TotalPlaytime = Room.Playlist.QueueTotalPlaytime(Room: Room)
    try await FirebaseManager.UpdatePlaylistTotalPlaytime(Room: Room)
    if(!self.player.queue.entries.isEmpty &&
       !Room.Controlled &&
       !Room.Playlist.QueueInitializing &&
       !Room.Playlist.Queue.isEmpty &&
       !Room.UpNext &&
       !Room.InFirstTime){
      if(self.player.queue.entries.count == 1 && Room.Playlist.Queue.count > 1){
        Room.Playlist.QueueInitializing = true
        try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: Room)
        var QueuedSongs: [Song] = []
        var queueSize = 2
        for song in Room.Playlist.Queue.sorted(){
          if song == Room.Playlist.Queue.sorted()[0]{ continue }
          else{
            guard let AM_Song = try await self.ConvertSong(AuxrSong: song) else{ return }
            QueuedSongs.append(AM_Song)
          }
          if(queueSize > 0){ queueSize -= 1 }
          else{ break }
        }
        try await self.player.queue.insert(QueuedSongs, position: .afterCurrentEntry)
        self.player.state.repeatMode = MusicPlayer.RepeatMode.none
        Room.Playlist.QueueInitializing = false
        try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: Room)
      }
      self.InRoomQueue = Room.Playlist.Queue.sorted().prefix(2).contains(where: { $0.AppleMusic == self.player.queue.currentEntry?.item?.id.rawValue })
      if(self.InRoomQueue){
        if(self.player.queue.entries.count > 1 && Room.Playlist.Queue.count > 1){
          if(self.player.queue.currentEntry?.item?.id.rawValue != Room.Playlist.Queue.sorted()[0].AppleMusic){
            Room.Controlled = true
            try await FirebaseManager.UpdateRoomControlled(Room: Room)
            Room.Playlist.QueueInitializing = true
            try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: Room)
            let currSong = Room.Playlist.Queue.sorted()[0]
            try await FirebaseManager.RemoveSongFromPlaylistQueue(Room: Room, AuxrSong: currSong)
            self.player.queue.entries.removeFirst()
            Room.Playlist.QueueInitializing = false
            try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: Room)
            Room.Controlled = false
            try await FirebaseManager.UpdateRoomControlled(Room: Room)
          }
          else{
            if(self.player.queue.currentEntry == self.player.queue.entries[1]){
              Room.Controlled = true
              try await FirebaseManager.UpdateRoomControlled(Room: Room)
              Room.Playlist.QueueInitializing = true
              try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: Room)
              let currSong = Room.Playlist.Queue.sorted()[0]
              try await FirebaseManager.RemoveSongFromPlaylistQueue(Room: Room, AuxrSong: currSong)
              self.player.queue.entries.removeFirst()
              Room.Playlist.QueueInitializing = false
              try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: Room)
              Room.Controlled = false
              try await FirebaseManager.UpdateRoomControlled(Room: Room)
            }
          }
        }
      }
      else{
        if(Room.Playlist.Queue.count > 1){
          if(self.player.queue.currentEntry?.item?.id.rawValue != Room.Playlist.Queue.sorted()[0].AppleMusic){
            Room.Controlled = true
            try await FirebaseManager.UpdateRoomControlled(Room: Room)
            Room.Playlist.QueueInitializing = true
            try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: Room)
            let currSong = Room.Playlist.Queue.sorted()[0]
            try await FirebaseManager.RemoveSongFromPlaylistQueue(Room: Room, AuxrSong: currSong)
            try await self.PlayerInit(Room: Room)
            Room.Controlled = false
            try await FirebaseManager.UpdateRoomControlled(Room: Room)
          }
          else{
            if(self.player.queue.currentEntry == self.player.queue.entries[1]){
              Room.Controlled = true
              try await FirebaseManager.UpdateRoomControlled(Room: Room)
              Room.Playlist.QueueInitializing = true
              try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: Room)
              let currSong = Room.Playlist.Queue.sorted()[0]
              try await FirebaseManager.RemoveSongFromPlaylistQueue(Room: Room, AuxrSong: currSong)
              try await self.PlayerInit(Room: Room)
              Room.Controlled = false
              try await FirebaseManager.UpdateRoomControlled(Room: Room)
            }
          }
        }
        else{
          Room.Controlled = true
          try await FirebaseManager.UpdateRoomControlled(Room: Room)
          Room.Playlist.QueueInitializing = true
          try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: Room)
          try await self.PlayerInit(Room: Room)
          Room.Controlled = false
          try await FirebaseManager.UpdateRoomControlled(Room: Room)
        }
      }
    }
  }
  
  // MARK: Background Fetch For Player Queue
  @MainActor
  func BackgroundTaskFetch(Room: Room) async throws {
    if(self.player.queue.entries.count == 1 &&
       Room.Playlist.Queue.count > 1 &&
       !Room.Playlist.QueueInitializing){
      let networkStatus: NetworkStatus = CheckNetworkStatus()
      if(networkStatus == NetworkStatus.reachable){
        Room.Playlist.QueueInitializing = true
        try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: Room)
        var QueuedSongs: [Song] = []
        var queueSize = 2
        for song in Room.Playlist.Queue.sorted(){
          if song == Room.Playlist.Queue.sorted()[0]{ continue }
          else{
            guard let AM_Song = try await self.ConvertSong(AuxrSong: song)
            else{ return }
            QueuedSongs.append(AM_Song)
          }
          if(queueSize > 0){ queueSize -= 1 }
          else{ break }
        }
        try await self.player.queue.insert(QueuedSongs, position: .afterCurrentEntry)
        self.player.state.repeatMode = MusicPlayer.RepeatMode.none
        Room.Playlist.QueueInitializing = false
        try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: Room)
      }
    }
  }
  
  // MARK: Create Playlist From User Likes In Room
  @MainActor
  func AddLikeSongsToPlaylistFromRoom(User: User, Room: Room) async throws {
    var LikeSongs: [Song] = []
    for song in User.Likes.sorted(){
      guard let AM_Song = try await self.ConvertSong(AuxrSong: song)
      else{ return }
      LikeSongs.append(AM_Song)
    }
    
    let UserPlaylistName = Room.Name
    try await self.UserMusicLibrary.createPlaylist(name: UserPlaylistName, items: LikeSongs)
  }
  
  // MARK: Create Playlist From User Likes In Account
  @MainActor
  func AddLikeSongsToPlaylistFromAccount(User: User, Account: AuxrAccount) async throws {
    var LikeSongs: [Song] = []
    for song in Account.Likes.sorted(){
      guard let AM_Song = try await self.ConvertSong(AuxrSong: song)
      else{ return }
      LikeSongs.append(AM_Song)
    }
    
    let UserPlaylistName = Account.Username + " Likes"
    try await self.UserMusicLibrary.createPlaylist(name: UserPlaylistName, items: LikeSongs)
  }
  
  // MARK: Retrieve User Playlists From Library
  @MainActor
  func GetUserPlaylists() async throws {
    let UserPlaylistQuery = MPMediaQuery.playlists()
    if let UserPlaylists = UserPlaylistQuery.collections{
      for Playlist in UserPlaylists{
        let UserLibraryPlaylist = UserPlaylist()
        if(Playlist.mediaTypes == .music){
          if Playlist.value(forKey: MPMediaItemPropertyPersistentID) != nil{
            if(!Playlist.items.isEmpty){
              for song in Playlist.items {
                if(song.mediaType == .music){
                  UserLibraryPlaylist.AM_Songs.append(song.playbackStoreID)
                  UserLibraryPlaylist.Artists.append(song.artist ?? "")
                  UserLibraryPlaylist.Albums.append(song.albumTitle ?? "")
                }
              }
            }
            if(!UserLibraryPlaylist.AM_Songs.isEmpty){
              if let PlaylistName = Playlist.value(forKey: MPMediaPlaylistPropertyName) as? String { UserLibraryPlaylist.Title = PlaylistName }
              else{ UserLibraryPlaylist.Title = "No Name" }
              UserLibraryPlaylist.PersistentID = Playlist.persistentID
              UserLibraryPlaylist.Art = Playlist.representativeItem?.artwork
              self.UserLibraryPlaylists.append(UserLibraryPlaylist)
            }
          }
        }
      }
    }
  }
  
  @MainActor
  func GetAccountLikes(User: User) async throws {
    if let account: AuxrAccount = User.Account{
      for song in account.Likes.sorted(){
        if let am_song = try await self.ConvertSong(AuxrSong: song){
          if(!self.AccountLikes.contains(am_song)){ self.AccountLikes.append(am_song) }
        }
      }
    }
  }
  
  // MARK: Get Most Frequent Song Data
  func GetMostMusicDataFrequentFromUserPlaylists(){
    self.UserRecommended.MostFrequentArtistNames = []
    let PlaylistsRankedBySongCount = self.UserLibraryPlaylists.sorted{ $0.AM_Songs.count > $1.AM_Songs.count }
    for i in 0..<self.UserLibraryPlaylists.count{ self.UserRecommended.MostFrequentArtistNames.append(contentsOf: MostFrequentString(A: PlaylistsRankedBySongCount[i].Artists, howMany: 1000)) }
    self.UserRecommended.MostFrequentArtistNames = Array(Set(self.UserRecommended.MostFrequentArtistNames))
  }
  func GetMostFrequentMusicDataFromRoomQueue(Room: Room){
    self.UserRecommended.MostFrequentArtistNames = []
    var ArtistCount: [String] = []
    for song in Room.Playlist.Queue.sorted(){ ArtistCount.append(song.Artist) }
    self.UserRecommended.MostFrequentArtistNames.append(contentsOf: MostFrequentString(A: ArtistCount, howMany: 5))
    self.UserRecommended.MostFrequentArtistNames = Array(Set(self.UserRecommended.MostFrequentArtistNames))
  }
  func GetMostFrequentMusicDataFromRoomHistory(Room: Room){
    self.UserRecommended.MostFrequentArtistNames = []
    var ArtistCount: [String] = []
    for song in Room.Playlist.History.sorted(){ ArtistCount.append(song.Artist) }
    self.UserRecommended.MostFrequentArtistNames.append(contentsOf: MostFrequentString(A: ArtistCount, howMany: 100))
    self.UserRecommended.MostFrequentArtistNames = Array(Set(self.UserRecommended.MostFrequentArtistNames))
  }
  func GetMostFrequentMusicDataFromUserLikes(User: User, Room: Room){
    self.UserRecommended.MostFrequentArtistNames = []
    var ArtistCount: [String] = []
    for song in User.Likes.sorted(){ ArtistCount.append(song.Artist) }
    self.UserRecommended.MostFrequentArtistNames.append(contentsOf: MostFrequentString(A: ArtistCount, howMany: 3))
    self.UserRecommended.MostFrequentArtistNames = Array(Set(self.UserRecommended.MostFrequentArtistNames))
  }
  func GetMostFrequentMusicDataFromUserVotes(User: User, Room: Room){
    self.UserRecommended.MostFrequentArtistNames = []
    var ArtistCount: [String] = []
    for song in User.Votes.sorted(){ ArtistCount.append(song.Artist) }
    self.UserRecommended.MostFrequentArtistNames.append(contentsOf: MostFrequentString(A: ArtistCount, howMany: 10))
    self.UserRecommended.MostFrequentArtistNames = Array(Set(self.UserRecommended.MostFrequentArtistNames))
  }
  
  // MARK: Generate Flow Entry Point Percentages
  func GetFlowEntryPointPercentages(User: User, Room: Room){
    if(Room.Playlist.Queue.isEmpty){
      if(self.Subscription == AppleMusicSubscriptionStatus.active){
        if(!self.UserLibraryPlaylists.isEmpty){ self.UserRecommended.LibraryPercentage = 100.0 }
        else{ self.UserRecommended.DefaultPercentage = 100.0 }
      }
      else{ self.UserRecommended.DefaultPercentage = 100.0 }
    }
    
    if(Room.Playlist.Queue.count > 0 && Room.Playlist.Queue.count <= 3){
      self.UserRecommended.QueuePercentage = 70.0
      if(self.Subscription == AppleMusicSubscriptionStatus.active){
        if(!self.UserLibraryPlaylists.isEmpty){ self.UserRecommended.LibraryPercentage = 15.0 }
      }
      if(!Room.Playlist.History.isEmpty){ self.UserRecommended.HistoryPercentage = 5.0 }
      if(!User.Likes.isEmpty){ self.UserRecommended.LikesPercentage = 5.0 }
      if(!User.Votes.isEmpty){ self.UserRecommended.VotesPercentage = 5.0 }
    }
    
    if(Room.Playlist.Queue.count > 3 && Room.Playlist.Queue.count <= 5){
      self.UserRecommended.QueuePercentage = 75.0
      if(self.Subscription == AppleMusicSubscriptionStatus.active){
        if(!self.UserLibraryPlaylists.isEmpty){ self.UserRecommended.LibraryPercentage = 10.0 }
      }
      if(!Room.Playlist.History.isEmpty){ self.UserRecommended.HistoryPercentage = 5.0 }
      if(!User.Likes.isEmpty){ self.UserRecommended.LikesPercentage = 5.0 }
      if(!User.Votes.isEmpty){ self.UserRecommended.VotesPercentage = 5.0 }
    }
    
    if(!Room.Playlist.Queue.isEmpty){
      let percentageTotal = self.UserRecommended.QueuePercentage +
      self.UserRecommended.LibraryPercentage +
      self.UserRecommended.HistoryPercentage +
      self.UserRecommended.LikesPercentage +
      self.UserRecommended.VotesPercentage
      if(percentageTotal < 100.0){ self.UserRecommended.QueuePercentage += (100.0 - percentageTotal) }
    }
  }
  func GetRerunFlowEntryPointPercentages(User: User, Room: Room){
    if(Room.Playlist.Queue.isEmpty){
      if(self.Subscription == AppleMusicSubscriptionStatus.active){
        if(!self.UserLibraryPlaylists.isEmpty){ self.UserRecommended.LibraryPercentage = 100.0 }
        else{
          self.UserRecommended.TopSongsPercentage = 45.0
          self.UserRecommended.TopAlbumsPercentage = 55.0
        }
      }
      else{
        self.UserRecommended.TopSongsPercentage = 45.0
        self.UserRecommended.TopAlbumsPercentage = 55.0
      }
    }
    
    if(Room.Playlist.Queue.count > 0 && Room.Playlist.Queue.count <= 3){
      self.UserRecommended.QueuePercentage = 70.0
      if(self.Subscription == AppleMusicSubscriptionStatus.active){
        if(!self.UserLibraryPlaylists.isEmpty){ self.UserRecommended.LibraryPercentage = 15.0 }
      }
      if(!Room.Playlist.History.isEmpty){ self.UserRecommended.HistoryPercentage = 5.0 }
      if(!User.Likes.isEmpty){ self.UserRecommended.LikesPercentage = 5.0 }
      if(!User.Votes.isEmpty){ self.UserRecommended.VotesPercentage = 5.0 }
      self.UserRecommended.TopSongsPercentage = 0.0
      self.UserRecommended.TopAlbumsPercentage = 0.0
    }
    
    if(Room.Playlist.Queue.count > 3 && Room.Playlist.Queue.count <= 5){
      self.UserRecommended.QueuePercentage = 75.0
      if(self.Subscription == AppleMusicSubscriptionStatus.active){
        if(!self.UserLibraryPlaylists.isEmpty){ self.UserRecommended.LibraryPercentage = 10.0 }
      }
      if(!Room.Playlist.History.isEmpty){ self.UserRecommended.HistoryPercentage = 5.0 }
      if(!User.Likes.isEmpty){ self.UserRecommended.LikesPercentage = 5.0 }
      if(!User.Votes.isEmpty){ self.UserRecommended.VotesPercentage = 5.0 }
      self.UserRecommended.TopSongsPercentage = 0.0
      self.UserRecommended.TopAlbumsPercentage = 0.0
    }
    
    if(Room.Playlist.Queue.count > 5){
      self.UserRecommended.QueuePercentage = 85.0
      if(self.Subscription == AppleMusicSubscriptionStatus.active){
        if(!self.UserLibraryPlaylists.isEmpty){ self.UserRecommended.LibraryPercentage = 5.0 }
      }
      if(!Room.Playlist.History.isEmpty){ self.UserRecommended.HistoryPercentage = 2.5 }
      if(!User.Likes.isEmpty){ self.UserRecommended.LikesPercentage = 5.0 }
      if(!User.Votes.isEmpty){ self.UserRecommended.VotesPercentage = 2.5 }
      self.UserRecommended.TopSongsPercentage = 0.0
      self.UserRecommended.TopAlbumsPercentage = 0.0
    }
    
    if(!Room.Playlist.Queue.isEmpty){
      let percentageTotal = self.UserRecommended.QueuePercentage +
      self.UserRecommended.LibraryPercentage +
      self.UserRecommended.HistoryPercentage +
      self.UserRecommended.LikesPercentage +
      self.UserRecommended.VotesPercentage
      if(percentageTotal < 100.0){ self.UserRecommended.QueuePercentage += (100.0 - percentageTotal) }
    }
  }
  
  // MARK: Generate Random Songs
  func GenerateRandomSongs(User: User, Room: Room, howMany: Int) async throws {
    guard (self.UserRecommended.GeneratingRandom) else{ return }
    self.UserRecommended.QueuePercentage = 0.0
    self.UserRecommended.LibraryPercentage = 0.0
    self.UserRecommended.HistoryPercentage = 0.0
    self.UserRecommended.LikesPercentage = 0.0
    self.UserRecommended.VotesPercentage = 0.0
    self.UserRecommended.DefaultPercentage = 0.0
    if(self.UserRecommended.Songs.count < howMany){
      self.GetFlowEntryPointPercentages(User: User, Room: Room)
      let flow = self.UserRecommended.initLayerFlow()
      var topChartsRequest = MusicCatalogChartsRequest(types: [Song.self, Album.self])
      topChartsRequest.limit = 25
      let topChartsResponse = try await topChartsRequest.response()
      let topSongs = topChartsResponse.songCharts
      let topSongsBound = topSongs[0].items.count
      let randSongIndex = ((topSongsBound > 1) ? Int.random(in: 0...topSongsBound-1) : 0)
      let randSong = topSongs[0].items[randSongIndex]
      let defaultSong = try await self.ConvertSongID(SongID: randSong.id.rawValue)
      self.UserRecommended.MostFrequentArtistNames.append(ParseArtistName(input: randSong.artistName, getFirst: false) ?? "")
      if let songID = try await self.ConvertRecommendedFlowToSongID(defaultSong: defaultSong, User: User, Room: Room, Flow: flow){
        if let am_song = try await self.ConvertSongID(SongID: songID){
          let contains =
          (
            self.UserRecommended.Songs.contains(where: { ($0 == am_song) || ($0.title == am_song.title) }) ||
            Room.Playlist.Queue.contains(where: { ($0.AppleMusic == songID) || ($0.Title == am_song.title) }) ||
            Room.Playlist.History.contains(where: { ($0.AppleMusic == songID) || ($0.Title == am_song.title) }) ||
            User.Likes.contains(where: { ($0.AppleMusic == songID) || ($0.Title == am_song.title) }) ||
            User.Votes.contains(where: { ($0.AppleMusic == songID) || ($0.Title == am_song.title) })
          )
          if(!contains){ self.UserRecommended.Songs.append(am_song) }
        }
      }
      guard (self.UserRecommended.GeneratingRandom) else{ return }
      try await self.GenerateRandomSongs(User: User, Room: Room, howMany: 3)
    }
    else{ self.UserRecommended.GeneratingRandom = false }
  }
  
  // MARK: Generate Similar Songs
  func GenerateSimilarSongs(User: User, Room: Room, howMany: Int, attempts: Int, SelectedSong: Song?) async throws {
    guard (self.UserRecommended.GeneratingSimilar) else{ return }
    if(attempts > 0){
      let newAttempts = attempts - 1
      if(self.UserRecommended.SimilarSongs.count < howMany){
        self.GetFlowEntryPointPercentages(User: User, Room: Room)
        let flow = self.UserRecommended.initSimilarSongsFlow()
        if let songID = try await self.ConvertRecommendedFlowToSongID(defaultSong: SelectedSong, User: User, Room: Room, Flow: flow){
          if let am_song = try await self.ConvertSongID(SongID: songID){
            let contains =
            (
              self.UserRecommended.SimilarSongs.contains(where: { ($0 == am_song) || ($0.title == am_song.title) }) ||
              Room.Playlist.Queue.contains(where: { ($0.AppleMusic == songID) || ($0.Title == am_song.title) })
            )
            if(!contains){ self.UserRecommended.SimilarSongs.append(am_song) }
          }
        }
        guard (self.UserRecommended.GeneratingSimilar) else{ return }
        try await self.GenerateSimilarSongs(User: User, Room: Room, howMany: howMany, attempts: newAttempts, SelectedSong: SelectedSong)
      }
      else{
        self.UserRecommended.GeneratingSimilar = false
      }
    }
    else{
      self.UserRecommended.GeneratingSimilar = false
    }
  }
  
  // MARK: Convert Recommended Flow To Song ID
  func ConvertRecommendedFlowToSongID(defaultSong: Song?, User: User, Room: Room, Flow: [AuxrRecommendNode]) async throws -> String? {
    if(self.UserRecommended.GeneratingRandom ||
       self.UserRecommended.GeneratingSimilar ||
       (User.Account == nil)){
      var song = defaultSong
      // FIRST LAYER: Entry Point
      let entryPoint = Flow[0]
      if(entryPoint == AuxrRecommendNode.library){
        self.self.GetMostMusicDataFrequentFromUserPlaylists()
        var bound = self.UserLibraryPlaylists.count
        let randPlaylistIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
        let playlist = self.UserLibraryPlaylists[randPlaylistIndex]
        bound = playlist.AM_Songs.count
        let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
        let selectedSong = playlist.AM_Songs[randSongIndex]
        song = try await self.ConvertSongID(SongID: selectedSong)
      }
      else if(entryPoint == AuxrRecommendNode.queue){
        self.GetMostFrequentMusicDataFromRoomQueue(Room: Room)
        let bound = Room.Playlist.Queue.count
        let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
        let selectedSong = Room.Playlist.Queue.sorted()[randSongIndex]
        song = try await self.ConvertSong(AuxrSong: selectedSong)
      }
      else if(entryPoint == AuxrRecommendNode.history){
        self.GetMostFrequentMusicDataFromRoomHistory(Room: Room)
        let bound = Room.Playlist.History.count
        let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
        let selectedSong = Room.Playlist.History.sorted()[randSongIndex]
        song = try await self.ConvertSong(AuxrSong: selectedSong)
      }
      else if(entryPoint == AuxrRecommendNode.likes){
        self.GetMostFrequentMusicDataFromUserLikes(User: User, Room: Room)
        let bound = User.Likes.count
        let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
        let selectedSong = User.Likes.sorted()[randSongIndex]
        song = try await self.ConvertSong(AuxrSong: selectedSong)
      }
      else if(entryPoint == AuxrRecommendNode.votes){
        self.GetMostFrequentMusicDataFromUserVotes(User: User, Room: Room)
        let bound = User.Votes.count
        let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
        let selectedSong = User.Votes.sorted()[randSongIndex]
        song = try await self.ConvertSong(AuxrSong: selectedSong)
      }
      else if(entryPoint == AuxrRecommendNode.similarSongs){
        self.UserRecommended.MostFrequentAlbumNames = []
        self.UserRecommended.MostFrequentArtistNames.append(ParseArtistName(input: defaultSong?.artistName ?? "", getFirst: false) ?? "")
      }
      else if(entryPoint == AuxrRecommendNode.rerun){
        self.UserRecommended.MostFrequentArtistNames.append(ParseArtistName(input: defaultSong?.artistName ?? "", getFirst: false) ?? "")
      }
      else{
        self.UserRecommended.MostFrequentArtistNames = []
        self.UserRecommended.MostFrequentArtistNames.append(ParseArtistName(input: defaultSong?.artistName ?? "", getFirst: false) ?? "")
      }
      
      let secondLayer = Flow[1]
      // SECOND LAYER: song
      if(secondLayer == AuxrRecommendNode.song){
        // THIRD LAYER (song): artist
        if(Flow[2] == AuxrRecommendNode.artist){
          if let artistName = ParseArtistName(input: song?.artistName ?? "", getFirst: false){
            self.BackgroundSongSearchResult = []
            self.BackgroundAlbumSearchResult = []
            self.BackgroundArtistSearchResult = []
            try await self.Search(Input: artistName, Filter: SearchFilter.artists, Background: true)
            if let artistID = self.BackgroundArtistSearchResult.first?.id.rawValue{
              let artist = try await self.ConvertArtistID(ArtistID: artistID)
              // FOURTH LAYER (song/artist): similarArtists
              if(Flow[3] == AuxrRecommendNode.similarArtists){
                if let similarArtists = artist?.similarArtists{
                  let artistsBound = similarArtists.count
                  let randArtistIndex = ((artistsBound > 1) ? Int.random(in: 0...artistsBound-1) : 0)
                  let randSimilarArtist = similarArtists[randArtistIndex]
                  // FOURTH LAYER (song/artist/similarArtist): topSongs
                  if(Flow[4] == AuxrRecommendNode.topSongs){
                    self.BackgroundSongSearchResult = []
                    self.BackgroundAlbumSearchResult = []
                    self.BackgroundArtistSearchResult = []
                    try await self.Search(Input: ParseArtistName(input: randSimilarArtist.name, getFirst: false) ?? "", Filter: SearchFilter.songs, Background: true)
                    if(!self.BackgroundSongSearchResult.isEmpty){
                      var sameGenreSongs: [Song] = []
                      if let genre = randSimilarArtist.genreNames?.filter({ $0 != "Music"}).first{
                        for song in self.BackgroundSongSearchResult{ if(song.genreNames.contains(genre)){ sameGenreSongs.append(song)} }
                        if(!sameGenreSongs.isEmpty){
                          let songsBound = sameGenreSongs.count
                          let randSongIndex = ((songsBound > 1) ? Int.random(in: 0...songsBound-1) : 0)
                          let randSong = sameGenreSongs[randSongIndex]
                          return randSong.id.rawValue
                        }
                        else{
                          // FOURTH LAYER (song/artist/similarArtist): topSongs [no genre]
                          let songsBound = self.BackgroundSongSearchResult.count
                          let randSongIndex = ((songsBound > 1) ? Int.random(in: 0...songsBound-1) : 0)
                          let randSong = self.BackgroundSongSearchResult[randSongIndex]
                          return randSong.id.rawValue
                        }
                      }
                    }
                  }
                  // FOURTH LAYER (song/artist/similarArtist): topAlbums
                  else if(Flow[4] == AuxrRecommendNode.topAlbums){
                    self.BackgroundSongSearchResult = []
                    self.BackgroundAlbumSearchResult = []
                    self.BackgroundArtistSearchResult = []
                    try await self.Search(Input: ParseArtistName(input: randSimilarArtist.name, getFirst: false) ?? "", Filter: SearchFilter.albums, Background: true)
                    if(!self.BackgroundAlbumSearchResult.isEmpty){
                      var sameGenreAlbums: [Album] = []
                      let genre = artist?.genreNames?.filter({ $0 != "Music" }).first ?? "Music"
                      for album in self.BackgroundAlbumSearchResult{ if(album.genreNames.contains(genre)){ sameGenreAlbums.append(album)} }
                      if(!sameGenreAlbums.isEmpty){
                        self.BackgroundSongSearchResult = []
                        self.BackgroundAlbumSearchResult = []
                        self.BackgroundArtistSearchResult = []
                        let topAlbumsBound = sameGenreAlbums.count
                        let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                        let randAlbum = sameGenreAlbums[randAlbumIndex]
                        self.BackgroundAlbumTracks = []
                        try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                        let albumTracks = self.BackgroundAlbumTracks
                        let tracksBound = albumTracks.count
                        let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                        let randTrack = albumTracks[randTrackIndex]
                        return randTrack.id.rawValue
                      }
                      else{
                        let albumsCount = self.BackgroundAlbumSearchResult.count
                        let randAlbumIndex = ((albumsCount > 1) ? Int.random(in: 0...albumsCount-1) : 0)
                        let randAlbum = self.BackgroundAlbumSearchResult[randAlbumIndex]
                        self.BackgroundAlbumTracks = []
                        try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                        let albumTracks = self.BackgroundAlbumTracks
                        let tracksBound = albumTracks.count
                        let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                        let randTrack = albumTracks[randTrackIndex]
                        return randTrack.id.rawValue
                      }
                    }
                  }
                  // FOURTH LAYER (song/artist/similarArtist): latestRelease
                  else if(Flow[4] == AuxrRecommendNode.latestRelease){
                    if let latestRelease = randSimilarArtist.latestRelease{
                      try await self.GetAlbumTracks(Album: latestRelease, Background: true)
                      self.BackgroundAlbumTracks = []
                      let albumTracks = self.BackgroundAlbumTracks
                      let tracksBound = albumTracks.count
                      let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                      let randTrack = albumTracks[randTrackIndex]
                      return randTrack.id.rawValue
                    }
                  }
                  else{
                    // FOURTH LAYER (song/artist/similarArtist): rerun [default]
                    if let genre = song?.genreNames.filter({ $0 != "Music" }).first{
                      var defaultChoice = self.UserRecommended.initDefaultLayer(QueuePercentage: 0.0, LibraryPercentage: 0.0, HistoryPercentage: 0.0, LikesPercentage: 0.0, VotesPercentage: 0.0, TopSongsPercentage: 45.0, TopAlbumsPercentage: 55.0)
                      if(entryPoint != AuxrRecommendNode.rerun){
                        if(entryPoint == AuxrRecommendNode.similarSongs){
                          return try await self.ConvertRecommendedFlowToSongID(defaultSong: defaultSong, User: User, Room: Room, Flow: Flow)
                        }
                        self.GetRerunFlowEntryPointPercentages(User: User, Room: Room)
                        defaultChoice = self.UserRecommended.initDefaultLayer(QueuePercentage: self.UserRecommended.QueuePercentage, LibraryPercentage: self.UserRecommended.LibraryPercentage, HistoryPercentage: self.UserRecommended.HistoryPercentage, LikesPercentage: self.UserRecommended.LikesPercentage, VotesPercentage: self.UserRecommended.VotesPercentage, TopSongsPercentage: self.UserRecommended.TopSongsPercentage, TopAlbumsPercentage: self.UserRecommended.TopAlbumsPercentage)
                      }
                      // FOURTH LAYER (song/artist/similarArtist): library [rerun]
                      if(defaultChoice == AuxrRecommendNode.library){
                        self.GetMostMusicDataFrequentFromUserPlaylists()
                        var bound = self.UserLibraryPlaylists.count
                        let randPlaylistIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                        let playlist = self.UserLibraryPlaylists[randPlaylistIndex]
                        bound = playlist.AM_Songs.count
                        let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                        let selectedSong = playlist.AM_Songs[randSongIndex]
                        let am_song = try await self.ConvertSongID(SongID: selectedSong)
                        var rerunFlow = Flow
                        rerunFlow[0] = .rerun
                        return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                      }
                      // FOURTH LAYER (song/artist/similarArtist): queue [rerun]
                      if(defaultChoice == AuxrRecommendNode.queue){
                        self.GetMostFrequentMusicDataFromRoomQueue(Room: Room)
                        let bound = Room.Playlist.Queue.count
                        let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                        let selectedSong = Room.Playlist.Queue.sorted()[randSongIndex]
                        let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                        var rerunFlow = Flow
                        rerunFlow[0] = .rerun
                        return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                      }
                      // FOURTH LAYER (song/artist/similarArtist): history [rerun]
                      if(defaultChoice == AuxrRecommendNode.history){
                        self.GetMostFrequentMusicDataFromRoomHistory(Room: Room)
                        let bound = Room.Playlist.History.count
                        let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                        let selectedSong = Room.Playlist.History.sorted()[randSongIndex]
                        let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                        var rerunFlow = Flow
                        rerunFlow[0] = .rerun
                        return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                      }
                      // FOURTH LAYER (song/artist/similarArtist): likes [rerun]
                      if(defaultChoice == AuxrRecommendNode.likes){
                        self.GetMostFrequentMusicDataFromUserLikes(User: User, Room: Room)
                        let bound = User.Likes.count
                        let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                        let selectedSong = User.Likes.sorted()[randSongIndex]
                        let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                        var rerunFlow = Flow
                        rerunFlow[0] = .rerun
                        return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                      }
                      // FOURTH LAYER (song/artist/similarArtist): votes [rerun]
                      if(defaultChoice == AuxrRecommendNode.votes){
                        self.GetMostFrequentMusicDataFromUserVotes(User: User, Room: Room)
                        let bound = User.Votes.count
                        let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                        let selectedSong = User.Votes.sorted()[randSongIndex]
                        let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                        var rerunFlow = Flow
                        rerunFlow[0] = .rerun
                        return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                      }
                      else if(entryPoint == AuxrRecommendNode.rerun){
                        self.BackgroundSongSearchResult = []
                        self.BackgroundAlbumSearchResult = []
                        self.BackgroundArtistSearchResult = []
                        try await self.Search(Input: ParseArtistName(input: defaultSong?.artistName ?? "", getFirst: false) ?? "", Filter: SearchFilter.albums, Background: true)
                        if(!self.BackgroundAlbumSearchResult.isEmpty){
                          var sameGenreAlbums: [Album] = []
                          let genre = artist?.genreNames?.filter({ $0 != "Music" }).first ?? "Music"
                          for album in self.BackgroundAlbumSearchResult{ if(album.genreNames.contains(genre)){ sameGenreAlbums.append(album)} }
                          if(!sameGenreAlbums.isEmpty){
                            self.BackgroundSongSearchResult = []
                            self.BackgroundAlbumSearchResult = []
                            self.BackgroundArtistSearchResult = []
                            let topAlbumsBound = sameGenreAlbums.count
                            let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                            let randAlbum = sameGenreAlbums[randAlbumIndex]
                            self.BackgroundAlbumTracks = []
                            try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                            let albumTracks = self.BackgroundAlbumTracks
                            let tracksBound = albumTracks.count
                            let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                            let randTrack = albumTracks[randTrackIndex]
                            return randTrack.id.rawValue
                          }
                          else{
                            let albumsCount = self.BackgroundAlbumSearchResult.count
                            let randAlbumIndex = ((albumsCount > 1) ? Int.random(in: 0...albumsCount-1) : 0)
                            let randAlbum = self.BackgroundAlbumSearchResult[randAlbumIndex]
                            self.BackgroundAlbumTracks = []
                            try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                            let albumTracks = self.BackgroundAlbumTracks
                            let tracksBound = albumTracks.count
                            let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                            let randTrack = albumTracks[randTrackIndex]
                            return randTrack.id.rawValue
                          }
                        }
                      }
                      
                      var topChartsRequest = MusicCatalogChartsRequest(types: [Song.self, Album.self])
                      topChartsRequest.limit = 25
                      let topChartsResponse = try await topChartsRequest.response()
                      
                      // FOURTH LAYER (song/artist/similarArtist): topSongs [genre]
                      if(defaultChoice == AuxrRecommendNode.topSongs){
                        var sameGenreSongs: [Song] = []
                        let topSongs = topChartsResponse.songCharts
                        for song in topSongs[0].items{ if(song.genreNames.contains(genre)){ sameGenreSongs.append(song)} }
                        if(!sameGenreSongs.isEmpty){
                          let topSongsBound = sameGenreSongs.count
                          let randSongIndex = ((topSongsBound > 1) ? Int.random(in: 0...topSongsBound-1) : 0)
                          let randSong = sameGenreSongs[randSongIndex]
                          return randSong.id.rawValue
                        }
                        else{
                          // FOURTH LAYER (song/artist/similarArtist): topSongs [no genre]
                          let topSongsBound = topSongs[0].items.count
                          let randSongIndex = ((topSongsBound > 1) ? Int.random(in: 0...topSongsBound-1) : 0)
                          let randSong = topSongs[0].items[randSongIndex]
                          return randSong.id.rawValue
                        }
                      }
                      // FOURTH LAYER (song/artist/similarArtist): topAlbums [genre]
                      if(defaultChoice == AuxrRecommendNode.topAlbums){
                        var sameGenreAlbums: [Album] = []
                        let topAlbums = topChartsResponse.albumCharts
                        for album in topAlbums[0].items{ if(album.genreNames.contains(genre)){ sameGenreAlbums.append(album)} }
                        if(!sameGenreAlbums.isEmpty){
                          self.BackgroundSongSearchResult = []
                          self.BackgroundAlbumSearchResult = []
                          self.BackgroundArtistSearchResult = []
                          let topAlbumsBound = sameGenreAlbums.count
                          let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                          let randAlbum = sameGenreAlbums[randAlbumIndex]
                          self.BackgroundAlbumTracks = []
                          try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                          let albumTracks = self.BackgroundAlbumTracks
                          let tracksBound = albumTracks.count
                          let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                          let randTrack = albumTracks[randTrackIndex]
                          return randTrack.id.rawValue
                        }
                        else{
                          // FOURTH LAYER (song/artist/similarArtist): topAlbums [no genre]
                          let topAlbumsBound = topAlbums[0].items.count
                          let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                          let randAlbum = topAlbums[0].items[randAlbumIndex]
                          self.BackgroundAlbumTracks = []
                          try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                          let albumTracks = self.BackgroundAlbumTracks
                          let tracksBound = albumTracks.count
                          let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                          let randTrack = albumTracks[randTrackIndex]
                          return randTrack.id.rawValue
                        }
                      }
                    }
                  }
                }
                else{
                  // THIRD LAYER (song/artist/similarArtist): rerun [default]
                  if let genre = song?.genreNames.filter({ $0 != "Music" }).first{
                    let defaultChoice = self.UserRecommended.initDefaultLayer(QueuePercentage: 0.0, LibraryPercentage: 0.0, HistoryPercentage: 0.0, LikesPercentage: 0.0, VotesPercentage: 0.0, TopSongsPercentage: 30.0, TopAlbumsPercentage: 70.0)
                    // FOURTH LAYER (song/artist/similarArtist): queue [genre]
                    if(defaultChoice == AuxrRecommendNode.queue){
                      let bound = Room.Playlist.Queue.count
                      let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                      let selectedSong = Room.Playlist.Queue.sorted()[randSongIndex]
                      let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                      var rerunFlow = Flow
                      rerunFlow[0] = .rerun
                      return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                    }
                    var topChartsRequest = MusicCatalogChartsRequest(types: [Song.self, Album.self])
                    topChartsRequest.limit = 25
                    let topChartsResponse = try await topChartsRequest.response()
                    // FOURTH LAYER (song/artist): topSongs [genre]
                    if(defaultChoice == AuxrRecommendNode.topSongs){
                      var sameGenreSongs: [Song] = []
                      let topSongs = topChartsResponse.songCharts
                      for song in topSongs[0].items{ if(song.genreNames.contains(genre)){ sameGenreSongs.append(song)} }
                      if(!sameGenreSongs.isEmpty){
                        let topSongsBound = sameGenreSongs.count
                        let randSongIndex = ((topSongsBound > 1) ? Int.random(in: 0...topSongsBound-1) : 0)
                        let randSong = sameGenreSongs[randSongIndex]
                        return randSong.id.rawValue
                      }
                      else{
                        // FOURTH LAYER (song/artist/similarArtist): topSongs [no genre]
                        let topSongsBound = topSongs[0].items.count
                        let randSongIndex = ((topSongsBound > 1) ? Int.random(in: 0...topSongsBound-1) : 0)
                        let randSong = topSongs[0].items[randSongIndex]
                        return randSong.id.rawValue
                      }
                    }
                    // FOURTH LAYER (song/artist/similarArtist): topAlbums [genre]
                    if(defaultChoice == AuxrRecommendNode.topAlbums){
                      var sameGenreAlbums: [Album] = []
                      let topAlbums = topChartsResponse.albumCharts
                      for album in topAlbums[0].items{ if(album.genreNames.contains(genre)){ sameGenreAlbums.append(album)} }
                      if(!sameGenreAlbums.isEmpty){
                        self.BackgroundSongSearchResult = []
                        self.BackgroundAlbumSearchResult = []
                        self.BackgroundArtistSearchResult = []
                        let topAlbumsBound = sameGenreAlbums.count
                        let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                        let randAlbum = sameGenreAlbums[randAlbumIndex]
                        self.BackgroundAlbumTracks = []
                        try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                        let albumTracks = self.BackgroundAlbumTracks
                        let tracksBound = albumTracks.count
                        let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                        let randTrack = albumTracks[randTrackIndex]
                        return randTrack.id.rawValue
                      }
                      else{
                        // FOURTH LAYER (song/artist/similarArtist): topAlbums [no genre]
                        let topAlbumsBound = topAlbums[0].items.count
                        let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                        let randAlbum = topAlbums[0].items[randAlbumIndex]
                        self.BackgroundAlbumTracks = []
                        try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                        let albumTracks = self.BackgroundAlbumTracks
                        let tracksBound = albumTracks.count
                        let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                        let randTrack = albumTracks[randTrackIndex]
                        return randTrack.id.rawValue
                      }
                    }
                  }
                }
              }
              // THIRD LAYER (song/artist): topSongs
              if(Flow[3] == AuxrRecommendNode.topSongs){
                self.BackgroundSongSearchResult = []
                self.BackgroundAlbumSearchResult = []
                self.BackgroundArtistSearchResult = []
                try await self.Search(Input: artistName, Filter: .songs, Background: true)
                if(!self.BackgroundSongSearchResult.isEmpty){
                  var sameGenreSongs: [Song] = []
                  if let genre = song?.genreNames.filter({ $0 != "Music"}).first{
                    for song in self.BackgroundSongSearchResult{ if(song.genreNames.contains(genre)){ sameGenreSongs.append(song)} }
                    if(!sameGenreSongs.isEmpty){
                      let songsBound = sameGenreSongs.count
                      let randSongIndex = ((songsBound > 1) ? Int.random(in: 0...songsBound-1) : 0)
                      let randSong = sameGenreSongs[randSongIndex]
                      return randSong.id.rawValue
                    }
                    else{
                      // FOURTH LAYER (song/artist/similarArtist): topSongs [no genre]
                      let songsBound = self.BackgroundSongSearchResult.count
                      let randSongIndex = ((songsBound > 1) ? Int.random(in: 0...songsBound-1) : 0)
                      let randSong = self.BackgroundSongSearchResult[randSongIndex]
                      return randSong.id.rawValue
                    }
                  }
                }
              }
              // THIRD LAYER (song/artist): topAlbums
              else if(Flow[3] == AuxrRecommendNode.topAlbums){
                self.BackgroundSongSearchResult = []
                self.BackgroundAlbumSearchResult = []
                self.BackgroundArtistSearchResult = []
                try await self.Search(Input: artistName, Filter: SearchFilter.albums, Background: true)
                if(!self.BackgroundAlbumSearchResult.isEmpty){
                  var sameGenreAlbums: [Album] = []
                  let genre = artist?.genreNames?.filter({ $0 != "Music" }).first ?? "Music"
                  for album in self.BackgroundAlbumSearchResult{ if(album.genreNames.contains(genre)){ sameGenreAlbums.append(album)} }
                  if(!sameGenreAlbums.isEmpty){
                    self.BackgroundSongSearchResult = []
                    self.BackgroundAlbumSearchResult = []
                    self.BackgroundArtistSearchResult = []
                    let topAlbumsBound = sameGenreAlbums.count
                    let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                    let randAlbum = sameGenreAlbums[randAlbumIndex]
                    self.BackgroundAlbumTracks = []
                    try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                    let albumTracks = self.BackgroundAlbumTracks
                    let tracksBound = albumTracks.count
                    let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                    let randTrack = albumTracks[randTrackIndex]
                    return randTrack.id.rawValue
                  }
                  else{
                    // FOURTH LAYER (song/artist/similarArtist): topAlbums [no genre]
                    let topAlbumsBound = self.BackgroundAlbumSearchResult.count
                    let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                    let randAlbum = self.BackgroundAlbumSearchResult[randAlbumIndex]
                    self.BackgroundAlbumTracks = []
                    try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                    let albumTracks = self.BackgroundAlbumTracks
                    let tracksBound = albumTracks.count
                    let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                    let randTrack = albumTracks[randTrackIndex]
                    return randTrack.id.rawValue
                  }
                }
              }
              // THIRD LAYER (song/artist): latestReleases
              else if(Flow[3] == AuxrRecommendNode.latestRelease){
                if let latestRelease = artist?.latestRelease{
                  try await self.GetAlbumTracks(Album: latestRelease, Background: true)
                  self.BackgroundAlbumTracks = []
                  let albumTracks = self.BackgroundAlbumTracks
                  let tracksBound = albumTracks.count
                  let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                  let randTrack = albumTracks[randTrackIndex]
                  return randTrack.id.rawValue
                }
              }
              // THIRD LAYER (song/artist): rerun [default]
              else{
                if let genre = song?.genreNames.filter({ $0 != "Music" }).first{
                  var defaultChoice = self.UserRecommended.initDefaultLayer(QueuePercentage: 0.0, LibraryPercentage: 0.0, HistoryPercentage: 0.0, LikesPercentage: 0.0, VotesPercentage: 0.0, TopSongsPercentage: 45.0, TopAlbumsPercentage: 55.0)
                  if(entryPoint != .rerun){
                    if(entryPoint == AuxrRecommendNode.similarSongs){
                      return try await self.ConvertRecommendedFlowToSongID(defaultSong: defaultSong, User: User, Room: Room, Flow: Flow)
                    }
                    self.GetRerunFlowEntryPointPercentages(User: User, Room: Room)
                    defaultChoice = self.UserRecommended.initDefaultLayer(QueuePercentage: self.UserRecommended.QueuePercentage, LibraryPercentage: self.UserRecommended.LibraryPercentage, HistoryPercentage: self.UserRecommended.HistoryPercentage, LikesPercentage: self.UserRecommended.LikesPercentage, VotesPercentage: self.UserRecommended.VotesPercentage, TopSongsPercentage: self.UserRecommended.TopSongsPercentage, TopAlbumsPercentage: self.UserRecommended.TopAlbumsPercentage)
                  }
                  // FOURTH LAYER (song/artist/similarArtist): library [rerun]
                  if(defaultChoice == AuxrRecommendNode.library){
                    self.GetMostMusicDataFrequentFromUserPlaylists()
                    var bound = self.UserLibraryPlaylists.count
                    let randPlaylistIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                    let playlist = self.UserLibraryPlaylists[randPlaylistIndex]
                    bound = playlist.AM_Songs.count
                    let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                    let selectedSong = playlist.AM_Songs[randSongIndex]
                    let am_song = try await self.ConvertSongID(SongID: selectedSong)
                    var rerunFlow = Flow
                    rerunFlow[0] = .rerun
                    return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                  }
                  // FOURTH LAYER (song/artist/similarArtist): queue [rerun]
                  else if(defaultChoice == AuxrRecommendNode.queue){
                    self.GetMostFrequentMusicDataFromRoomQueue(Room: Room)
                    let bound = Room.Playlist.Queue.count
                    let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                    let selectedSong = Room.Playlist.Queue.sorted()[randSongIndex]
                    let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                    var rerunFlow = Flow
                    rerunFlow[0] = .rerun
                    return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                  }
                  // FOURTH LAYER (song/artist/similarArtist): history [rerun]
                  else if(defaultChoice == AuxrRecommendNode.history){
                    self.GetMostFrequentMusicDataFromRoomHistory(Room: Room)
                    let bound = Room.Playlist.History.count
                    let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                    let selectedSong = Room.Playlist.History.sorted()[randSongIndex]
                    let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                    var rerunFlow = Flow
                    rerunFlow[0] = .rerun
                    return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                  }
                  // FOURTH LAYER (song/artist/similarArtist): likes [rerun]
                  else if(defaultChoice == AuxrRecommendNode.likes){
                    self.GetMostFrequentMusicDataFromUserLikes(User: User, Room: Room)
                    let bound = User.Likes.count
                    let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                    let selectedSong = User.Likes.sorted()[randSongIndex]
                    let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                    var rerunFlow = Flow
                    rerunFlow[0] = .rerun
                    return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                  }
                  // FOURTH LAYER (song/artist/similarArtist): votes [rerun]
                  else if(defaultChoice == AuxrRecommendNode.votes){
                    self.GetMostFrequentMusicDataFromUserVotes(User: User, Room: Room)
                    let bound = User.Votes.count
                    let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                    let selectedSong = User.Votes.sorted()[randSongIndex]
                    let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                    var rerunFlow = Flow
                    rerunFlow[0] = .rerun
                    return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                  }
                  else if(entryPoint == AuxrRecommendNode.rerun){
                    self.BackgroundSongSearchResult = []
                    self.BackgroundAlbumSearchResult = []
                    self.BackgroundArtistSearchResult = []
                    try await self.Search(Input: ParseArtistName(input: defaultSong?.artistName ?? "", getFirst: false) ?? "", Filter: SearchFilter.albums, Background: true)
                    if(!self.BackgroundAlbumSearchResult.isEmpty){
                      var sameGenreAlbums: [Album] = []
                      let genre = artist?.genreNames?.filter({ $0 != "Music" }).first ?? "Music"
                      for album in self.BackgroundAlbumSearchResult{ if(album.genreNames.contains(genre)){ sameGenreAlbums.append(album)} }
                      if(!sameGenreAlbums.isEmpty){
                        self.BackgroundSongSearchResult = []
                        self.BackgroundAlbumSearchResult = []
                        self.BackgroundArtistSearchResult = []
                        let topAlbumsBound = sameGenreAlbums.count
                        let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                        let randAlbum = sameGenreAlbums[randAlbumIndex]
                        self.BackgroundAlbumTracks = []
                        try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                        let albumTracks = self.BackgroundAlbumTracks
                        let tracksBound = albumTracks.count
                        let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                        let randTrack = albumTracks[randTrackIndex]
                        return randTrack.id.rawValue
                      }
                      else{
                        let albumsCount = self.BackgroundAlbumSearchResult.count
                        let randAlbumIndex = ((albumsCount > 1) ? Int.random(in: 0...albumsCount-1) : 0)
                        let randAlbum = self.BackgroundAlbumSearchResult[randAlbumIndex]
                        self.BackgroundAlbumTracks = []
                        try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                        let albumTracks = self.BackgroundAlbumTracks
                        let tracksBound = albumTracks.count
                        let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                        let randTrack = albumTracks[randTrackIndex]
                        return randTrack.id.rawValue
                      }
                    }
                  }
                  
                  var topChartsRequest = MusicCatalogChartsRequest(types: [Song.self, Album.self])
                  topChartsRequest.limit = 25
                  let topChartsResponse = try await topChartsRequest.response()
                  
                  // THIRD LAYER (song/artist): topSongs [genre]
                  if(defaultChoice == AuxrRecommendNode.topSongs){
                    var sameGenreSongs: [Song] = []
                    let topSongs = topChartsResponse.songCharts
                    for song in topSongs[0].items{ if(song.genreNames.contains(genre)){ sameGenreSongs.append(song)} }
                    if(!sameGenreSongs.isEmpty){
                      let topSongsBound = sameGenreSongs.count
                      let randSongIndex = ((topSongsBound > 1) ? Int.random(in: 0...topSongsBound-1) : 0)
                      let randSong = sameGenreSongs[randSongIndex]
                      return randSong.id.rawValue
                    }
                    // THIRD LAYER (song/artist): topSongs [no genre]
                    else{
                      let topSongsBound = topSongs[0].items.count
                      let randSongIndex = ((topSongsBound > 1) ? Int.random(in: 0...topSongsBound-1) : 0)
                      let randSong = topSongs[0].items[randSongIndex]
                      return randSong.id.rawValue
                    }
                  }
                  // THIRD LAYER (song/artist): topAlbums [genre]
                  if(defaultChoice == AuxrRecommendNode.topAlbums){
                    var sameGenreAlbums: [Album] = []
                    let topAlbums = topChartsResponse.albumCharts
                    for album in topAlbums[0].items{ if(album.genreNames.contains(genre)){ sameGenreAlbums.append(album)} }
                    if(!sameGenreAlbums.isEmpty){
                      self.BackgroundSongSearchResult = []
                      self.BackgroundAlbumSearchResult = []
                      self.BackgroundArtistSearchResult = []
                      let topAlbumsBound = sameGenreAlbums.count
                      let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                      let randAlbum = sameGenreAlbums[randAlbumIndex]
                      self.BackgroundAlbumTracks = []
                      try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                      let albumTracks = self.BackgroundAlbumTracks
                      let tracksBound = albumTracks.count
                      let randTrackIndex = Int.random(in: 0...tracksBound-1)
                      let randTrack = albumTracks[randTrackIndex]
                      return randTrack.id.rawValue
                    }
                    // THIRD LAYER (song/artist): topAlbums [no genre]
                    else{
                      let topAlbumsBound = topAlbums[0].items.count
                      let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                      let randAlbum = topAlbums[0].items[randAlbumIndex]
                      self.BackgroundAlbumTracks = []
                      try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                      let albumTracks = self.BackgroundAlbumTracks
                      let tracksBound = albumTracks.count
                      let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                      let randTrack = albumTracks[randTrackIndex]
                      return randTrack.id.rawValue
                    }
                  }
                }
              }
            }
          }
        }
        // THIRD LAYER (song): album
        if(Flow[2] == AuxrRecommendNode.album){
          // FOURTH LAYER (song/album): relatedAlbums
          if(Flow[3] == AuxrRecommendNode.relatedAlbums){
            if let albumTitle = song?.albumTitle{
              self.BackgroundSongSearchResult = []
              self.BackgroundAlbumSearchResult = []
              self.BackgroundArtistSearchResult = []
              try await self.Search(Input: ParseArtistName(input: song?.artistName ?? "", getFirst: false) ?? "", Filter: SearchFilter.albums, Background: true)
              if let relatedAlbums = self.BackgroundAlbumSearchResult.first?.relatedAlbums{
                let albumsBound = relatedAlbums.count
                let randRelatedAlbumIndex = ((albumsBound > 1) ? Int.random(in: 0...albumsBound-1) : 0)
                let randRelatedAlbum = relatedAlbums[randRelatedAlbumIndex]
                self.BackgroundAlbumTracks = []
                try await self.GetAlbumTracks(Album: randRelatedAlbum, Background: true)
                let albumTracks = self.BackgroundAlbumTracks
                let tracksBound = albumTracks.count
                let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                let randTrack = albumTracks[randTrackIndex]
                return randTrack.id.rawValue
              }
              else{
                // FOURTH LAYER (song/album/relatedAlbums): rerun [default]
                if let genre = song?.genreNames.filter({ $0 != "Music" }).first{
                  var defaultChoice = self.UserRecommended.initDefaultLayer(QueuePercentage: 0.0, LibraryPercentage: 0.0, HistoryPercentage: 0.0, LikesPercentage: 0.0, VotesPercentage: 0.0, TopSongsPercentage: 45.0, TopAlbumsPercentage: 55.0)
                  if(entryPoint == AuxrRecommendNode.rerun){
                    self.GetRerunFlowEntryPointPercentages(User: User, Room: Room)
                    defaultChoice = self.UserRecommended.initDefaultLayer(QueuePercentage: self.UserRecommended.QueuePercentage, LibraryPercentage: self.UserRecommended.LibraryPercentage, HistoryPercentage: self.UserRecommended.HistoryPercentage, LikesPercentage: self.UserRecommended.LikesPercentage, VotesPercentage: self.UserRecommended.VotesPercentage, TopSongsPercentage: self.UserRecommended.TopSongsPercentage, TopAlbumsPercentage: self.UserRecommended.TopAlbumsPercentage)
                  }
                  // FOURTH LAYER (song/artist/similarArtist): library [rerun]
                  if(defaultChoice == AuxrRecommendNode.library){
                    self.GetMostMusicDataFrequentFromUserPlaylists()
                    var bound = self.UserLibraryPlaylists.count
                    let randPlaylistIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                    let playlist = self.UserLibraryPlaylists[randPlaylistIndex]
                    bound = playlist.AM_Songs.count
                    let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                    let selectedSong = playlist.AM_Songs[randSongIndex]
                    let am_song = try await self.ConvertSongID(SongID: selectedSong)
                    var rerunFlow = Flow
                    rerunFlow[0] = .rerun
                    return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                  }
                  // FOURTH LAYER (song/artist/similarArtist): queue [rerun]
                  if(defaultChoice == AuxrRecommendNode.queue){
                    self.GetMostFrequentMusicDataFromRoomQueue(Room: Room)
                    let bound = Room.Playlist.Queue.count
                    let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                    let selectedSong = Room.Playlist.Queue.sorted()[randSongIndex]
                    let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                    var rerunFlow = Flow
                    rerunFlow[0] = .rerun
                    return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                  }
                  // FOURTH LAYER (song/artist/similarArtist): history [rerun]
                  if(defaultChoice == AuxrRecommendNode.history){
                    self.GetMostFrequentMusicDataFromRoomHistory(Room: Room)
                    let bound = Room.Playlist.History.count
                    let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                    let selectedSong = Room.Playlist.History.sorted()[randSongIndex]
                    let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                    var rerunFlow = Flow
                    rerunFlow[0] = .rerun
                    return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                  }
                  // FOURTH LAYER (song/artist/similarArtist): likes [rerun]
                  if(defaultChoice == AuxrRecommendNode.likes){
                    self.GetMostFrequentMusicDataFromUserLikes(User: User, Room: Room)
                    let bound = User.Likes.count
                    let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                    let selectedSong = User.Likes.sorted()[randSongIndex]
                    let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                    var rerunFlow = Flow
                    rerunFlow[0] = .rerun
                    return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                  }
                  // FOURTH LAYER (song/artist/similarArtist): votes [rerun]
                  if(defaultChoice == AuxrRecommendNode.votes){
                    self.GetMostFrequentMusicDataFromUserVotes(User: User, Room: Room)
                    let bound = User.Votes.count
                    let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                    let selectedSong = User.Votes.sorted()[randSongIndex]
                    let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                    var rerunFlow = Flow
                    rerunFlow[0] = .rerun
                    return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                  }
                  else if(entryPoint == AuxrRecommendNode.rerun){
                    self.BackgroundSongSearchResult = []
                    self.BackgroundAlbumSearchResult = []
                    self.BackgroundArtistSearchResult = []
                    try await self.Search(Input: ParseArtistName(input: defaultSong?.artistName ?? "", getFirst: false) ?? "", Filter: SearchFilter.albums, Background: true)
                    if(!self.BackgroundAlbumSearchResult.isEmpty){
                      var sameGenreAlbums: [Album] = []
                      let genre = defaultSong?.genreNames.filter({ $0 != "Music" }).first ?? "Music"
                      for album in self.BackgroundAlbumSearchResult{ if(album.genreNames.contains(genre)){ sameGenreAlbums.append(album)} }
                      if(!sameGenreAlbums.isEmpty){
                        self.BackgroundSongSearchResult = []
                        self.BackgroundAlbumSearchResult = []
                        self.BackgroundArtistSearchResult = []
                        let topAlbumsBound = sameGenreAlbums.count
                        let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                        let randAlbum = sameGenreAlbums[randAlbumIndex]
                        self.BackgroundAlbumTracks = []
                        try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                        let albumTracks = self.BackgroundAlbumTracks
                        let tracksBound = albumTracks.count
                        let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                        let randTrack = albumTracks[randTrackIndex]
                        return randTrack.id.rawValue
                      }
                      else{
                        let albumsCount = self.BackgroundAlbumSearchResult.count
                        let randAlbumIndex = ((albumsCount > 1) ? Int.random(in: 0...albumsCount-1) : 0)
                        let randAlbum = self.BackgroundAlbumSearchResult[randAlbumIndex]
                        self.BackgroundAlbumTracks = []
                        try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                        let albumTracks = self.BackgroundAlbumTracks
                        let tracksBound = albumTracks.count
                        let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                        let randTrack = albumTracks[randTrackIndex]
                        return randTrack.id.rawValue
                      }
                    }
                  }
                  
                  var topChartsRequest = MusicCatalogChartsRequest(types: [Song.self, Album.self])
                  topChartsRequest.limit = 25
                  let topChartsResponse = try await topChartsRequest.response()
                  
                  // FOURTH LAYER (song/album/relatedAlbums): topSongs [genre]
                  if(defaultChoice == AuxrRecommendNode.topSongs){
                    var sameGenreSongs: [Song] = []
                    let topSongs = topChartsResponse.songCharts
                    for song in topSongs[0].items{ if(song.genreNames.contains(genre)){ sameGenreSongs.append(song)} }
                    if(!sameGenreSongs.isEmpty){
                      let topSongsBound = sameGenreSongs.count
                      let randSongIndex = ((topSongsBound > 1) ? Int.random(in: 0...topSongsBound-1) : 0)
                      let randSong = sameGenreSongs[randSongIndex]
                      return randSong.id.rawValue
                    }
                    else{
                      // FOURTH LAYER (song/album/relatedAlbums): topSongs [no genre]
                      let topSongsBound = topSongs[0].items.count
                      let randSongIndex = ((topSongsBound > 1) ? Int.random(in: 0...topSongsBound-1) : 0)
                      let randSong = topSongs[0].items[randSongIndex]
                      return randSong.id.rawValue
                    }
                  }
                  // FOURTH LAYER (song/album/relatedAlbums): topAlbums [genre]
                  if(defaultChoice == AuxrRecommendNode.topAlbums){
                    var sameGenreAlbums: [Album] = []
                    let topAlbums = topChartsResponse.albumCharts
                    for album in topAlbums[0].items{ if(album.genreNames.contains(genre)){ sameGenreAlbums.append(album)} }
                    if(!sameGenreAlbums.isEmpty){
                      self.BackgroundSongSearchResult = []
                      self.BackgroundAlbumSearchResult = []
                      self.BackgroundArtistSearchResult = []
                      let topAlbumsBound = sameGenreAlbums.count
                      let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                      let randAlbum = sameGenreAlbums[randAlbumIndex]
                      self.BackgroundAlbumTracks = []
                      try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                      let albumTracks = self.BackgroundAlbumTracks
                      let tracksBound = albumTracks.count
                      let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                      let randTrack = albumTracks[randTrackIndex]
                      return randTrack.id.rawValue
                    }
                    else{
                      // FOURTH LAYER (song/album/relatedAlbums): topSongs [no genre]
                      let topAlbumsBound = topAlbums[0].items.count
                      let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                      let randAlbum = topAlbums[0].items[randAlbumIndex]
                      self.BackgroundAlbumTracks = []
                      try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                      let albumTracks = self.BackgroundAlbumTracks
                      let tracksBound = albumTracks.count
                      let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                      let randTrack = albumTracks[randTrackIndex]
                      return randTrack.id.rawValue
                    }
                  }
                }
              }
            }
          }
          // THIRD LAYER (song/album): track
          if(Flow[3] == AuxrRecommendNode.track){
            if let albumTitle = song?.albumTitle{
              self.BackgroundSongSearchResult = []
              self.BackgroundAlbumSearchResult = []
              self.BackgroundArtistSearchResult = []
              try await self.Search(Input: ParseArtistName(input: defaultSong?.artistName ?? "", getFirst: false) ?? "", Filter: SearchFilter.albums, Background: true)
              if(!self.BackgroundAlbumSearchResult.isEmpty){
                var sameGenreAlbums: [Album] = []
                let genre = song?.genreNames.filter({ $0 != "Music" }).first ?? "Music"
                for album in self.BackgroundAlbumSearchResult{ if(album.genreNames.contains(genre)){ sameGenreAlbums.append(album)} }
                if(!sameGenreAlbums.isEmpty){
                  self.BackgroundSongSearchResult = []
                  self.BackgroundAlbumSearchResult = []
                  self.BackgroundArtistSearchResult = []
                  let topAlbumsBound = sameGenreAlbums.count
                  let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                  let randAlbum = sameGenreAlbums[randAlbumIndex]
                  self.BackgroundAlbumTracks = []
                  try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                  let albumTracks = self.BackgroundAlbumTracks
                  let tracksBound = albumTracks.count
                  let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                  let randTrack = albumTracks[randTrackIndex]
                  return randTrack.id.rawValue
                }
                else{
                  let albumsCount = self.BackgroundAlbumSearchResult.count
                  let randAlbumIndex = ((albumsCount > 1) ? Int.random(in: 0...albumsCount-1) : 0)
                  let randAlbum = self.BackgroundAlbumSearchResult[randAlbumIndex]
                  self.BackgroundAlbumTracks = []
                  try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                  let albumTracks = self.BackgroundAlbumTracks
                  let tracksBound = albumTracks.count
                  let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                  let randTrack = albumTracks[randTrackIndex]
                  return randTrack.id.rawValue
                }
              }
            }
          }
        }
      }
      
      // SECOND LAYER: artist
      if(secondLayer == AuxrRecommendNode.artist){
        let artistsBound = self.UserRecommended.MostFrequentArtists.count
        let randArtistIndex = ((artistsBound > 1) ? Int.random(in: 0...artistsBound-1) : 0)
        let artistName = ParseArtistName(input: self.UserRecommended.MostFrequentArtistNames[randArtistIndex], getFirst: false) ?? ""
        self.BackgroundSongSearchResult = []
        self.BackgroundAlbumSearchResult = []
        self.BackgroundArtistSearchResult = []
        try await self.Search(Input: artistName, Filter: SearchFilter.artists, Background: true)
        if let artistID = self.BackgroundArtistSearchResult.first?.id.rawValue{
          let artist = try await self.ConvertArtistID(ArtistID: artistID)
          // THIRD LAYER(artist): similarArtists
          if(Flow[2] == AuxrRecommendNode.similarArtists){
            if let similarArtists = artist?.similarArtists{
              let artistsBound = similarArtists.count
              let randArtistIndex = ((artistsBound > 1) ? Int.random(in: 0...artistsBound-1) : 0)
              let randSimilarArtist = similarArtists[randArtistIndex]
              // THIRD LAYER(artist/similarArtists): topSongs
              if(Flow[3] == AuxrRecommendNode.topSongs){
                self.BackgroundSongSearchResult = []
                self.BackgroundAlbumSearchResult = []
                self.BackgroundArtistSearchResult = []
                try await self.Search(Input: ParseArtistName(input: randSimilarArtist.name, getFirst: false) ?? "", Filter: .songs, Background: true)
                if(!self.BackgroundSongSearchResult.isEmpty){
                  var sameGenreSongs: [Song] = []
                  if let genre = randSimilarArtist.genreNames?.filter({ $0 != "Music"}).first{
                    for song in self.BackgroundSongSearchResult{ if(song.genreNames.contains(genre)){ sameGenreSongs.append(song)} }
                    if(!sameGenreSongs.isEmpty){
                      let songsBound = sameGenreSongs.count
                      let randSongIndex = ((songsBound > 1) ? Int.random(in: 0...songsBound-1) : 0)
                      let randSong = sameGenreSongs[randSongIndex]
                      return randSong.id.rawValue
                    }
                    else{
                      // FOURTH LAYER (song/artist/similarArtist): topSongs [no genre]
                      let songsBound = self.BackgroundSongSearchResult.count
                      let randSongIndex = ((songsBound > 1) ? Int.random(in: 0...songsBound-1) : 0)
                      let randSong = self.BackgroundSongSearchResult[randSongIndex]
                      return randSong.id.rawValue
                    }
                  }
                }
              }
              // THIRD LAYER(artist/similarArtists): topAlbums
              else if(Flow[3] == AuxrRecommendNode.topAlbums){
                self.BackgroundSongSearchResult = []
                self.BackgroundAlbumSearchResult = []
                self.BackgroundArtistSearchResult = []
                try await self.Search(Input: ParseArtistName(input: randSimilarArtist.name, getFirst: false) ?? "", Filter: SearchFilter.albums, Background: true)
                if(!self.BackgroundAlbumSearchResult.isEmpty){
                  var sameGenreAlbums: [Album] = []
                  let genre = artist?.genreNames?.filter({ $0 != "Music" }).first ?? "Music"
                  for album in self.BackgroundAlbumSearchResult{ if(album.genreNames.contains(genre)){ sameGenreAlbums.append(album)} }
                  if(!sameGenreAlbums.isEmpty){
                    self.BackgroundSongSearchResult = []
                    self.BackgroundAlbumSearchResult = []
                    self.BackgroundArtistSearchResult = []
                    let topAlbumsBound = sameGenreAlbums.count
                    let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                    let randAlbum = sameGenreAlbums[randAlbumIndex]
                    self.BackgroundAlbumTracks = []
                    try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                    let albumTracks = self.BackgroundAlbumTracks
                    let tracksBound = albumTracks.count
                    let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                    let randTrack = albumTracks[randTrackIndex]
                    return randTrack.id.rawValue
                  }
                  else{
                    // FOURTH LAYER (song/artist/similarArtist): topAlbums [no genre]
                    let topAlbumsBound = self.BackgroundAlbumSearchResult.count
                    let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                    let randAlbum = self.BackgroundAlbumSearchResult[randAlbumIndex]
                    self.BackgroundAlbumTracks = []
                    try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                    let albumTracks = self.BackgroundAlbumTracks
                    let tracksBound = albumTracks.count
                    let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                    let randTrack = albumTracks[randTrackIndex]
                    return randTrack.id.rawValue
                  }
                }
              }
              // THIRD LAYER(artist/similarArtists): latestReleases
              else if(Flow[3] == AuxrRecommendNode.latestRelease){
                if let latestRelease = randSimilarArtist.latestRelease{
                  try await self.GetAlbumTracks(Album: latestRelease, Background: true)
                  self.BackgroundAlbumTracks = []
                  let albumTracks = self.BackgroundAlbumTracks
                  let tracksBound = albumTracks.count
                  let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                  let randTrack = albumTracks[randTrackIndex]
                  return randTrack.id.rawValue
                }
              }
              else{
                // THIRD LAYER(artist/similarArtists): rerun [default]
                if let genre = artist?.genreNames?.filter({ $0 != "Music" }).first{
                  var defaultChoice = self.UserRecommended.initDefaultLayer(QueuePercentage: 0.0, LibraryPercentage: 0.0, HistoryPercentage: 0.0, LikesPercentage: 0.0, VotesPercentage: 0.0, TopSongsPercentage: 45.0, TopAlbumsPercentage: 55.0)
                  if(entryPoint != .rerun){
                    if(entryPoint == AuxrRecommendNode.similarSongs){
                      return try await self.ConvertRecommendedFlowToSongID(defaultSong: defaultSong, User: User, Room: Room, Flow: Flow)
                    }
                    self.GetRerunFlowEntryPointPercentages(User: User, Room: Room)
                    defaultChoice = self.UserRecommended.initDefaultLayer(QueuePercentage: self.UserRecommended.QueuePercentage, LibraryPercentage: self.UserRecommended.LibraryPercentage, HistoryPercentage: self.UserRecommended.HistoryPercentage, LikesPercentage: self.UserRecommended.LikesPercentage, VotesPercentage: self.UserRecommended.VotesPercentage, TopSongsPercentage: self.UserRecommended.TopSongsPercentage, TopAlbumsPercentage: self.UserRecommended.TopAlbumsPercentage)
                  }
                  // FOURTH LAYER (song/artist/similarArtist): library [rerun]
                  if(defaultChoice == AuxrRecommendNode.library){
                    self.GetMostMusicDataFrequentFromUserPlaylists()
                    var bound = self.UserLibraryPlaylists.count
                    let randPlaylistIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                    let playlist = self.UserLibraryPlaylists[randPlaylistIndex]
                    bound = playlist.AM_Songs.count
                    let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                    let selectedSong = playlist.AM_Songs[randSongIndex]
                    let am_song = try await self.ConvertSongID(SongID: selectedSong)
                    var rerunFlow = Flow
                    rerunFlow[0] = .rerun
                    return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                  }
                  // FOURTH LAYER (song/artist/similarArtist): queue [rerun]
                  if(defaultChoice == AuxrRecommendNode.queue){
                    self.GetMostFrequentMusicDataFromRoomQueue(Room: Room)
                    let bound = Room.Playlist.Queue.count
                    let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                    let selectedSong = Room.Playlist.Queue.sorted()[randSongIndex]
                    let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                    var rerunFlow = Flow
                    rerunFlow[0] = .rerun
                    return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                  }
                  // FOURTH LAYER (song/artist/similarArtist): history [rerun]
                  if(defaultChoice == AuxrRecommendNode.history){
                    self.GetMostFrequentMusicDataFromRoomHistory(Room: Room)
                    let bound = Room.Playlist.History.count
                    let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                    let selectedSong = Room.Playlist.History.sorted()[randSongIndex]
                    let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                    var rerunFlow = Flow
                    rerunFlow[0] = .rerun
                    return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                  }
                  // FOURTH LAYER (song/artist/similarArtist): likes [rerun]
                  if(defaultChoice == AuxrRecommendNode.likes){
                    self.GetMostFrequentMusicDataFromUserLikes(User: User, Room: Room)
                    let bound = User.Likes.count
                    let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                    let selectedSong = User.Likes.sorted()[randSongIndex]
                    let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                    var rerunFlow = Flow
                    rerunFlow[0] = .rerun
                    return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                  }
                  // FOURTH LAYER (song/artist/similarArtist): votes [rerun]
                  if(defaultChoice == AuxrRecommendNode.votes){
                    self.GetMostFrequentMusicDataFromUserVotes(User: User, Room: Room)
                    let bound = User.Votes.count
                    let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                    let selectedSong = User.Votes.sorted()[randSongIndex]
                    let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                    var rerunFlow = Flow
                    rerunFlow[0] = .rerun
                    return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                  }
                  else if(entryPoint == AuxrRecommendNode.rerun){
                    self.BackgroundSongSearchResult = []
                    self.BackgroundAlbumSearchResult = []
                    self.BackgroundArtistSearchResult = []
                    try await self.Search(Input: ParseArtistName(input: defaultSong?.artistName ?? "", getFirst: false) ?? "", Filter: SearchFilter.albums, Background: true)
                    if(!self.BackgroundAlbumSearchResult.isEmpty){
                      var sameGenreAlbums: [Album] = []
                      let genre = artist?.genreNames?.filter({ $0 != "Music" }).first ?? "Music"
                      for album in self.BackgroundAlbumSearchResult{ if(album.genreNames.contains(genre)){ sameGenreAlbums.append(album)} }
                      if(!sameGenreAlbums.isEmpty){
                        self.BackgroundSongSearchResult = []
                        self.BackgroundAlbumSearchResult = []
                        self.BackgroundArtistSearchResult = []
                        let topAlbumsBound = sameGenreAlbums.count
                        let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                        let randAlbum = sameGenreAlbums[randAlbumIndex]
                        self.BackgroundAlbumTracks = []
                        try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                        let albumTracks = self.BackgroundAlbumTracks
                        let tracksBound = albumTracks.count
                        let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                        let randTrack = albumTracks[randTrackIndex]
                        return randTrack.id.rawValue
                      }
                      else{
                        let albumsCount = self.BackgroundAlbumSearchResult.count
                        let randAlbumIndex = ((albumsCount > 1) ? Int.random(in: 0...albumsCount-1) : 0)
                        let randAlbum = self.BackgroundAlbumSearchResult[randAlbumIndex]
                        self.BackgroundAlbumTracks = []
                        try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                        let albumTracks = self.BackgroundAlbumTracks
                        let tracksBound = albumTracks.count
                        let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                        let randTrack = albumTracks[randTrackIndex]
                        return randTrack.id.rawValue
                      }
                    }
                  }
                  
                  var topChartsRequest = MusicCatalogChartsRequest(types: [Song.self, Album.self])
                  topChartsRequest.limit = 25
                  let topChartsResponse = try await topChartsRequest.response()
                  
                  // THIRD LAYER(artist/similarArtists): topSongs [genre]
                  if(defaultChoice == AuxrRecommendNode.topSongs){
                    var sameGenreSongs: [Song] = []
                    let topSongs = topChartsResponse.songCharts
                    for song in topSongs[0].items{ if(song.genreNames.contains(genre)){ sameGenreSongs.append(song)} }
                    if(!sameGenreSongs.isEmpty){
                      let topSongsBound = sameGenreSongs.count
                      let randSongIndex = ((topSongsBound > 1) ? Int.random(in: 0...topSongsBound-1) : 0)
                      let randSong = sameGenreSongs[randSongIndex]
                      return randSong.id.rawValue
                    }
                    else{
                      // THIRD LAYER(artist/similarArtists): topSongs [no genre]
                      let topSongsBound = topSongs[0].items.count
                      let randSongIndex = ((topSongsBound > 1) ? Int.random(in: 0...topSongsBound-1) : 0)
                      let randSong = topSongs[0].items[randSongIndex]
                      return randSong.id.rawValue
                    }
                  }
                  // THIRD LAYER(artist/similarArtists): topAlbums [genre]
                  if(defaultChoice == AuxrRecommendNode.topAlbums){
                    var sameGenreAlbums: [Album] = []
                    let topAlbums = topChartsResponse.albumCharts
                    for album in topAlbums[0].items{ if(album.genreNames.contains(genre)){ sameGenreAlbums.append(album)} }
                    if(!sameGenreAlbums.isEmpty){
                      self.BackgroundSongSearchResult = []
                      self.BackgroundAlbumSearchResult = []
                      self.BackgroundArtistSearchResult = []
                      let topAlbumsBound = sameGenreAlbums.count
                      let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                      let randAlbum = sameGenreAlbums[randAlbumIndex]
                      self.BackgroundAlbumTracks = []
                      try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                      let albumTracks = self.BackgroundAlbumTracks
                      let tracksBound = albumTracks.count
                      let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                      let randTrack = albumTracks[randTrackIndex]
                      return randTrack.id.rawValue
                    }
                    else{
                      // THIRD LAYER(artist/similarArtists): topAlbums [no genre]
                      let topAlbumsBound = topAlbums[0].items.count
                      let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                      let randAlbum = topAlbums[0].items[randAlbumIndex]
                      self.BackgroundAlbumTracks = []
                      try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                      let albumTracks = self.BackgroundAlbumTracks
                      let tracksBound = albumTracks.count
                      let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                      let randTrack = albumTracks[randTrackIndex]
                      return randTrack.id.rawValue
                    }
                  }
                }
              }
            }
            else{
              // THIRD LAYER(artist/similarArtists): rerun [default]
              if let genre = artist?.genreNames?.filter({ $0 != "Music" }).first{
                var defaultChoice = self.UserRecommended.initDefaultLayer(QueuePercentage: 0.0, LibraryPercentage: 0.0, HistoryPercentage: 0.0, LikesPercentage: 0.0, VotesPercentage: 0.0, TopSongsPercentage: 45.0, TopAlbumsPercentage: 55.0)
                if(entryPoint != .rerun){
                  if(entryPoint == AuxrRecommendNode.similarSongs){
                    return try await self.ConvertRecommendedFlowToSongID(defaultSong: defaultSong, User: User, Room: Room, Flow: Flow)
                  }
                  self.GetRerunFlowEntryPointPercentages(User: User, Room: Room)
                  defaultChoice = self.UserRecommended.initDefaultLayer(QueuePercentage: self.UserRecommended.QueuePercentage, LibraryPercentage: self.UserRecommended.LibraryPercentage, HistoryPercentage: self.UserRecommended.HistoryPercentage, LikesPercentage: self.UserRecommended.LikesPercentage, VotesPercentage: self.UserRecommended.VotesPercentage, TopSongsPercentage: self.UserRecommended.TopSongsPercentage, TopAlbumsPercentage: self.UserRecommended.TopAlbumsPercentage)
                }
                // FOURTH LAYER (song/artist/similarArtist): library [rerun]
                if(defaultChoice == AuxrRecommendNode.library){
                  self.GetMostMusicDataFrequentFromUserPlaylists()
                  var bound = self.UserLibraryPlaylists.count
                  let randPlaylistIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                  let playlist = self.UserLibraryPlaylists[randPlaylistIndex]
                  bound = playlist.AM_Songs.count
                  let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                  let selectedSong = playlist.AM_Songs[randSongIndex]
                  let am_song = try await self.ConvertSongID(SongID: selectedSong)
                  var rerunFlow = Flow
                  rerunFlow[0] = .rerun
                  return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                }
                // FOURTH LAYER (song/artist/similarArtist): queue [rerun]
                if(defaultChoice == AuxrRecommendNode.queue){
                  self.GetMostFrequentMusicDataFromRoomQueue(Room: Room)
                  let bound = Room.Playlist.Queue.count
                  let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                  let selectedSong = Room.Playlist.Queue.sorted()[randSongIndex]
                  let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                  var rerunFlow = Flow
                  rerunFlow[0] = .rerun
                  return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                }
                // FOURTH LAYER (song/artist/similarArtist): history [rerun]
                if(defaultChoice == AuxrRecommendNode.history){
                  self.GetMostFrequentMusicDataFromRoomHistory(Room: Room)
                  let bound = Room.Playlist.History.count
                  let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                  let selectedSong = Room.Playlist.History.sorted()[randSongIndex]
                  let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                  var rerunFlow = Flow
                  rerunFlow[0] = .rerun
                  return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                }
                // FOURTH LAYER (song/artist/similarArtist): likes [rerun]
                if(defaultChoice == AuxrRecommendNode.likes){
                  self.GetMostFrequentMusicDataFromUserLikes(User: User, Room: Room)
                  let bound = User.Likes.count
                  let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                  let selectedSong = User.Likes.sorted()[randSongIndex]
                  let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                  var rerunFlow = Flow
                  rerunFlow[0] = .rerun
                  return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                }
                // FOURTH LAYER (song/artist/similarArtist): votes [rerun]
                if(defaultChoice == AuxrRecommendNode.votes){
                  self.GetMostFrequentMusicDataFromUserVotes(User: User, Room: Room)
                  let bound = User.Votes.count
                  let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                  let selectedSong = User.Votes.sorted()[randSongIndex]
                  let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                  var rerunFlow = Flow
                  rerunFlow[0] = .rerun
                  return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
                }
                else if(entryPoint == AuxrRecommendNode.rerun){
                  self.BackgroundSongSearchResult = []
                  self.BackgroundAlbumSearchResult = []
                  self.BackgroundArtistSearchResult = []
                  try await self.Search(Input: ParseArtistName(input: defaultSong?.artistName ?? "", getFirst: false) ?? "", Filter: SearchFilter.albums, Background: true)
                  if(!self.BackgroundAlbumSearchResult.isEmpty){
                    var sameGenreAlbums: [Album] = []
                    let genre = artist?.genreNames?.filter({ $0 != "Music" }).first ?? "Music"
                    for album in self.BackgroundAlbumSearchResult{ if(album.genreNames.contains(genre)){ sameGenreAlbums.append(album)} }
                    if(!sameGenreAlbums.isEmpty){
                      self.BackgroundSongSearchResult = []
                      self.BackgroundAlbumSearchResult = []
                      self.BackgroundArtistSearchResult = []
                      let topAlbumsBound = sameGenreAlbums.count
                      let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                      let randAlbum = sameGenreAlbums[randAlbumIndex]
                      self.BackgroundAlbumTracks = []
                      try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                      let albumTracks = self.BackgroundAlbumTracks
                      let tracksBound = albumTracks.count
                      let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                      let randTrack = albumTracks[randTrackIndex]
                      return randTrack.id.rawValue
                    }
                    else{
                      let albumsCount = self.BackgroundAlbumSearchResult.count
                      let randAlbumIndex = ((albumsCount > 1) ? Int.random(in: 0...albumsCount-1) : 0)
                      let randAlbum = self.BackgroundAlbumSearchResult[randAlbumIndex]
                      self.BackgroundAlbumTracks = []
                      try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                      let albumTracks = self.BackgroundAlbumTracks
                      let tracksBound = albumTracks.count
                      let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                      let randTrack = albumTracks[randTrackIndex]
                      return randTrack.id.rawValue
                    }
                  }
                }
                
                var topChartsRequest = MusicCatalogChartsRequest(types: [Song.self, Album.self])
                topChartsRequest.limit = 25
                let topChartsResponse = try await topChartsRequest.response()
                
                // THIRD LAYER(artist/similarArtists): topSongs [genre]
                if(defaultChoice == AuxrRecommendNode.topSongs){
                  var sameGenreSongs: [Song] = []
                  let topSongs = topChartsResponse.songCharts
                  for song in topSongs[0].items{ if(song.genreNames.contains(genre)){ sameGenreSongs.append(song)} }
                  if(!sameGenreSongs.isEmpty){
                    let topSongsBound = sameGenreSongs.count
                    let randSongIndex = ((topSongsBound > 1) ? Int.random(in: 0...topSongsBound-1) : 0)
                    let randSong = sameGenreSongs[randSongIndex]
                    return randSong.id.rawValue
                  }
                  else{
                    // THIRD LAYER(artist/similarArtists): topSongs [no genre]
                    let topSongsBound = topSongs[0].items.count
                    let randSongIndex = ((topSongsBound > 1) ? Int.random(in: 0...topSongsBound-1) : 0)
                    let randSong = topSongs[0].items[randSongIndex]
                    return randSong.id.rawValue
                  }
                }
                // THIRD LAYER(artist/similarArtists): topAlbums [genre]
                if(defaultChoice == AuxrRecommendNode.topAlbums){
                  var sameGenreAlbums: [Album] = []
                  let topAlbums = topChartsResponse.albumCharts
                  for album in topAlbums[0].items{ if(album.genreNames.contains(genre)){ sameGenreAlbums.append(album)} }
                  if(!sameGenreAlbums.isEmpty){
                    self.BackgroundSongSearchResult = []
                    self.BackgroundAlbumSearchResult = []
                    self.BackgroundArtistSearchResult = []
                    let topAlbumsBound = sameGenreAlbums.count
                    let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                    let randAlbum = sameGenreAlbums[randAlbumIndex]
                    self.BackgroundAlbumTracks = []
                    try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                    let albumTracks = self.BackgroundAlbumTracks
                    let tracksBound = albumTracks.count
                    let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                    let randTrack = albumTracks[randTrackIndex]
                    return randTrack.id.rawValue
                  }
                  else{
                    // THIRD LAYER(artist/similarArtists): topAlbums [no genre]
                    let topAlbumsBound = topAlbums[0].items.count
                    let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                    let randAlbum = topAlbums[0].items[randAlbumIndex]
                    self.BackgroundAlbumTracks = []
                    try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                    let albumTracks = self.BackgroundAlbumTracks
                    let tracksBound = albumTracks.count
                    let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                    let randTrack = albumTracks[randTrackIndex]
                    return randTrack.id.rawValue
                  }
                }
              }
            }
          }
          // THIRD LAYER(artist): topSong
          if(Flow[2] == AuxrRecommendNode.topSongs){
            self.BackgroundSongSearchResult = []
            self.BackgroundAlbumSearchResult = []
            self.BackgroundArtistSearchResult = []
            try await self.Search(Input: artistName, Filter: .songs, Background: true)
            if(!self.BackgroundSongSearchResult.isEmpty){
              var sameGenreSongs: [Song] = []
              if let genre = song?.genreNames.filter({ $0 != "Music"}).first{
                for song in self.BackgroundSongSearchResult{ if(song.genreNames.contains(genre)){ sameGenreSongs.append(song)} }
                if(!sameGenreSongs.isEmpty){
                  let songsBound = sameGenreSongs.count
                  let randSongIndex = ((songsBound > 1) ? Int.random(in: 0...songsBound-1) : 0)
                  let randSong = sameGenreSongs[randSongIndex]
                  return randSong.id.rawValue
                }
                else{
                  // FOURTH LAYER (song/artist/similarArtist): topSongs [no genre]
                  let songsBound = self.BackgroundSongSearchResult.count
                  let randSongIndex = ((songsBound > 1) ? Int.random(in: 0...songsBound-1) : 0)
                  let randSong = self.BackgroundSongSearchResult[randSongIndex]
                  return randSong.id.rawValue
                }
              }
            }
          }
          // THIRD LAYER(artist): topAlbums
          else if(Flow[2] == AuxrRecommendNode.topAlbums){
            self.BackgroundSongSearchResult = []
            self.BackgroundAlbumSearchResult = []
            self.BackgroundArtistSearchResult = []
            try await self.Search(Input: artistName, Filter: SearchFilter.albums, Background: true)
            if(!self.BackgroundAlbumSearchResult.isEmpty){
              var sameGenreAlbums: [Album] = []
              let genre = artist?.genreNames?.filter({ $0 != "Music" }).first ?? "Music"
              for album in self.BackgroundAlbumSearchResult{ if(album.genreNames.contains(genre)){ sameGenreAlbums.append(album)} }
              if(!sameGenreAlbums.isEmpty){
                self.BackgroundSongSearchResult = []
                self.BackgroundAlbumSearchResult = []
                self.BackgroundArtistSearchResult = []
                let topAlbumsBound = sameGenreAlbums.count
                let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                let randAlbum = sameGenreAlbums[randAlbumIndex]
                self.BackgroundAlbumTracks = []
                try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                let albumTracks = self.BackgroundAlbumTracks
                let tracksBound = albumTracks.count
                let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                let randTrack = albumTracks[randTrackIndex]
                return randTrack.id.rawValue
              }
              else{
                // FOURTH LAYER (song/artist/similarArtist): topAlbums [no genre]
                let topAlbumsBound = self.BackgroundAlbumSearchResult.count
                let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                let randAlbum = self.BackgroundAlbumSearchResult[randAlbumIndex]
                self.BackgroundAlbumTracks = []
                try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                let albumTracks = self.BackgroundAlbumTracks
                let tracksBound = albumTracks.count
                let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                let randTrack = albumTracks[randTrackIndex]
                return randTrack.id.rawValue
              }
            }
          }
          // THIRD LAYER(artist): latestReleases
          else if(Flow[2] == AuxrRecommendNode.latestRelease){
            if let latestRelease = artist?.latestRelease{
              try await self.GetAlbumTracks(Album: latestRelease, Background: true)
              self.BackgroundAlbumTracks = []
              let albumTracks = self.BackgroundAlbumTracks
              let tracksBound = albumTracks.count
              let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
              let randTrack = albumTracks[randTrackIndex]
              return randTrack.id.rawValue
            }
          }
          else{
            // THIRD LAYER(artist): genreNames
            if let genre = artist?.genreNames?.filter({ $0 != "Music" }).first{
              var defaultChoice = self.UserRecommended.initDefaultLayer(QueuePercentage: 0.0, LibraryPercentage: 0.0, HistoryPercentage: 0.0, LikesPercentage: 0.0, VotesPercentage: 0.0, TopSongsPercentage: 45.0, TopAlbumsPercentage: 55.0)
              if(entryPoint != .rerun){
                if(entryPoint == AuxrRecommendNode.similarSongs){
                  return try await self.ConvertRecommendedFlowToSongID(defaultSong: defaultSong, User: User, Room: Room, Flow: Flow)
                }
                self.GetRerunFlowEntryPointPercentages(User: User, Room: Room)
                defaultChoice = self.UserRecommended.initDefaultLayer(QueuePercentage: self.UserRecommended.QueuePercentage, LibraryPercentage: self.UserRecommended.LibraryPercentage, HistoryPercentage: self.UserRecommended.HistoryPercentage, LikesPercentage: self.UserRecommended.LikesPercentage, VotesPercentage: self.UserRecommended.VotesPercentage, TopSongsPercentage: self.UserRecommended.TopSongsPercentage, TopAlbumsPercentage: self.UserRecommended.TopAlbumsPercentage)
              }
              // FOURTH LAYER (song/artist/similarArtist): library [rerun]
              if(defaultChoice == AuxrRecommendNode.library){
                self.GetMostMusicDataFrequentFromUserPlaylists()
                var bound = self.UserLibraryPlaylists.count
                let randPlaylistIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                let playlist = self.UserLibraryPlaylists[randPlaylistIndex]
                bound = playlist.AM_Songs.count
                let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                let selectedSong = playlist.AM_Songs[randSongIndex]
                let am_song = try await self.ConvertSongID(SongID: selectedSong)
                var rerunFlow = Flow
                rerunFlow[0] = .rerun
                return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
              }
              // FOURTH LAYER (song/artist/similarArtist): queue [rerun]
              if(defaultChoice == AuxrRecommendNode.queue){
                self.GetMostFrequentMusicDataFromRoomQueue(Room: Room)
                let bound = Room.Playlist.Queue.count
                let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                let selectedSong = Room.Playlist.Queue.sorted()[randSongIndex]
                let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                var rerunFlow = Flow
                rerunFlow[0] = .rerun
                return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
              }
              // FOURTH LAYER (song/artist/similarArtist): history [rerun]
              if(defaultChoice == AuxrRecommendNode.history){
                self.GetMostFrequentMusicDataFromRoomHistory(Room: Room)
                let bound = Room.Playlist.History.count
                let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                let selectedSong = Room.Playlist.History.sorted()[randSongIndex]
                let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                var rerunFlow = Flow
                rerunFlow[0] = .rerun
                return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
              }
              // FOURTH LAYER (song/artist/similarArtist): likes [rerun]
              if(defaultChoice == AuxrRecommendNode.likes){
                self.GetMostFrequentMusicDataFromUserLikes(User: User, Room: Room)
                let bound = User.Likes.count
                let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                let selectedSong = User.Likes.sorted()[randSongIndex]
                let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                var rerunFlow = Flow
                rerunFlow[0] = .rerun
                return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
              }
              // FOURTH LAYER (song/artist/similarArtist): votes [rerun]
              if(defaultChoice == AuxrRecommendNode.votes){
                self.GetMostFrequentMusicDataFromUserVotes(User: User, Room: Room)
                let bound = User.Votes.count
                let randSongIndex = ((bound > 1) ? Int.random(in: 0...bound-1) : 0)
                let selectedSong = User.Votes.sorted()[randSongIndex]
                let am_song = try await self.ConvertSong(AuxrSong: selectedSong)
                var rerunFlow = Flow
                rerunFlow[0] = .rerun
                return try await self.ConvertRecommendedFlowToSongID(defaultSong: am_song, User: User, Room: Room, Flow: rerunFlow)
              }
              else if(entryPoint == AuxrRecommendNode.rerun){
                self.BackgroundSongSearchResult = []
                self.BackgroundAlbumSearchResult = []
                self.BackgroundArtistSearchResult = []
                try await self.Search(Input: ParseArtistName(input: defaultSong?.artistName ?? "", getFirst: false) ?? "", Filter: SearchFilter.albums, Background: true)
                if(!self.BackgroundAlbumSearchResult.isEmpty){
                  var sameGenreAlbums: [Album] = []
                  let genre = artist?.genreNames?.filter({ $0 != "Music" }).first ?? "Music"
                  for album in self.BackgroundAlbumSearchResult{ if(album.genreNames.contains(genre)){ sameGenreAlbums.append(album)} }
                  if(!sameGenreAlbums.isEmpty){
                    self.BackgroundSongSearchResult = []
                    self.BackgroundAlbumSearchResult = []
                    self.BackgroundArtistSearchResult = []
                    let topAlbumsBound = sameGenreAlbums.count
                    let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                    let randAlbum = sameGenreAlbums[randAlbumIndex]
                    self.BackgroundAlbumTracks = []
                    try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                    let albumTracks = self.BackgroundAlbumTracks
                    let tracksBound = albumTracks.count
                    let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                    let randTrack = albumTracks[randTrackIndex]
                    return randTrack.id.rawValue
                  }
                  else{
                    let albumsCount = self.BackgroundAlbumSearchResult.count
                    let randAlbumIndex = ((albumsCount > 1) ? Int.random(in: 0...albumsCount-1) : 0)
                    let randAlbum = self.BackgroundAlbumSearchResult[randAlbumIndex]
                    self.BackgroundAlbumTracks = []
                    try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                    let albumTracks = self.BackgroundAlbumTracks
                    let tracksBound = albumTracks.count
                    let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                    let randTrack = albumTracks[randTrackIndex]
                    return randTrack.id.rawValue
                  }
                }
              }
              
              var topChartsRequest = MusicCatalogChartsRequest(types: [Song.self, Album.self])
              topChartsRequest.limit = 25
              let topChartsResponse = try await topChartsRequest.response()
              
              // THIRD LAYER(artist): topSongs [genre]
              if(defaultChoice == AuxrRecommendNode.topSongs){
                var sameGenreSongs: [Song] = []
                let topSongs = topChartsResponse.songCharts
                for song in topSongs[0].items{ if(song.genreNames.contains(genre)){ sameGenreSongs.append(song)} }
                if(!sameGenreSongs.isEmpty){
                  let topSongsBound = sameGenreSongs.count
                  let randSongIndex = ((topSongsBound > 1) ? Int.random(in: 0...topSongsBound-1) : 0)
                  let randSong = sameGenreSongs[randSongIndex]
                  return randSong.id.rawValue
                }
                else{
                  // THIRD LAYER(artist): topSongs [no genre]
                  let topSongsBound = topSongs[0].items.count
                  let randSongIndex = ((topSongsBound > 1) ? Int.random(in: 0...topSongsBound-1) : 0)
                  let randSong = topSongs[0].items[randSongIndex]
                  return randSong.id.rawValue
                }
              }
              // THIRD LAYER(artist): topAlbums [genre]
              if(defaultChoice == AuxrRecommendNode.topAlbums){
                var sameGenreAlbums: [Album] = []
                let topAlbums = topChartsResponse.albumCharts
                for album in topAlbums[0].items{ if(album.genreNames.contains(genre)){ sameGenreAlbums.append(album)} }
                if(!sameGenreAlbums.isEmpty){
                  self.BackgroundSongSearchResult = []
                  self.BackgroundAlbumSearchResult = []
                  self.BackgroundArtistSearchResult = []
                  let topAlbumsBound = sameGenreAlbums.count
                  let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                  let randAlbum = sameGenreAlbums[randAlbumIndex]
                  self.BackgroundAlbumTracks = []
                  try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                  let albumTracks = self.BackgroundAlbumTracks
                  let tracksBound = albumTracks.count
                  let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                  let randTrack = albumTracks[randTrackIndex]
                  return randTrack.id.rawValue
                }
                else{
                  // THIRD LAYER(artist): topAlbums [no genre]
                  let topAlbumsBound = topAlbums[0].items.count
                  let randAlbumIndex = ((topAlbumsBound > 1) ? Int.random(in: 0...topAlbumsBound-1) : 0)
                  let randAlbum = topAlbums[0].items[randAlbumIndex]
                  self.BackgroundAlbumTracks = []
                  try await self.GetAlbumTracks(Album: randAlbum, Background: true)
                  let albumTracks = self.BackgroundAlbumTracks
                  let tracksBound = albumTracks.count
                  let randTrackIndex = ((tracksBound > 1) ? Int.random(in: 0...tracksBound-1) : 0)
                  let randTrack = albumTracks[randTrackIndex]
                  return randTrack.id.rawValue
                }
              }
            }
          }
        }
      }
      return nil
    }
    return nil
  }
  
  // MARK: Reset Player Handler
  @MainActor
  func PlayerReset() async throws {
    self.player.stop()
    self.player.queue.entries = []
    self.player.queue.currentEntry = nil
    self.Queue = []
  }
  
  // MARK: Apple Music Reset
  @MainActor
  func Reset() async throws {
    self.Authorized = .notDetermined
    self.CheckedForSubscription = false
    self.Subscription = AppleMusicSubscriptionStatus.notChecked
    self.UserLibraryPlaylists = []
    self.AccountLikes = []
    self.UserRecommended = try await self.UserRecommended.Reset()
    self.SongSearchResult = []
    self.AlbumSearchResult = []
    self.BackgroundArtistSearchResult = []
    self.AlbumTracks = []
    self.BackgroundSongSearchResult = []
    self.BackgroundAlbumSearchResult = []
    self.BackgroundArtistSearchResult = []
    self.BackgroundAlbumTracks = []
    self.RecentSearches = []
    self.Queue = []
  }
}
