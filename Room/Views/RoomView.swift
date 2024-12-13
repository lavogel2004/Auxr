import SwiftUI
import MessageUI
import MusicKit
import OSLog

struct RoomView: View {
  @Environment(\.scenePhase) var scenePhase
  @EnvironmentObject var router: Router
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  // MARK: Search
  let srch: Search = Search()
  @State private var  SearchInput: String = ""
  @State private var StartSearch: Bool = false
  @State private var Filter: SearchFilter = SearchFilter.songs
  @State private var Searching: Bool = false
  @State private var Submitted: Bool = true
  @State private var Animate: Bool = false
  @State private var Completed: Bool = false
  @State private var ShowSubSearch: Bool = false
  
  // MARK: Controls
  @State private var CurrentSongText: String = "No Song Playing"
  @State private var CurrentSong: AuxrSong = AuxrSong()
  @State private var ShowCurrentSong: Bool = false
  @State private var CurrentSongViewActive: Bool = false
  @State private var ShowSimilarSongs: Bool = false
  
  // MARK: Helpers
  @State private var ShowOfflineOverlay: Bool = false
  @State private var ShowMenuOverlay: Bool = false
  @State private var ShowListenersOverlay: Bool = false
  @State private var Share: Bool = false
  @State private var ShowFriendPopover: Bool = false
  @State private var OtherShareOptions: Bool = false
  @State private var ShowCopyOverlay: Bool = false
  @State private var ShowNoControlsOverlay: Bool = false
  @State private var ShowPlayOverlay: Bool = false
  @State private var ShowPauseOverlay: Bool = false
  @State private var ShowSkipOverlay: Bool = false
  @State private var ShowRemoveOverlay: Bool = false
  @State private var ShowLikeOverlay: Bool = false
  @State private var ShowUpvoteOverlay: Bool = false
  @State private var ShowDownvoteOverlay: Bool = false
  @State private var ShowUpNextOverlay: Bool = false
  @State private var ShowNoSongOverlay: Bool = false
  @State private var GoToAccountView: Bool = false
  @State private var SwipeLeftGesture: Bool = false
  @State private var SwipeRightGesture: Bool = false
  @State private var navigated: Bool = false
  @State private var presented: Bool = false
  @State private var noop: Bool = false
  @State private var refreshing: Bool = false
  
  init(){
    UITableView.appearance().backgroundColor = UIColor(Color("Primary"))
    UIScrollView.appearance().bounces = false
  }
  
  var body: some View {
    ZStack{
      Color("Primary").edgesIgnoringSafeArea(.all)
      Image("LogoNoText")
        .resizable()
        .frame(width: UIScreen.main.bounds.size.width*0.41, height: UIScreen.main.bounds.size.width*0.41)
        .opacity(0.3)
      if(ShowOfflineOverlay){ OfflineOverlay(networkStatus: NetworkStatus.notConnected, Show: $ShowOfflineOverlay) }
      if(Share){ ShareOverlay(Passcode: room.Passcode, Show: $Share, Copied: $ShowCopyOverlay, ShowFriendPopover: $ShowFriendPopover, OtherOptions: $OtherShareOptions) }
      
      ZStack{
        if(ShowNoControlsOverlay){ GeneralOverlay(type: GeneralOverlayType.noControls, Show: $ShowNoControlsOverlay) }
        else if(ShowPlayOverlay){ GeneralOverlay(type: GeneralOverlayType.play, Show: $ShowPlayOverlay) }
        else if(ShowPauseOverlay){ GeneralOverlay(type: GeneralOverlayType.pause, Show: $ShowPauseOverlay) }
        else if(ShowSkipOverlay){ GeneralOverlay(type: GeneralOverlayType.skip, Show: $ShowSkipOverlay) }
        else if(ShowRemoveOverlay){ GeneralOverlay(type: GeneralOverlayType.remove, Show: $ShowRemoveOverlay) }
        else if(ShowLikeOverlay){ GeneralOverlay(type: GeneralOverlayType.like, Show: $ShowLikeOverlay) }
        else if(ShowUpvoteOverlay){ GeneralOverlay(type: GeneralOverlayType.upvote, Show: $ShowUpvoteOverlay) }
        else if(ShowDownvoteOverlay){ GeneralOverlay(type: GeneralOverlayType.downvote, Show: $ShowDownvoteOverlay) }
        else if(ShowUpNextOverlay){ GeneralOverlay(type: .upNext, Show: $ShowUpNextOverlay) }
        else if(ShowNoSongOverlay){ GeneralOverlay(type: GeneralOverlayType.noSong, Show: $ShowNoSongOverlay) }
        else if(ShowCopyOverlay){ GeneralOverlay(type: GeneralOverlayType.copy, Show: $ShowCopyOverlay) }
        
        // MARK: Menu
        ZStack{
          MenuView(Share: $Share, RecentSearch: $ShowSubSearch)
            .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
        }
        .offset(y: -UIScreen.main.bounds.size.height*0.41)
        
        // MARK: Search
        ZStack{
          SearchBarView(Input: $SearchInput, Filter: $Filter)
            .onTapGesture { ShowSubSearch = true }
            .onSubmit{
              StartSearch = true
              let networkStatus: NetworkStatus = CheckNetworkStatus()
              if(networkStatus == NetworkStatus.reachable){
                Task{
                  Searching = true
                  Completed = false
                  Animate = false
                  srch.Reset(Room: room, AppleMusic: appleMusic)
                  try await srch.SearchMusic(Room: room, AppleMusic: appleMusic, Input: SearchInput, Filter: Filter)
                  if(!SearchInput.isEmpty){
                    if(room.MusicService == "AppleMusic"){
                      if(!appleMusic.RecentSearches.contains(SearchInput)){
                        appleMusic.RecentSearches.append(SearchInput)
                        if(appleMusic.RecentSearches.count > 6){ appleMusic.RecentSearches.removeFirst() }
                      }
                    }
                  }
                }
              }
            }
        }
        .offset(y: -UIScreen.main.bounds.size.height*0.36)
        
        // MARK: SubSearch
        if(ShowSubSearch){
          ZStack{
            SubSearchView(Show: $ShowSubSearch, StartSearch: $StartSearch, Input: $SearchInput, Filter: $Filter, Searching: $Searching, Completed: $Completed, Queued: $noop, MaxSongs: $noop,  Offline: $ShowOfflineOverlay)
          }
          .offset(y: -UIScreen.main.bounds.size.height*0.05)
        }
        
        // MARK: Playlist
        ZStack{
          if(!ShowSubSearch){
            VStack(alignment: .center){
              PlaylistView(Remove: $ShowRemoveOverlay, Like: $ShowLikeOverlay, Upvote: $ShowUpvoteOverlay, Downvote: $ShowDownvoteOverlay, PlayNow: $ShowPlayOverlay, UpNext: $ShowUpNextOverlay, NoSong: $ShowNoSongOverlay, Offline: $ShowOfflineOverlay, Refreshing: $refreshing)
            }
            .zIndex(2)
          }
        }
        .frame(maxHeight: UIScreen.main.bounds.size.height*0.65, alignment: .top)
        
        // MARK: Controls
        ZStack{
          ControlsView(Share: $Share, NoControls: $ShowNoControlsOverlay, Playing: $ShowPlayOverlay, Paused: $ShowPauseOverlay, Skipped: $ShowSkipOverlay, NoSong: $ShowNoSongOverlay, CurrentSong: $CurrentSong, CurrentSongText: $CurrentSongText, ShowCurrentSong: $ShowCurrentSong, Offline: $ShowOfflineOverlay)
        }
        .offset(y: UIScreen.main.bounds.size.height*0.5)
        .zIndex(3)
        
        // MARK: Search Swipe Navigation
        if(StartSearch){
          NavigationLink(value: router.search){ Spacer().frame(height: 1) }
            .onAppear{
              router.currPath = router.search.path
              presented = true
            }
            .navigationDestination(isPresented: $presented){ SearchMusicView(StartSearch: $StartSearch, SearchInput: $SearchInput, Filter: $Filter, Searching: $Searching, Completed: $Completed, ShowCurrentSong: $ShowCurrentSong) }
        }
        
        if(ShowSimilarSongs){
          NavigationLink(value: router.similarSongs){ Spacer().frame(height: 1) }
            .onAppear{
              router.currPath = router.similarSongs.path
              Task{
                if(appleMusic.UserRecommended.SimilarSongs.isEmpty &&
                   !appleMusic.UserRecommended.GeneratingSimilar &&
                   !room.Playlist.Queue.isEmpty){
                  appleMusic.UserRecommended.GeneratingSimilar = true
                  let AM_Song = try await appleMusic.ConvertSong(AuxrSong: CurrentSong)
                  guard (appleMusic.UserRecommended.GeneratingSimilar) else{ return }
                  try await appleMusic.GenerateSimilarSongs(User: user, Room: room, howMany: 10, attempts: 30, SelectedSong: AM_Song)
                }
              }
              presented = true
            }
            .navigationDestination(isPresented: $presented){ SimilarSongsView(Song: $CurrentSong, Show: $ShowSimilarSongs, ShowCurrentSong: $ShowCurrentSong) }
          
          if(GoToAccountView){
            if let acct: AuxrAccount = user.Account{
              NavigationLink(value: router.account){ Spacer().frame(height: 1) }
                .onAppear{
                  router.currPath = router.account.path
                  presented = true
                }
                .navigationDestination(isPresented: $presented){ AccountView().environmentObject(acct) }
            }
          }
        }
      }
    }
    .frame(maxHeight: UIScreen.main.bounds.size.height, alignment: .top)
    .navigationBarHidden(true)
    .ignoresSafeArea(.keyboard, edges: .all)
    .popover(isPresented: $ShowCurrentSong){
      CurrentSongView(Song: $CurrentSong, Show: $ShowCurrentSong, Active: $CurrentSongViewActive, StartSearch: $StartSearch, SearchInput: $SearchInput, Filter: $Filter, Searching: $Searching, Completed: $Completed, SimilarSongs: $ShowSimilarSongs)
        .onAppear{ CurrentSongViewActive = true }
    }
    .popover(isPresented: $ShowFriendPopover){
      if let account: AuxrAccount = user.Account{
        FriendInvitePopover(RoomID: room.ID, Show: $ShowFriendPopover, ShowOtherOptions: $OtherShareOptions, ShowShareOverlay: $Share).environmentObject(account)
          .onAppear{ Share = false }
      }
    }
    .task{
      // MARK: Firebase Listener [Room Updates]
      FirebaseManager.GetRoomUpdates(room: room, completion: { UpdatedRoom, Status in
        Logger.room.log("[Room View] GetRoomUpdates")
        Task{
          if(Status == "success"){
            if(!UpdatedRoom.SwappingHost){
              if(!UpdatedRoom.Creator(User: user)){
                if(!UpdatedRoom.Guest(User: user)){
                  if(!UpdatedRoom.Host(User: user)){
                    try await room.Disconnect(User: user, AppleMusic: appleMusic, Router: router)
                  }
                }
              }
            }
            
            if(room.Creator.InRoom != UpdatedRoom.Creator.InRoom){
              room.Creator.InRoom = UpdatedRoom.Creator.InRoom
            }
            if(room.Host.InRoom != UpdatedRoom.Host.InRoom){
              room.Host.InRoom = UpdatedRoom.Host.InRoom
            }
            
            if let i: Int = UpdatedRoom.Guests.firstIndex(where: {
              $0.pai == user.pai }){
              if(user.PlayPausePermission != UpdatedRoom.Guests[i].PlayPausePermission){
                user.PlayPausePermission = UpdatedRoom.Guests[i].PlayPausePermission
              }
              if(user.RemovePermission != UpdatedRoom.Guests[i].RemovePermission){
                user.RemovePermission = UpdatedRoom.Guests[i].RemovePermission
              }
              if(user.SkipPermission != UpdatedRoom.Guests[i].SkipPermission){
                user.SkipPermission = UpdatedRoom.Guests[i].SkipPermission
              }
            }
            else if let i: Int = UpdatedRoom.Guests.firstIndex(where: {
              $0.token == user.token }){
              if(user.PlayPausePermission != UpdatedRoom.Guests[i].PlayPausePermission){
                user.PlayPausePermission = UpdatedRoom.Guests[i].PlayPausePermission
              }
              if(user.RemovePermission != UpdatedRoom.Guests[i].RemovePermission){
                user.RemovePermission = UpdatedRoom.Guests[i].RemovePermission
              }
              if(user.SkipPermission != UpdatedRoom.Guests[i].SkipPermission){
                user.SkipPermission = UpdatedRoom.Guests[i].SkipPermission
              }
            }
            
            // MARK: Add Song Update
            if(room.AddSong){
              if(!room.Playlist.LocalAdd.isEmpty){
                room.GlobalPlaylistIndex = UpdatedRoom.GlobalPlaylistIndex
                try await room.Playlist.MoveLocalAdd(Room: room)
              }
              room.AddSong = false
            }
            
            // MARK: Playlist Queue Update
            if(((room.Playlist.Queue.count != UpdatedRoom.Playlist.Queue.count) && !room.SongControlled) ||
               (room.Refreshing && !room.SongControlled && !room.Voting)){
              if(room.Playlist.Queue != UpdatedRoom.Playlist.Queue){
                room.Playlist.Queue = UpdatedRoom.Playlist.Queue.sorted()
              }
              if((room.Playlist.History.count != UpdatedRoom.Playlist.History.count)){ room.Playlist.History = UpdatedRoom.Playlist.History.sorted() }
              room.GlobalPlaylistIndex = UpdatedRoom.GlobalPlaylistIndex
              room.GlobalPlaylistIndex2 = UpdatedRoom.GlobalPlaylistIndex2
              for song in room.Playlist.Queue.sorted(){
                if(!user.Votes.isEmpty){
                  if let i: Int = user.Votes.firstIndex(where: { $0.ID == song.ID }){ user.Votes[i] = song}
                }
                if(!user.Likes.isEmpty){
                  if let i: Int = user.Likes.firstIndex(where: { $0.ID == song.ID }){ user.Likes[i] = song }
                }
              }
            }
            
            // MARK: Update Current Song Display
            if(!room.Playlist.Queue.isEmpty){ CurrentSongText = room.Playlist.Queue.sorted()[0].Title + " - " + room.Playlist.Queue.sorted()[0].Artist }
            
            // MARK: Up Next Update
            if(room.UpNext){
              room.Playlist.Queue = UpdatedRoom.Playlist.Queue.sorted()
              room.GlobalPlaylistIndex = UpdatedRoom.GlobalPlaylistIndex
              room.UpNext = false
              try await FirebaseManager.UpdateRoomUpNext(Room: room)
              for song in room.Playlist.Queue.sorted(){
                if(!user.Votes.isEmpty){
                  if let i: Int = user.Votes.firstIndex(where: { $0.ID == song.ID }){ user.Votes[i] = song}
                }
                if(!user.Likes.isEmpty){
                  if let i: Int = user.Likes.firstIndex(where: { $0.ID == song.ID }){ user.Likes[i] = song }
                }
              }
            }
            
            // MARK: Vote Update
            if(room.GlobalVoteCount != UpdatedRoom.GlobalVoteCount){
              room.GlobalVoteCount = UpdatedRoom.GlobalVoteCount
              room.Playlist.Queue = UpdatedRoom.Playlist.Queue.sorted()
              if((room.Playlist.History.count != UpdatedRoom.Playlist.History.count)){ room.Playlist.History = UpdatedRoom.Playlist.History.sorted() }
              if(room.Host(User: user)){
                if(appleMusic.player.state.playbackStatus == .playing){
                  if(room.Playlist.Queue.sorted()[0].AppleMusic != appleMusic.player.queue.currentEntry?.item?.id.rawValue){
                    room.Controlled = true
                    try await FirebaseManager.UpdateRoomControlled(Room: room)
                    room.Playlist.QueueInitializing = true
                    try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: room)
                    try await appleMusic.PlayerInit(Room: room)
                    room.Controlled = false
                    try await FirebaseManager.UpdateRoomControlled(Room: room)
                  }
                }
              }
              for song in room.Playlist.Queue.sorted(){
                if(!user.Votes.isEmpty){
                  if let i: Int = user.Votes.firstIndex(where: { $0.ID == song.ID }){ user.Votes[i] = song }
                }
                if(!user.Likes.isEmpty){
                  if let i: Int = user.Likes.firstIndex(where: { $0.ID == song.ID }){ user.Likes[i] = song }
                }
              }
            }
            
            // MARK: Playlist History Update
            if((room.Playlist.History.count != UpdatedRoom.Playlist.History.count)){ room.Playlist.History = UpdatedRoom.Playlist.History.sorted() }
            
            //MARK: Total Playtime Update
            if(room.Playlist.TotalPlaytime != UpdatedRoom.Playlist.TotalPlaytime){ room.Playlist.TotalPlaytime = UpdatedRoom.Playlist.TotalPlaytime }
            
            // MARK: Queue Initializing Update
            if(room.Playlist.QueueInitializing != UpdatedRoom.Playlist.QueueInitializing){ room.Playlist.QueueInitializing = UpdatedRoom.Playlist.QueueInitializing }
            
            // MARK: General Room Updates
            try await room.GeneralReplace(Room: UpdatedRoom)
            
            // MARK: Account Channel Updates
            //try await AccountManager.updateChannel(user: user, room: room)
          }
          else{
            if let _ = user.Account{
              try await room.ReplaceAll(Room: UpdatedRoom)
            }
            else{ try await room.Disconnect(User: user, AppleMusic: appleMusic, Router: router) }
          }
        }
      })
    }
    // MARK: RoomView scenePhase Change
    .onChange(of: scenePhase){ phase in
      room.ScenePhaseHandler(phase: phase, User: user, AppleMusic: appleMusic)
    }
    // MARK: Tap Gesture
    .onTapGesture{
      UIApplication.shared.dismissKeyboard()
      ShowSubSearch = false
    }
    .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .global)
      .onEnded{ position in
        let HorizontalDrag = position.translation.width
        let VerticalDrag = position.translation.height
        if(abs(HorizontalDrag) > abs(VerticalDrag)){
          if(HorizontalDrag < 0){ SwipeLeftGesture = true }
          if(HorizontalDrag > 0){ SwipeRightGesture = true }
        }
      })
    // MARK: On Appear
    .onAppear{
      Task{
        if((user.Account != nil) && room.InFirstTime){
          if let Channels: [AuxrChannel] = user.Account?.Channels{
            if let i: Int = Channels.firstIndex(where: { $0.RoomData.roomID == room.ID }){
              user.Likes = Channels[i].Likes
              user.Votes = Channels[i].Votes
            }
          }
          if let AppleMusicConnected: Bool = user.Account?.AppleMusicConnected{
            if(AppleMusicConnected){
              if(appleMusic.Authorized == .notDetermined){
                try await appleMusic.Authorize()
              }
              if(appleMusic.Subscription == .notChecked || appleMusic.Subscription == .active){
                appleMusic.CheckSubscription(completion: { _ in })
              }
            }
          }
          if let Likes: [AuxrSong] = user.Account?.Likes{
            if(!Likes.isEmpty){
              Task{ try await appleMusic.GetAccountLikes(User: user) }
            }
          }
          room.InFirstTime = false
        }
        if((room.Host(User: user) || appleMusic.Subscription == .active)
           && appleMusic.UserLibraryPlaylists.isEmpty){
          Task{ try await appleMusic.GetUserPlaylists() }
        }
        
        if(!room.Playlist.Queue.isEmpty){ CurrentSong = room.Playlist.Queue.sorted()[0] }
        if(appleMusic.UserRecommended.Songs.isEmpty && !appleMusic.UserRecommended.GeneratingRandom){
          appleMusic.UserRecommended.GeneratingRandom = true
          guard (appleMusic.UserRecommended.GeneratingRandom) else{ return }
          Task{ try await appleMusic.GenerateRandomSongs(User: user, Room: room, howMany: 3) }
        }
        if(CurrentSongViewActive){ ShowCurrentSong = CurrentSongViewActive }
        Task{
          if(appleMusic.UserRecommended.SimilarSongs.isEmpty &&
             !room.Playlist.Queue.isEmpty &&
             !appleMusic.UserRecommended.GeneratingSimilar){
            appleMusic.UserRecommended.GeneratingSimilar = true
            let AM_Song = try await appleMusic.ConvertSong(AuxrSong: room.Playlist.Queue.sorted()[0])
            guard (appleMusic.UserRecommended.GeneratingSimilar) else{ return }
            try await appleMusic.GenerateSimilarSongs(User: user, Room: room, howMany: 10, attempts: 30, SelectedSong: AM_Song)
          }
        }
        user.InRoom = true
        try await FirebaseManager.UpdateUserInRoom(User: user, Room: room)
        StartSearch = false
      }
    }
  }
}
