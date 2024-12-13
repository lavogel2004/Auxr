import SwiftUI
import MusicKit

struct CurrentSongView: View {
  @AppStorage("isDarkMode") private var isDarkMode = false
  
  @Environment(\.scenePhase) var scenePhase
  @Environment(\.presentationMode) var Presentation
  @EnvironmentObject var router: Router
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  let srch: Search = Search()
  
  @Binding var Song: AuxrSong
  @Binding var Show: Bool
  @Binding var Active: Bool
  @Binding var StartSearch: Bool
  @Binding var SearchInput: String
  @Binding var Filter: SearchFilter
  @Binding var Searching: Bool
  @Binding var Completed: Bool
  @Binding var SimilarSongs: Bool
  
  @State private var AM_Song: Song? = nil
  @State private var SongChange: Bool = false
  @State private var CurrentSongProgressTime: Float = 0.0
  @State private var SongTime: Float = 0.0
  @State private var ShowOfflineOverlay: Bool = false
  @State private var ShowNoControlsOverlay: Bool = false
  @State private var ShowNoSongOverlay: Bool = false
  @State private var ShowPlayOverlay: Bool = false
  @State private var ShowPauseOverlay: Bool = false
  @State private var ShowSkipOverlay: Bool = false
  @State private var ShowLikeOverlay: Bool = false
  @State private var VerticalDragOffset: CGFloat = 0
  
  var body: some View {
    ZStack{
      Color("Primary").edgesIgnoringSafeArea(.all)
      
      if(ShowOfflineOverlay){ OfflineOverlay(networkStatus: NetworkStatus.notConnected, Show: $ShowOfflineOverlay)}
      
      if(ShowNoControlsOverlay){ GeneralOverlay(type: GeneralOverlayType.noControls, Show: $ShowNoControlsOverlay) }
      else if(ShowNoSongOverlay){ GeneralOverlay(type: GeneralOverlayType.noSong, Show: $ShowNoSongOverlay) }
      
      if(AM_Song != nil){
        
        HStack(alignment: .top){
          Button(action: { withAnimation(.easeInOut(duration: 0.2)){
            appleMusic.UserRecommended.SimilarSongs = []
            Active = false
            Show = false
          }}){
            Image(systemName: "chevron.down")
              .font(.system(size: 20, weight: .medium))
              .foregroundColor(Color("Tertiary"))
              .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .leading)
              .padding(.leading, 10)
          }
        }
        .frame(width: UIScreen.main.bounds.size.width*0.95, alignment: .topLeading)
        .offset(y: -UIScreen.main.bounds.size.height/2*0.82)
        
        ZStack{
          VStack(spacing: 0){
            HStack{
              if(!SongChange){
                if let AlbumImage:Artwork = AM_Song?.artwork{
                  ArtworkImage(AlbumImage, width: UIScreen.main.bounds.size.height*0.38)
                    .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")).shadow(color: Color("Shadow").opacity(0.5), radius: 1))
                }
              }
              else{
                Image(systemName: "music.note")
                  .font(.system(size: 50, weight: .bold))
                  .foregroundColor(Color("Tertiary"))
                  .frame(width: UIScreen.main.bounds.size.height*0.38, height: UIScreen.main.bounds.size.height*0.38)
                  .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")).shadow(color: Color("Shadow").opacity(0.5), radius: 1))
              }
            }
            .frame(width: UIScreen.main.bounds.size.height*0.4, height: UIScreen.main.bounds.size.height*0.4, alignment: .center)
            
            VStack(spacing: 10){
              HStack{
                if let Title = AM_Song?.title{
                  Text(Title).lineLimit(1)
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(Color("Text"))
                }
              }
              .frame(width: UIScreen.main.bounds.size.width*0.7, height: UIScreen.main.bounds.size.width*0.05, alignment: .center)
              HStack{
                if let Artist = AM_Song?.artistName{
                  Text(Artist).lineLimit(1)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color("Text"))
                }
              }
              .frame(width: UIScreen.main.bounds.size.width*0.8, height: UIScreen.main.bounds.size.width*0.05, alignment: .center)
            }
            .frame(width: UIScreen.main.bounds.size.width*0.8, height: UIScreen.main.bounds.size.height*0.1, alignment: .center)
            
            // MARK: Song Progress Bar
            if(room.Host(User: user)){
              VStack(spacing: 11){
                HStack{
                  ZStack{
                    Capsule()
                      .frame(width: UIScreen.main.bounds.size.width*0.88, height: 5)
                      .foregroundColor(Color("System"))
                    SongProgressBar(progress: CGFloat((Float(CurrentSongProgressTime)/Float(AM_Song?.duration ?? -1.0))))
                      .frame(width: UIScreen.main.bounds.size.width*0.88, height: 5)
                      .foregroundColor(Color("Tertiary"))
                    
                  }
                }
                .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .center)
                HStack{
                  HStack{
                    Text(FormatDurationToString(s: Double(CurrentSongProgressTime)))
                      .font(.system(size: 10, weight: .medium))
                      .foregroundColor(Color("Text"))
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.45, alignment: .leading)
                  HStack{
                    Text(FormatDurationToString(s: Double(SongTime)))
                      .font(.system(size: 10, weight: .medium))
                      .foregroundColor(Color("Text"))
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.45, alignment: .trailing)
                }
                .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .center)
              }
              .frame(width: UIScreen.main.bounds.size.width*0.8, height: UIScreen.main.bounds.size.height*0.05, alignment: .bottom)
            }
            
            VStack(spacing: UIScreen.main.bounds.size.height*0.04){
              // MARK: Play/Pause Button
              HStack(spacing: 20){
                if(room.Creator(User: user) ||
                   room.Host(User: user) ||
                   room.PlayPausePermission ||
                   user.PlayPausePermission){
                  if(!room.PlaySong){
                    Button(action: {
                      let NetworkStatus: NetworkStatus = CheckNetworkStatus()
                      if(NetworkStatus == .reachable){
                        if(!room.Playlist.Queue.isEmpty){
                          Task{
                            do
                            {
                              room.PlaySong = true
                              try await FirebaseManager.UpdateRoomPlaySong(Room: room)
                              room.Controlled = true
                              try await FirebaseManager.UpdateRoomControlled(Room: room)
                              // MARK: Play Notification
                              if(!room.Host.InRoom){
                                NotificationManager.SendWakeupHostNotification(
                                  hostFcmToken: room.Host.token,
                                  queueAction: "play",
                                  completion: { success, error in
                                    if(!success){ print("ERROR: " + error) }
                                  }
                                )
                              }
                              try await FirebaseManager.UpdateRoomGuestControlled(Room: room)
                            }
                            catch _ {}
                          }
                        }
                        else{ ShowNoSongOverlay = true }
                      }
                      if(NetworkStatus == .notConnected){ ShowOfflineOverlay = true }
                    }){
                      Image(systemName: "play.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color("Tertiary"))
                        .frame(width: 40, height: 40)
                    }
                    .disabled(room.Controlled ||
                              ShowPauseOverlay ||
                              ShowSkipOverlay)
                  }
                  if(room.PlaySong){
                    Button(action: {
                      let NetworkStatus: NetworkStatus = CheckNetworkStatus()
                      if(NetworkStatus == .reachable){
                        if(!room.Playlist.Queue.isEmpty){
                          Task{
                            do
                            {
                              room.PlaySong = false
                              try await FirebaseManager.UpdateRoomPlaySong(Room: room)
                            }
                            catch _ {}
                          }
                        }
                        else{ ShowNoSongOverlay = true }
                      }
                      if(NetworkStatus == .notConnected){ ShowOfflineOverlay = true }
                    }){
                      Image(systemName: "pause.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color("Tertiary"))
                        .frame(width: 40, height: 40)
                    }
                    .disabled(room.Controlled ||
                              ShowPlayOverlay ||
                              ShowSkipOverlay)
                  }
                }
                else{
                  Button(action: { withAnimation(.easeIn(duration: 0.2)){ ShowNoControlsOverlay = true }}){
                    Image(systemName: "play.fill")
                      .font(.system(size: 40, weight: .bold))
                      .foregroundColor(Color("System"))
                      .frame(width: 40, height: 40)
                  }
                }
                
                // MARK: Skip Button
                if(room.Creator(User: user) ||
                   room.Host(User: user) ||
                   room.SkipPermission ||
                   user.SkipPermission){
                  Button(action: {
                    let NetworkStatus: NetworkStatus = CheckNetworkStatus()
                    if(NetworkStatus == .reachable){
                      if(room.Playlist.Queue.count > 1){
                        Task{
                          do
                          {
                            room.SkipSong = true
                            try await FirebaseManager.UpdateRoomSkipSong(Room: room)
                            room.Controlled = true
                            try await FirebaseManager.UpdateRoomControlled(Room: room)
                            // MARK: Skip Notification
                            if(!room.Host.InRoom && !room.PlaySong){
                              NotificationManager.SendWakeupHostNotification(
                                hostFcmToken: room.Host.token,
                                queueAction: "skip",
                                completion: { success, error in
                                  if(!success){ print("ERROR: " + error) }
                                }
                              )
                            }
                          }
                          catch _ {}
                        }
                      }
                      else{ ShowNoSongOverlay = true }
                    }
                    if(NetworkStatus == .notConnected){ ShowOfflineOverlay = true }
                  }){
                    Image(systemName: "forward.fill")
                      .frame(width: 40, height: 40)
                      .font(.system(size: 40, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                  }
                  .disabled(room.Controlled ||
                            ShowPauseOverlay ||
                            ShowSkipOverlay)
                }
                else{
                  Button(action: { withAnimation(.easeIn(duration: 0.2)){ ShowNoControlsOverlay = true }}){
                    Image(systemName: "forward.fill")
                      .frame(width: 40, height: 40)
                      .font(.system(size: 40, weight: .bold))
                      .foregroundColor(Color("System"))
                  }
                }
              }
              .frame(width: UIScreen.main.bounds.size.width, alignment: .center)
              
              HStack(spacing: UIScreen.main.bounds.size.width*0.22){
                // MARK: Like Button
                if(!(user.Likes.contains(where: { $0.AppleMusic == Song.AppleMusic }))){
                  Button(action: {
                    let NetworkStatus: NetworkStatus = CheckNetworkStatus()
                    if(NetworkStatus == .reachable){
                      if(!(user.Likes.contains(where: { $0.AppleMusic == Song.AppleMusic }))){
                        user.Likes.append(Song)
                      }
                      Task{
                        if let account: AuxrAccount = user.Account{
                          try await AccountManager.addPoints(account: account, p: 1)
                          if(!account.HideLikes){
                            try await AccountManager.sendLikeNotification(song: Song, sending_account: account)
                          }
                          else{
                            try await AccountManager.addAccountLikes(account: account, like: Song)
                          }
                          if let am_song = try await appleMusic.ConvertSong(AuxrSong: Song){
                            if(!(appleMusic.AccountLikes.contains(where: { $0.id.rawValue == am_song.id.rawValue }))){
                              appleMusic.AccountLikes.append(am_song)
                            }
                          }
                        }
                      }
                    }
                    if(NetworkStatus == .notConnected){ ShowOfflineOverlay = true }
                  }){
                    VStack(spacing: 7){
                      Image(systemName: "heart")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(Color("Tertiary"))
                        .frame(width: 40, height: 40, alignment: .center)
                      Text("Like")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color("Tertiary"))
                    }
                  }
                }
                
                //MARK: Unlike Button
                if(user.Likes.contains(where: { $0.AppleMusic == Song.AppleMusic })){
                  Button(action: {
                    let NetworkStatus: NetworkStatus = CheckNetworkStatus()
                    if(NetworkStatus == .reachable){
                      user.Likes = user.Likes.filter{ $0 != Song }
                      Task{
                        if let account: AuxrAccount = user.Account{
                          try await AccountManager.subtractPoints(account: account, p: 1)
                          try await AccountManager.deleteAccountLikes(account: account, like: Song)
                          if let am_song = try await appleMusic.ConvertSong(AuxrSong: Song){
                            appleMusic.AccountLikes = appleMusic.AccountLikes.filter{ $0.id.rawValue != am_song.id.rawValue }
                          }
                        }
                      }
                    }
                    if(NetworkStatus == .notConnected){ ShowOfflineOverlay = true }
                  }){
                    VStack(spacing: 7){
                      Image(systemName: "heart.fill")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(Color("Red"))
                        .frame(width: 40, height: 40, alignment: .center)
                      Text("Unlike")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(Color("Tertiary"))
                    }
                  }
                }
                
                // MARK: Search Artists
                Button(action: {
                  StartSearch = true
                  let networkStatus: NetworkStatus = CheckNetworkStatus()
                  if(networkStatus == .reachable){
                    Task{
                      if let Title = AM_Song?.artistName{
                        SearchInput = ParseArtistName(input: Title, getFirst: true) ?? ""
                        Searching = true
                        Completed = false
                      }
                      srch.Reset(Room: room, AppleMusic: appleMusic)
                      try await srch.SearchMusic(Room: room, AppleMusic: appleMusic, Input: SearchInput, Filter: .songs)
                    }
                  }
                }){
                  VStack(spacing: 7){
                    Image(systemName: "music.mic")
                      .font(.system(size: 40, weight: .semibold))
                      .foregroundColor(Color("Tertiary"))
                      .frame(width: 40, height: 40, alignment: .center)
                    Text("Artist")
                      .font(.system(size: 8, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                  }
                }
                .offset(y: 1)
                
                // MARK: Similar Songs
                Button(action: {
                  if(!appleMusic.UserRecommended.SimilarSongs.isEmpty){
                    appleMusic.UserRecommended.SimilarSongs = []
                    Show = false
                    SimilarSongs = true
                  }
                }){
                  VStack(spacing: 7){
                    ZStack{
                      Image(systemName: "waveform.and.magnifyingglass")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(Color("Tertiary"))
                        .frame(width: 40, height: 40, alignment: .center)
                    }
                    .offset(x: -3)
                    Text("Similar Songs")
                      .font(.system(size: 8, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                  }
                }
              }
              .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.1, alignment: .center)
              .padding(10)
            }
            .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.25, alignment: .center)
          }
          
          // MARK: Application Player Publishers
          if(room.MusicService == "AppleMusic"){
            EmptyView().hidden()
              .onReceive(appleMusic.player.state.objectWillChange){
                Task{
                  do
                  {
                    try await appleMusic.RemoteCommandCenterState(Room: room)
                  }
                  catch _
                  {
                    room.Controlled = false
                    try await FirebaseManager.UpdateRoomControlled(Room: room)
                  }
                }
              }
              .onReceive(appleMusic.player.queue.objectWillChange){
                Task{
                  do
                  {
                    if(room.Host(User: user)){
                      guard room.Name != "" else{ return }
                      try await appleMusic.QueueControl(Room: room)
                    }
                  }
                  catch _
                  {
                    room.Controlled = false
                    try await FirebaseManager.UpdateRoomControlled(Room: room)
                  }
                }
              }
          }
        }
        .frame(height: UIScreen.main.bounds.size.height*0.85)
      }
    }
    .gesture(
      DragGesture(coordinateSpace: .global)
        .onChanged{ value in
          if(value.translation.height > 0){
            let dragDistance = min(value.translation.height, 20)
            self.VerticalDragOffset = dragDistance
          }
          if(value.translation.height > 20){
            DispatchQueue.main.asyncAfter(deadline: .now()){
              withAnimation(.easeInOut(duration: 0.5)){
                VerticalDragOffset = 0
                Active = false
                Show = false
              }
            }
          }
        }
    )
    .onAppear{
      Task{
        if(!SongChange){ AM_Song = try await appleMusic.ConvertSong(AuxrSong: room.Playlist.Queue.sorted()[0]) }
        if(appleMusic.UserRecommended.SimilarSongs.isEmpty && !appleMusic.UserRecommended.GeneratingSimilar){
          appleMusic.UserRecommended.GeneratingSimilar = true
          guard (appleMusic.UserRecommended.GeneratingSimilar) else{ return }
          try await appleMusic.GenerateSimilarSongs(User: user, Room: room, howMany: 10,attempts: 30, SelectedSong: AM_Song)
        }
      }
    }
    .onReceive(room.Playlist.TMR){ _ in
      Task{
        CurrentSongProgressTime = Float(appleMusic.player.playbackTime)
        SongTime = Float(AM_Song?.duration ?? 0.0) - CurrentSongProgressTime
        if(Song != room.Playlist.Queue.sorted()[0]){
          SongChange = true
          Song = room.Playlist.Queue.sorted()[0]
          AM_Song = try await appleMusic.ConvertSong(AuxrSong: room.Playlist.Queue.sorted()[0])
          SongChange = false
          appleMusic.UserRecommended.GeneratingSimilar = true
          appleMusic.UserRecommended.SimilarSongs = []
          if(appleMusic.UserRecommended.GeneratingSimilar){
            let nextAM_Song = try await appleMusic.ConvertSong(AuxrSong: room.Playlist.Queue.sorted()[0])
            guard (appleMusic.UserRecommended.GeneratingSimilar) else{ return }
            try await appleMusic.GenerateSimilarSongs(User: user, Room: room, howMany: 10, attempts: 30, SelectedSong: nextAM_Song)
          }
        }
      }
    }
    .onChange(of: scenePhase){ phase in
      room.ScenePhaseHandler(phase: phase, User: user, AppleMusic: appleMusic)
    }
    .navigationBarHidden(true)
    .colorScheme(isDarkMode ? .dark : .light)
    // MARK: Handle Search scenePhase Changes
    .onChange(of: scenePhase){ phase in
      room.ScenePhaseHandler(phase: phase, User: user, AppleMusic: appleMusic)
    }
  }
}
