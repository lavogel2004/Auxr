import SwiftUI
import MusicKit

struct AppleMusicAlbumTrackCell: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  
  let Track: Track
  
  @Binding var Queued: Bool
  @Binding var MaxSongs: Bool
  @Binding var Offline: Bool
  
  @State private var Queuing: Bool = false
  @State private var Completed: Bool = false
  
  var body: some View {
    ZStack{
      Color("Primary").edgesIgnoringSafeArea(.all)
      VStack{
        HStack{
          Text(Track.title).lineLimit(1)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(Color("Text"))
            .frame(width: UIScreen.main.bounds.size.width*0.55, alignment: .leading)
          HStack{
            Text(FormatDurationToString(s: Double(Track.duration ?? 0)))
              .font(.system(size: 12, weight: .light))
              .foregroundColor(Color("Text"))
              .frame(width: UIScreen.main.bounds.size.width*0.1, alignment: .leading)
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
                      AddedSong.AppleMusic = Track.id.rawValue
                      AddedSong.Title = Track.title
                      AddedSong.Artist = Track.artistName
                      AddedSong.Album = Track.albumTitle ?? ""
                      AddedSong.Duration = Track.duration ?? 0
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
          }
        }
      }
    }
  }
}
