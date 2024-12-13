import SwiftUI
import MusicKit

struct AppleMusicSongCell: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  let Song: Song
  
  @Binding var Queued: Bool
  @Binding var MaxSongs: Bool
  @Binding var Offline: Bool
  
  @State private var Queuing: Bool = false
  @State private var Completed: Bool = false
  
  var body: some View {
    HStack{
      HStack(spacing: 7){
        if let AlbumImage:Artwork = Song.artwork{
          ArtworkImage(AlbumImage, width: UIScreen.main.bounds.size.height*0.07)
            .padding(.leading, 5)
        }
        else{
          Image(systemName: "music.note")
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(Color("Tertiary"))
            .frame(width: UIScreen.main.bounds.size.height*0.07, height: UIScreen.main.bounds.size.height*0.07)
            .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
            .padding(.leading, 5)
        }
        VStack(alignment: .leading){
            Text(Song.title).lineLimit(1)
              .font(.system(size: 12, weight: .bold))
              .foregroundColor(Color("Text"))
            Text(Song.artistName).lineLimit(1)
              .font(.system(size: 10, weight: .medium))
              .foregroundColor(Color("Text"))
            Text(FormatDurationToString(s: Double(Song.duration ?? 0)))
              .font(.system(size: 10, weight: .medium))
              .foregroundColor(Color("Text"))
          if let AlbumTitle: String = Song.albumTitle{
            Text(AlbumTitle).lineLimit(1)
              .font(.system(size: 10, weight: .medium))
              .foregroundColor(Color("Text"))
          }
        }
        .frame(width: UIScreen.main.bounds.size.width*0.5, alignment: .leading)
      }
      .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .leading)
      if(!Queuing && !Completed){
        Button(action: {
          let networkStatus: NetworkStatus = CheckNetworkStatus()
          if(networkStatus == NetworkStatus.reachable){
            if(room.Playlist.Queue.count >= 100 && room.VoteModePermission){
              MaxSongs = true
              return
            }
            Task{
              if let Account = user.Account{ try await AccountManager.addPoints(account: Account, p: 1) }
              do
              {
                print("Queuing", Queuing)
                print("Queued", Queued)
                print("Completed", Completed)
                guard !Queuing else{ return }
                Queuing = true
                Queued = true
                print("Queuing", Queuing)
                print("Queued", Queued)
                print("Completed", Completed)
                let AddedSong: AuxrSong = AuxrSong()
                AddedSong.AppleMusic = Song.id.rawValue
                AddedSong.Title = Song.title
                AddedSong.Artist = Song.artistName
                AddedSong.Album = Song.albumTitle ?? ""
                AddedSong.Duration = Song.duration ?? 0
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
        .frame(width: 20, height: 20, alignment: .leading)
        .padding(10)
        .offset(x: -UIScreen.main.bounds.size.width*0.03)
      }
      if(Queuing && !Completed){
        ZStack{ QueuedLoaderView(Loading: $Queuing, Completed: $Completed) }
          .frame(width: 20, height: 20, alignment: .center)
          .padding(10)
          .offset(x: -UIScreen.main.bounds.size.width*0.03)
      }
      if(!Queuing && Completed){
        ZStack{
          Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color("Tertiary"))
            .frame(alignment: .leading)
        }
        .frame(width: 20, height: 20)
        .padding(10)
        .offset(x: -UIScreen.main.bounds.size.width*0.03)
      }
    }
    .frame(width: UIScreen.main.bounds.size.width*0.82, height: UIScreen.main.bounds.size.height*0.08, alignment: .leading)
    .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
  }
}
