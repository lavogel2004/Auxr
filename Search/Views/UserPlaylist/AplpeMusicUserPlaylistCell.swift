import SwiftUI
import MusicKit

struct AppleMusicUserPlaylistCell: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  let AM_ID: String
  
  @Binding var Queued: Bool
  @Binding var MaxSongs: Bool
  @Binding var Reload: Bool
  @Binding var Offline: Bool
  
  @State private var AM_Song: Song?
  @State private var Queuing: Bool = false
  @State private var Completed: Bool = false
  
  var body: some View {
    ZStack{
      Color("Primary").edgesIgnoringSafeArea(.all)
      VStack{
        HStack{
          HStack{
            if let AlbumImage:Artwork = AM_Song?.artwork{
              ArtworkImage(AlbumImage, width: UIScreen.main.bounds.size.height*0.045)
                .padding(.leading, 5)
            }
            else{
              Image(systemName: "music.note")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color("Tertiary"))
                .frame(width: UIScreen.main.bounds.size.height*0.045, height: UIScreen.main.bounds.size.height*0.045)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
                .padding(.leading, 5)
            }
            VStack(alignment: .leading){
              if let Title = AM_Song?.title{
                Text(Title).lineLimit(1)
                  .font(.system(size: 13, weight: .bold))
                  .foregroundColor(Color("Text"))
              }
              if let Artist = AM_Song?.artistName{
                Text(Artist).lineLimit(1)
                  .font(.system(size: 11, weight: .medium))
                  .foregroundColor(Color("Text"))
              }
            }
          }
          .frame(width: UIScreen.main.bounds.size.width*0.6, alignment: .leading)
          
          Text(FormatDurationToString(s: Double(AM_Song?.duration ?? 0)))
            .font(.system(size: 12, weight: .light))
            .foregroundColor(Color("Text"))
            .frame(width: UIScreen.main.bounds.size.width*0.1)
          
          if(!Queuing && !Completed){
            Button(action: {
              let networkStatus: NetworkStatus = CheckNetworkStatus()
              if(networkStatus == NetworkStatus.reachable){
                if(room.Playlist.Queue.count >= 100 && room.VoteModePermission){
                  MaxSongs = true
                  return
                }
                Task{
                  do
                  {
                    guard !Queuing else{ return }
                    Queuing = true
                    Queued = true
                    let AddedSong:AuxrSong = AuxrSong()
                    AddedSong.AppleMusic = AM_Song?.id.rawValue ?? ""
                    AddedSong.Title = AM_Song?.title ?? ""
                    AddedSong.Artist = AM_Song?.artistName ?? ""
                    AddedSong.Album = AM_Song?.albumTitle ?? ""
                    AddedSong.Duration = AM_Song?.duration ?? 0
                    AddedSong.QueuedBy = user.Nickname
                    AddedSong.Index = room.GlobalPlaylistIndex
                    try await FirebaseManager.UpdateRoomGlobalPlaylistIndex(Room: room)
                    if(AddedSong.AppleMusic != ""){
                      room.Playlist.LocalAdd.append(AddedSong)
                      room.AddSong = true
                      try await FirebaseManager.AddSongToPlaylistLocalAdd(Room: room, AuxrSong: AddedSong, account: user.Account ?? nil)
                    }
                  }
                  catch _ {}
                }
              }
              if(networkStatus == NetworkStatus.notConnected){ Offline = true }
            }){
              Image(systemName: "plus")
                .frame(alignment: .leading)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color("Tertiary"))
            }
            .frame(width: 20, height: 20, alignment: .trailing)
          }
          if(Queuing && !Completed){
            ZStack{ QueuedLoaderView(Loading: $Queuing, Completed: $Completed) }
              .frame(width: 20, height: 20, alignment: .center)
          }
          if(Completed){
            ZStack{
              Image(systemName: "checkmark.circle.fill")
                .frame(alignment: .leading)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color("Tertiary"))
            }
            .frame(width: 20, height: 20, alignment: .center)
          }
          if(Reload){
            Spacer()
              .frame(height: 0)
              .onAppear{
                Task{ try await AM_Song = appleMusic.ConvertSongID(SongID: AM_ID) }
                Reload = false
              }
          }
        }
      }
    }
    .onTapGesture{ Reload = true }
    .onAppear{ Task{ try await AM_Song = appleMusic.ConvertSongID(SongID: AM_ID) } }
  }
}
