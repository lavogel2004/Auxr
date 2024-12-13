import SwiftUI
import MusicKit

struct AppleMusicHistoryCell: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  let Song: AuxrSong
  
  @Binding var Queued: Bool
  @Binding var Like: Bool
  @Binding var MaxSongs: Bool
  @Binding var Offline: Bool
  
  @State private var AM_Song: Song?
  @State private var Queuing: Bool = false
  @State private var Completed: Bool = false
  
  var body: some View {
    ZStack{
      VStack(alignment: .leading, spacing: nil){
        HStack{
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
            VStack(alignment: .leading){
              if let Title: String = AM_Song?.title{
                Text(Title).lineLimit(1)
                  .font(.system(size: 12, weight: .bold))
                  .foregroundColor(Color("Text"))
              }
              if let Artist: String = AM_Song?.artistName{
                Text(Artist).lineLimit(1)
                  .font(.system(size: 10, weight: .medium))
                  .foregroundColor(Color("Text"))
              }
              Text(FormatDurationToString(s: Double(AM_Song?.duration ?? 0)))
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color("Text"))
              if let AlbumTitle: String = AM_Song?.albumTitle{
                Text(AlbumTitle).lineLimit(1)
                  .lineLimit(1)
                  .font(.system(size: 10, weight: .medium))
                  .foregroundColor(Color("Text"))
              }
            }
            .frame(width: UIScreen.main.bounds.size.width*0.5, alignment: .leading)
          }
          .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .leading)
          HStack(spacing: 7){
            ZStack{
              if(!(user.Likes.contains(where: { $0.AppleMusic == Song.AppleMusic }))){
                Button(action: {
                  let networkStatus: NetworkStatus = CheckNetworkStatus()
                  if(networkStatus == NetworkStatus.reachable){
                    withAnimation(.easeIn(duration: 0.2)){
                      Like = true
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
                  }
                  if(networkStatus == NetworkStatus.notConnected){ Offline = true }
                }){
                  Image(systemName: "heart")
                    .frame(alignment: .leading)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("Tertiary").opacity(0.8))
                }
              }
              if(user.Likes.contains(where: { $0.AppleMusic == Song.AppleMusic })){
                Button(action: {
                  let networkStatus: NetworkStatus = CheckNetworkStatus()
                  if(networkStatus == NetworkStatus.reachable){
                    Like = false
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
                  if(networkStatus == NetworkStatus.notConnected){ Offline = true }
                }){
                  Image(systemName: "heart.fill")
                    .frame(alignment: .leading)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("Red"))
                }
              }
            }
            .frame(width: 15, height: 15)
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
                      room.Playlist.LocalAdd.append(AddedSong)
                      room.AddSong = true
                      try await FirebaseManager.AddSongToPlaylistLocalAdd(Room: room, AuxrSong: AddedSong, account: user.Account ?? nil)
                    }
                    catch _ {}
                  }
                }
                if(networkStatus == NetworkStatus.notConnected){ Offline = true }
              }){
                Image(systemName: "plus")
                  .frame(alignment: .leading)
                  .font(.system(size: 15, weight: .semibold))
                  .foregroundColor(Color("Tertiary").opacity(0.8))
              }
              .frame(width: 15, height: 15, alignment: .leading)
            }
            if(Queuing && !Completed){
              ZStack{ QueuedLoaderView(Loading: $Queuing, Completed: $Completed) }
                .frame(width: 15, height: 15, alignment: .center)
            }
            if(!Queuing && Completed){
              ZStack{
                Image(systemName: "checkmark.circle.fill")
                  .frame(alignment: .leading)
                  .font(.system(size: 12, weight: .semibold))
                  .foregroundColor(Color("Tertiary"))
              }
              .frame(width: 15, height: 15)
            }
          }
          .offset(x: -UIScreen.main.bounds.size.width*0.033)
        }
        .frame(width: UIScreen.main.bounds.size.width*0.8, height: UIScreen.main.bounds.size.height*0.08, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
        HStack{
          Text(Song.QueuedBy)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color("Text"))
            .padding(.leading, UIScreen.main.bounds.size.width*0.02)
        }
        .frame(width: UIScreen.main.bounds.size.width*0.8, alignment: .leading)
      }
    }
    .padding(.top, 3)
    .onAppear{ Task{ AM_Song = try await appleMusic.ConvertSong(AuxrSong: Song) } }
    .onTapGesture(count: 2){
      Task{
        let networkStatus: NetworkStatus = CheckNetworkStatus()
        if(networkStatus == NetworkStatus.reachable){
          if(!(user.Likes.contains(where: { $0.AppleMusic == Song.AppleMusic }))){
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
