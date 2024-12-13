import SwiftUI
import MusicKit

struct ProfileLikeSongCell: View {
  @AppStorage("isDarkMode") private var isDarkMode = false
  
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var account: AuxrAccount
  @EnvironmentObject var appleMusic: AppleMusic
  
  let Song: AuxrSong
  let profileID: String
  
  @Binding var Remove: Bool
  @Binding var SongPlaying: Bool
  
  @State private var AM_Song: Song?
  @State private var Offline: Bool = false
  
  var body: some View {
    VStack(alignment: .leading, spacing: nil){
      HStack{
        Button(action: {
          Task{
            AM_Song = try await appleMusic.ConvertSong(AuxrSong: Song)
            Task{
              SongPlaying = false
              if(appleMusic.player.queue.currentEntry?.item?.id.rawValue != AM_Song?.id.rawValue){
                appleMusic.player.stop()
                appleMusic.player.queue.entries = []
                appleMusic.Queue = []
                if let song: Song = AM_Song{ appleMusic.Queue.append(song) }
                appleMusic.player.queue = ApplicationMusicPlayer.Queue(for: appleMusic.Queue, startingAt: appleMusic.Queue.first)
                appleMusic.player.state.repeatMode = MusicPlayer.RepeatMode.none
                try await appleMusic.player.play()
                SongPlaying = true
              }
              else if(appleMusic.player.state.playbackStatus == .playing && appleMusic.player.queue.currentEntry?.item?.id.rawValue == AM_Song?.id.rawValue ){
                appleMusic.player.pause()
                SongPlaying = false
              }
              else{
                try await appleMusic.player.play()
                SongPlaying = true
              }
            }
          }
        }){
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
              Text(FormatDurationToString(s: Double(AM_Song?.duration ?? 0)))
                .lineLimit(1)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color("Text"))
            }
            .frame(width: UIScreen.main.bounds.size.width*0.5, alignment: .leading)
          }
          .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .leading)
        }
        .disabled(!account.AppleMusicConnected)
        if(profileID == account.ID){
          Button(action: {
            withAnimation(.easeIn(duration: 0.2)){
              Remove = true
            }
            Task{
              try await AccountManager.subtractPoints(account: account, p: 1)
              try await AccountManager.deleteAccountLikes(account: account, like: Song)
            }
          }){
            Image(systemName: "xmark")
              .font(.system(size: 13, weight: .semibold))
              .foregroundColor(Color("Tertiary").opacity(0.8))
          }
          .frame(width: 13, height: 13)
          .offset(x: UIScreen.main.bounds.size.width*0.03, y: -UIScreen.main.bounds.size.height*0.023)
        }
        else{
          if(!(account.Likes.contains(where: { $0.AppleMusic == Song.AppleMusic } ))){
            Button(action: {
              let networkStatus: NetworkStatus = CheckNetworkStatus()
              if(networkStatus == NetworkStatus.reachable){
                Task{
                  if let account: AuxrAccount = user.Account{
                    try await AccountManager.addPoints(account: account, p: 1)
                    if(!account.HideLikes){
                      try await AccountManager.sendLikeNotification(song: Song, sending_account: account)
                    }
                    else{
                      try await AccountManager.addAccountLikes(account: account, like: Song)
                    }
                  }
                }
              }
              if(networkStatus == NetworkStatus.notConnected){ Offline = true }
            }){
              Image(systemName: "heart")
                .frame(alignment: .trailing)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color("Tertiary").opacity(0.8))
            }
            .frame(width: UIScreen.main.bounds.size.width*0.05)
            
          }
          if(account.Likes.contains(where: { $0.AppleMusic == Song.AppleMusic } )){
            Button(action: {
              let networkStatus: NetworkStatus = CheckNetworkStatus()
              if(networkStatus == NetworkStatus.reachable){
                Task{
                  try await AccountManager.subtractPoints(account: account, p: 1)
                  try await AccountManager.deleteAccountLikes(account: account, like: Song)
                }
              }
              if(networkStatus == NetworkStatus.notConnected){ Offline = true }
            }){
              Image(systemName: "heart.fill")
                .frame(alignment: .trailing)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color("Red"))
            }
            .frame(width: UIScreen.main.bounds.size.width*0.05)
          }
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.8, height: UIScreen.main.bounds.size.height*0.08, alignment: .leading)
      .background(RoundedRectangle(cornerRadius: 3).fill(Color((isDarkMode) ? "Secondary" : "Primary")).shadow(color: Color("Shadow"), radius: 1))
    }
    .padding(.top, 3)
    .onTapGesture{ Task{ AM_Song = try await appleMusic.ConvertSong(AuxrSong: Song) } }
    .onAppear{ Task{ AM_Song = try await appleMusic.ConvertSong(AuxrSong: Song) } }
    .zIndex(5)
  }
}
