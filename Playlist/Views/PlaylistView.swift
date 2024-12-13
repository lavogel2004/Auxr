import SwiftUI
import OSLog

struct PlaylistView: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  @Binding var Remove: Bool
  @Binding var Like: Bool
  @Binding var Upvote: Bool
  @Binding var Downvote: Bool
  @Binding var PlayNow: Bool
  @Binding var UpNext: Bool
  @Binding var NoSong: Bool
  @Binding var Offline: Bool
  @Binding var Refreshing: Bool
  
  @State private var SelectedSong: AuxrSong = AuxrSong()
  @State private var ShowSongMenu: Bool = false
  @State private var VerticalDragOffset: CGFloat = 0
  @State private var Animate = false
  
  var body: some View {
    ZStack{
      VStack{
        if(Refreshing){
          ZStack{
            HStack(alignment: .center){
              Circle()
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color("Tertiary"))
                .frame(width: 8, height: 8)
                .scaleEffect(Animate ? 1.0 : 0.5)
                .animation(.easeInOut(duration: 0.5).repeatForever(), value: Animate)
                .onAppear{ Animate.toggle() }
              Circle()
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color("Tertiary"))
                .frame(width: 8, height: 8)
                .scaleEffect(Animate ? 1.0 : 0.5)
                .animation(.easeInOut(duration: 0.5).repeatForever().delay(0.3), value: Animate)
                .onAppear{ Animate.toggle() }
              Circle()
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color("Tertiary"))
                .frame(width: 8, height: 8)
                .scaleEffect(Animate ? 1.0 : 0.5)
                .animation(.easeInOut(duration: 0.5).repeatForever().delay(0.6), value: Animate)
                .onAppear{ Animate.toggle() }
            }
          }
          .frame(width: UIScreen.main.bounds.size.width, height: 12)
          .offset(y: -UIScreen.main.bounds.size.height*0.025)
        }
        if(room.Playlist.Queue.isEmpty){
          ZStack{
            VStack(spacing: 2){
              HStack(spacing: 4){
                Image(systemName: "exclamationmark.triangle.fill")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Capsule").opacity(0.6))
                Text("Playlist Empty")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Capsule").opacity(0.6))
              }
              Text("Add songs on the queue")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color("Capsule").opacity(0.6))
            }
            .offset(y: UIScreen.main.bounds.size.height*0.04)
          }
          .frame(height: UIScreen.main.bounds.size.height*0.48, alignment: .top)
        }
        else{
          // MARK: Playlist Total Playtime
          VStack{
            ZStack{
              if(room.Playlist.Queue.count == 1){
                Text("\(room.Playlist.Queue.count) song, \(room.Playlist.TotalPlaytime)")
                  .font(.system(size: 12, weight: .medium))
                  .foregroundColor(Color("System"))
              }
              else{
                Text("\(room.Playlist.Queue.count) songs, \(room.Playlist.TotalPlaytime)")
                  .font(.system(size: 12, weight: .medium))
                  .foregroundColor(Color("System"))
              }
            }
            .frame(width: UIScreen.main.bounds.size.width, alignment: .center)
            
            Spacer()
            
            // MARK: Playlist Scroll View
            if(room.VoteModePermission){
              ScrollView(showsIndicators: false){
                VStack(alignment: .center, spacing: 11){
                  ForEach(Array(Set(room.Playlist.Queue)).sorted()){ song in
                    if(room.MusicService == "AppleMusic" && song.AppleMusic != ""){
                      AppleMusicPlaylistCell(Song: song, ShowMenu: $ShowSongMenu, Selected: $SelectedSong, Like: $Like, Upvote: $Upvote, Downvote: $Downvote, NoSong: $NoSong, Offline: $Offline)
                        .disabled(room.Refreshing)
                        .onTapGesture{ ShowSongMenu = false }
                    }
                    if(song == SelectedSong){
                      if(ShowSongMenu){ AppleMusicPlaylistSongMenu(Song: $SelectedSong, Show: $ShowSongMenu, Remove: $Remove, Like: $Like, PlayNow: $PlayNow, UpNext: $UpNext, NoSong: $NoSong, Offline: $Offline)
                          .offset(x: -UIScreen.main.bounds.size.width*0.125, y: -22)
                          .disabled(room.Refreshing)
                      }
                    }
                  }
                  if(room.Playlist.Queue.count > 4){ Spacer().frame(width: 1, height: UIScreen.main.bounds.size.height*0.2) }
                }
                .frame(width: UIScreen.main.bounds.size.width, alignment: .leading)
                .padding(.leading, UIScreen.main.bounds.size.width*0.05)
              }
            }
            if(!room.VoteModePermission){
              ScrollView(showsIndicators: false){
                VStack(alignment: .center, spacing: 11){
                  ForEach(Array(Set(room.Playlist.Queue)).sorted()){ song in
                    if(room.MusicService == "AppleMusic" && song.AppleMusic != ""){
                      AppleMusicPlaylistCell(Song: song, ShowMenu: $ShowSongMenu, Selected: $SelectedSong, Like: $Like, Upvote: $Upvote, Downvote: $Downvote, NoSong: $NoSong, Offline: $Offline)
                        .disabled(room.Refreshing)
                    }
                    if(song == SelectedSong){
                      if(ShowSongMenu){ AppleMusicPlaylistSongMenu(Song: $SelectedSong, Show: $ShowSongMenu, Remove: $Remove, Like: $Like, PlayNow: $PlayNow, UpNext: $UpNext, NoSong: $NoSong, Offline: $Offline)
                          .offset(x: -UIScreen.main.bounds.size.width*0.05, y: -22)
                          .disabled(room.Refreshing)
                      }
                    }
                  }
                  if(room.Playlist.Queue.count > 4){ Spacer().frame(width: 1, height: UIScreen.main.bounds.size.height*0.2) }
                }
                .frame(width: UIScreen.main.bounds.size.width)
              }
            }
            
          }
          .frame(height: UIScreen.main.bounds.size.height*0.9)
          if(room.Playlist.Queue.count > 7){
            ZStack{
              Spacer()
                .frame(width: UIScreen.main.bounds.size.width*0.8, height: UIScreen.main.bounds.size.height*0.3)
                .background(
                  LinearGradient(
                    gradient: Gradient(stops: [.init(color: Color("Primary").opacity(0.01), location: 0), .init(color: Color("Primary"), location: 1)]),
                    startPoint: .top,
                    endPoint: .bottom
                  )
                  .cornerRadius(6)
                  .allowsHitTesting(false)
                )
            }
            .offset(y: UIScreen.main.bounds.size.height*0.4)
          }
        }
      }
    }
    .onTapGesture{ ShowSongMenu = false }
    .offset(y: VerticalDragOffset)
    .contentShape(Rectangle())
    .onTapGesture {}
    .gesture(
      DragGesture(coordinateSpace: .global)
        .onEnded { value in
          if(value.translation.height > 35){
            Refreshing = true
            Task{ try await room.Refresh(AppleMusic: appleMusic, User: user) }
            withAnimation(.easeInOut(duration: 0.2)){
              VerticalDragOffset = 35
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
              withAnimation(.easeInOut(duration: 0.2)){
                Refreshing = false
                VerticalDragOffset = 0
              }
            }
          }
          else{
            withAnimation(.easeInOut(duration: 0.2)){
              Refreshing = false
              VerticalDragOffset = 0
            }
          }
        }
        .onChanged{ value in
          print(value.translation.height)
          if value.translation.height > 0 {
            withAnimation(.easeInOut(duration: 0.1)){
              self.VerticalDragOffset = value.translation.height
            }
          }
        }
    )
  }
}
