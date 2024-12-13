import SwiftUI
import MusicKit

struct AppleMusicPlaylistCell: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  let Song: AuxrSong
  
  @Binding var ShowMenu: Bool
  @Binding var Selected: AuxrSong
  @Binding var Like: Bool
  @Binding var Upvote: Bool
  @Binding var Downvote: Bool
  @Binding var NoSong: Bool
  @Binding var Offline: Bool
  
  @State private var AM_Song: Song?
  
  var body: some View {
    ZStack{
      VStack(alignment: .leading, spacing: nil){
        HStack{
          HStack(spacing: nil){
            HStack(spacing: 7){
              if let AlbumImage:Artwork = AM_Song?.artwork{
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
              VStack(alignment: .leading, spacing: 2){
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
                Text(FormatDurationToString(s: Double(AM_Song?.duration ?? 0))).lineLimit(1)
                  .font(.system(size: 11, weight: .medium))
                  .foregroundColor(Color("Text"))
              }
              .frame(width: UIScreen.main.bounds.size.width*0.5, alignment: .leading)
            }
            .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .leading)
            Button(action: {
              ShowMenu.toggle()
              Selected = Song
            }){
              ZStack{
                if(!ShowMenu){
                  Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(Color("Tertiary").opacity(0.8))
                }
                if(ShowMenu && Song == Selected){
                  Image(systemName: "ellipsis")
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundColor(Color("Tertiary").opacity(0.4))
                }
              }
              .offset(x: -UIScreen.main.bounds.size.width*0.02)
            }
          }
          .frame(width: UIScreen.main.bounds.size.width*0.8, height: UIScreen.main.bounds.size.height*0.08, alignment: .leading)
          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
          if(room.VoteModePermission){
            VoterView(Song: Song, Upvote: $Upvote, Downvote: $Downvote, ShowMenu: $ShowMenu, Offline: $Offline)
              .padding(.trailing, UIScreen.main.bounds.size.width*0.06)
          }
        }
        HStack{
          Text(Song.QueuedBy)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color("Text"))
            .padding(.leading, UIScreen.main.bounds.size.width*0.02)
          if(room.PlaySong){
            if(!room.Playlist.Queue.isEmpty){
              if(Song == room.Playlist.Queue.sorted()[0]){
                AudioVisualizer()
                  .frame(width: UIScreen.main.bounds.size.width*0.05, alignment: .leading)
                  .padding(.leading, 3)
              }
              else{
                Rectangle()
                  .fill(Color("Primary").opacity(0.0))
                  .frame(width: UIScreen.main.bounds.size.width*0.05, alignment: .leading)
                  .padding(.leading, 3)
              }
            }
          }
        }
        .frame(width: UIScreen.main.bounds.size.width*0.8, alignment: .leading)
      }
    }
    .frame(width: UIScreen.main.bounds.size.width, alignment: .center)
    .padding(.top, 3)
    .onAppear{ Task{ AM_Song = try await appleMusic.ConvertSong(AuxrSong: Song) } }
    .onTapGesture(count: 2){
      Task{
        let networkStatus: NetworkStatus = CheckNetworkStatus()
        if(networkStatus == NetworkStatus.reachable){
          if(!user.Likes.contains(where: { $0.AppleMusic == Song.AppleMusic })){
            Like = true
            if(!(user.Likes.contains(where: { $0.AppleMusic == Song.AppleMusic }))){
              user.Likes.append(Song)
            }
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
        if(networkStatus == NetworkStatus.notConnected){ Offline = true }
      }
    }
  }
}
