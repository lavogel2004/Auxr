import SwiftUI

struct ControlsView: View {
  @Environment(\.scenePhase) var scenePhase
  @EnvironmentObject var router: Router
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  @Binding var Share: Bool
  @Binding var NoControls: Bool
  @Binding var Playing: Bool
  @Binding var Paused: Bool
  @Binding var Skipped: Bool
  @Binding var NoSong: Bool
  @Binding var CurrentSong: AuxrSong
  @Binding var CurrentSongText: String
  @Binding var ShowCurrentSong: Bool
  @Binding var Offline: Bool
  
  var body: some View {
    ZStack{
      HStack(spacing: 2){
        // MARK: MarqueeText
        if(!room.Playlist.Queue.isEmpty)
        {
          Button(action:{ ShowCurrentSong = true }){
            MarqueeText(
              font: UIFont.preferredFont(forTextStyle: .subheadline),
              leftFade: 16,
              rightFade: 16,
              startDelay: 3,
              text: $CurrentSongText
            )
            .frame(width: UIScreen.main.bounds.size.width*0.6)
            .padding(10)
            .padding(.leading, UIScreen.main.bounds.size.width*0.0625)
            .offset(y: -20)
          }
        }
        else{
          MarqueeText(
            font: UIFont.preferredFont(forTextStyle: .subheadline),
            leftFade: 16,
            rightFade: 16,
            startDelay: 3,
            text: $CurrentSongText
          )
          .frame(width: UIScreen.main.bounds.size.width*0.6)
          .padding(10)
          .padding(.leading, UIScreen.main.bounds.size.width*0.0625)
          .offset(y: -20)
        }
        
        // MARK: Play/Pause Button
        HStack(spacing: 25){
          if(room.Creator(User: user) ||
             room.Host(User: user) ||
             room.PlayPausePermission ||
             user.PlayPausePermission){
            if(!room.PlaySong){
              Button(action: {
                let networkStatus: NetworkStatus = CheckNetworkStatus()
                if(networkStatus == NetworkStatus.reachable){
                  if(!room.Playlist.Queue.isEmpty){
                    withAnimation(.easeIn(duration: 0.2)){ Playing = true }
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
                  else{ NoSong = true }
                }
                if(networkStatus == NetworkStatus.notConnected){ Offline = true }
              }){
                Image(systemName: "play.fill")
                  .font(.system(size: 28, weight: .bold))
                  .foregroundColor(Color("Tertiary"))
                  .frame(width: 28, height: 28)
              }
              .disabled(room.Controlled ||
                        Paused ||
                        Skipped)
            }
            if(room.PlaySong){
              Button(action: {
                let networkStatus: NetworkStatus = CheckNetworkStatus()
                if(networkStatus == NetworkStatus.reachable){
                  if(!room.Playlist.Queue.isEmpty){
                    withAnimation(.easeIn(duration: 0.2)){ Paused = true }
                    Task{
                      do
                      {
                        room.PlaySong = false
                        try await FirebaseManager.UpdateRoomPlaySong(Room: room)
                      }
                      catch _ {}
                    }
                  }
                  else{ NoSong = true }
                }
                if(networkStatus == NetworkStatus.notConnected){ Offline = true }
              }){
                Image(systemName: "pause.fill")
                  .font(.system(size: 28, weight: .bold))
                  .foregroundColor(Color("Tertiary"))
                  .frame(width: 28, height: 28)
              }
              .disabled(room.Controlled ||
                        Playing ||
                        Skipped)
            }
          }
          else{
            Button(action: { withAnimation(.easeIn(duration: 0.2)){ NoControls = true }}){
              Image(systemName: "play.fill")
                .frame(width: 28, height: 28)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color("System"))
            }
          }
          
          // MARK: Skip Button
          if(room.Creator(User: user) ||
             room.Host(User: user) ||
             room.SkipPermission ||
             user.SkipPermission){
            Button(action: {
              let networkStatus: NetworkStatus = CheckNetworkStatus()
              if(networkStatus == NetworkStatus.reachable){
                if(room.Playlist.Queue.count > 1){
                  withAnimation(.easeIn(duration: 0.2)){ Skipped = true }
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
                else{ NoSong = true }
              }
              if(networkStatus == NetworkStatus.notConnected){ Offline = true }
            }){
              Image(systemName: "forward.fill")
                .frame(width: 28, height: 28)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color("Tertiary"))
            }
            .disabled(room.Controlled ||
                      Paused ||
                      Skipped)
          }
          else{
            Button(action: { withAnimation(.easeIn(duration: 0.2)){ NoControls = true }}){
              Image(systemName: "forward.fill")
                .frame(width: 28, height: 28)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color("System"))
            }
          }
        }
        .frame(width: UIScreen.main.bounds.size.width*0.25, alignment: .leading)
        .padding(10)
        .offset(x: -UIScreen.main.bounds.size.width*0.05, y: -20)
        
        // MARK: Application Player Publishers
        if(room.MusicService == "AppleMusic" && !room.SkipSong){
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
    }
    .frame(width: UIScreen.main.bounds.size.width, height: 100, alignment: .center)
    .background(Rectangle().fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
    .offset(y: -30)
    .onAppear{
      Task{
        if(!room.Playlist.Queue.isEmpty){
          if(CurrentSong != room.Playlist.Queue.sorted()[0]){ CurrentSong = room.Playlist.Queue.sorted()[0] }
        }
      }
    }
    .onReceive(room.Playlist.TMR){ _ in
      Task{
        if(room.Host(User: user)){
          // MARK: Update Player
          try await appleMusic.BackgroundTaskFetch(Room: room)
          
          // MARK: Play Control
          if(room.PlaySong){
            // MARK: Add Song History [Play]
            if(!room.Playlist.Queue.isEmpty){
              if(!room.Playlist.History.contains(room.Playlist.Queue.sorted()[0])){
                try await FirebaseManager.AddSongToPlaylistHistory(Room: room, AuxrSong: room.Playlist.Queue.sorted()[0])
              }
            }
            
            if(room.MusicService == "AppleMusic" && room.Host.InRoom){
              // MARK: Resume Playling [Play]
              if(room.Host(User: user)){
                if(!(appleMusic.player.state.playbackStatus == .playing)){
                  if(appleMusic.player.state.playbackStatus == .paused &&
                     room.Controlled &&
                     (room.Playlist.Queue.sorted()[0].AppleMusic ==
                      appleMusic.player.queue.currentEntry?.item?.id.rawValue)){
                    try await appleMusic.PlayerPlay()
                    room.Controlled = false
                    try await FirebaseManager.UpdateRoomControlled(Room: room)
                  }
                  else{
                    // MARK: Initialize Player [Play]
                    if(!room.Playlist.Queue.isEmpty && room.Controlled){
                      try await appleMusic.PlayerInit(Room: room)
                      room.Controlled = false
                      try await FirebaseManager.UpdateRoomControlled(Room: room)
                    }
                  }
                }
              }
            }
            // MARK: Overtime Case
            if(appleMusic.InRoomQueue &&
               !room.Playlist.QueueInitializing &&
               !room.SkipSong){
              if(!room.Playlist.Queue.isEmpty && !room.Controlled){
                if(appleMusic.player.queue.entries.count == 1 && room.Playlist.Queue.count > 1){
                  if(room.Playlist.Queue.sorted()[0].AppleMusic == appleMusic.player.queue.currentEntry?.item?.id.rawValue){
                    if(appleMusic.player.playbackTime+1.5 >= Double(Int(room.Playlist.Queue.sorted()[0].Duration-1.5))){
                      let networkStatus: NetworkStatus =  CheckNetworkStatus()
                      if(networkStatus == NetworkStatus.reachable){
                        room.Controlled = true
                        try await FirebaseManager.UpdateRoomControlled(Room: room)
                        room.Playlist.QueueInitializing = true
                        try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: room)
                        let currSong = room.Playlist.Queue.sorted()[0]
                        try await FirebaseManager.RemoveSongFromPlaylistQueue(Room: room, AuxrSong: currSong)
                        appleMusic.player.queue.entries.removeFirst()
                        room.Playlist.QueueInitializing = false
                        try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: room)
                        room.Controlled = false
                        try await FirebaseManager.UpdateRoomControlled(Room: room)
                      }
                      if(networkStatus == NetworkStatus.notConnected){ Offline = true }
                    }
                  }
                }
              }
            }
          }
          
          // MARK: Pause Control
          if(!room.PlaySong){
            if(room.MusicService == "AppleMusic"){
              try await appleMusic.PlayerPause()
            }
          }
          
          // MARK: Skip Control
          if(room.SkipSong && room.Controlled){
            if(room.MusicService == "AppleMusic"){
              if(room.PlaySong){
                if(room.Playlist.Queue.sorted()[0].AppleMusic == appleMusic.player.queue.currentEntry?.item?.id.rawValue){
                  try await appleMusic.PlayerSkip(Room: room)
                }
              }
              else{
                if(room.Host.InRoom){
                  try await appleMusic.PlayerSkip(Room: room)
                }
              }
            }
          }
          
        }
        
      }
    }
    
  }
}
