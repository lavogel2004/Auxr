import SwiftUI

struct AppleMusicPlaylistSongMenu: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  @Binding var Song: AuxrSong
  @Binding var Show: Bool
  @Binding var Remove: Bool
  @Binding var Like: Bool
  @Binding var PlayNow: Bool
  @Binding var UpNext: Bool
  @Binding var NoSong: Bool
  @Binding var Offline: Bool
  
  var body: some View {
    ZStack{
      if(Show){
        VStack(alignment: .leading, spacing: 5){
          Spacer().frame(height: 0)
          
          // MARK: Play Now Button
          if(room.Host(User: user)){
            Button(action: {
              withAnimation(.easeInOut(duration: 0.2)){
                PlayNow = true
                Show = false
              }
              Task{
                let networkStatus: NetworkStatus = CheckNetworkStatus()
                if(networkStatus == NetworkStatus.reachable){
                  room.Controlled = true
                  try await FirebaseManager.UpdateRoomControlled(Room: room)
                  let currSong: AuxrSong = room.Playlist.Queue.sorted()[0]
                  if(Song == currSong){
                    room.Playlist.QueueInitializing = true
                    try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: room)
                    try await appleMusic.PlayerInit(Room: room)
                    room.Controlled = false
                    try await FirebaseManager.UpdateRoomControlled(Room: room)
                  }
                  else{
                    Song.Index = room.GlobalPlaylistIndex2
                    try await FirebaseManager.UpdateRoomGlobalPlaylistIndex2(Room: room)
                    try await FirebaseManager.UpdatePlaylistQueueSong(Room: room, AuxrSong: Song)
                    try await FirebaseManager.RemoveSongFromPlaylistQueue(Room: room, AuxrSong: currSong)
                    if(!room.PlaySong){
                      room.PlaySong = true
                      try await FirebaseManager.UpdateRoomPlaySong(Room: room)
                    }
                    room.Playlist.QueueInitializing = true
                    try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: room)
                    try await appleMusic.PlayerInit(Room: room)
                    room.Controlled = false
                    try await FirebaseManager.UpdateRoomControlled(Room: room)
                  }
                }
                if(networkStatus == NetworkStatus.notConnected){ Offline = false }
              }
            }){
              HStack{
                Image(systemName: "play.fill")
                  .font(.system(size: 15, weight: .bold))
                  .foregroundColor(Color("Tertiary"))
                  .frame(width: 20, height: 20, alignment: .center)
                Text("Play Now")
                  .font(.system(size: 13, weight: .bold))
                  .foregroundColor(Color("Text"))
              }
              .padding(5)
              .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
            }
            Divider()
              .frame(width: UIScreen.main.bounds.size.width*0.4, height: 1)
              .background(Color("LightGray").opacity(0.6))
          }
          
          // MARK: Up Next Button
          if(room.Host(User: user)){
            if(room.Playlist.Queue.count > 2){
              if(Song != room.Playlist.Queue.sorted()[0] && Song != room.Playlist.Queue.sorted()[1]){
                Button(action: {
                  withAnimation(.easeInOut(duration: 0.2)){
                    UpNext = true
                    Show = false
                  }
                  Task{
                    let networkStatus: NetworkStatus = CheckNetworkStatus()
                    if(networkStatus == NetworkStatus.reachable){
                      if(!room.Controlled){
                        room.SongControlled = true
                        try await FirebaseManager.UpdateSongControlled(Room: room)
                        room.Controlled = true
                        try await FirebaseManager.UpdateRoomControlled(Room: room)
                        let secondSong: AuxrSong = room.Playlist.Queue.sorted()[1]
                        let tmp: Int = secondSong.Index
                        let tmpSong: AuxrSong = Song
                        try await FirebaseManager.RemoveSongFromPlaylistQueue(Room: room, AuxrSong: Song)
                        for i in 1..<room.Playlist.Queue.count{
                          room.Playlist.Queue.sorted()[i].Index += 1
                        }
                        try await FirebaseManager.UpdatePlaylistQueue(Room: room)
                        tmpSong.Index = tmp
                        try await FirebaseManager.AddSongToPlaylistQueue(Room: room, AuxrSong: tmpSong)
                        try await FirebaseManager.UpdateRoomGlobalPlaylistIndex(Room: room)
                        if(!appleMusic.player.queue.entries.isEmpty)
                        {
                          appleMusic.player.queue.entries.removeLast()
                          guard let AM_Song = try await appleMusic.ConvertSong(AuxrSong: tmpSong)
                          else{ return }
                          try await appleMusic.player.queue.insert(AM_Song, position: .afterCurrentEntry)
                        }
                        room.UpNext = true
                        try await FirebaseManager.UpdateRoomUpNext(Room: room)
                        room.Controlled = false
                        try await FirebaseManager.UpdateRoomControlled(Room: room)
                        room.SongControlled = false
                        try await FirebaseManager.UpdateSongControlled(Room: room)
                      }
                    }
                  }
                }){
                  HStack{
                    Image(systemName: "arrow.up")
                      .font(.system(size: 15, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                      .frame(width: 20, height: 20, alignment: .center)
                    Text("Up Next")
                      .font(.system(size: 13, weight: .bold))
                      .foregroundColor(Color("Text"))
                  }
                  .padding(5)
                  .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
                }
                Divider()
                  .frame(width: UIScreen.main.bounds.size.width*0.4, height: 1)
                  .background(Color("LightGray").opacity(0.6))
              }
            }
          }
          
          // MARK: Like Button
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
                // TODO: Give Credit to Queuer
              }
              if(networkStatus == NetworkStatus.notConnected){ Offline = true }
            }){
              HStack{
                Image(systemName: "heart")
                  .font(.system(size: 15, weight: .bold))
                  .foregroundColor(Color("Tertiary"))
                  .frame(width: 20, height: 20, alignment: .center)
                Text("Like")
                  .font(.system(size: 13, weight: .bold))
                  .foregroundColor(Color("Text"))
              }
              .padding(5)
              .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
            }
          }
          
          //MARK: Unlike Button
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
              HStack{
                Image(systemName: "heart.fill")
                  .font(.system(size: 15, weight: .bold))
                  .foregroundColor(Color("Tertiary"))
                  .frame(width: 20, height: 20, alignment: .center)
                Text("Unlike")
                  .font(.system(size: 13, weight: .bold))
                  .foregroundColor(Color("Tertiary"))
              }
              .padding(5)
              .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
            }
          }
          
          // MARK: Remove Button
          if(room.Host(User: user) ||
             room.RemovePermission ||
             (Song.QueuedBy == user.Nickname) || user.RemovePermission){
            if(room.Playlist.Queue.count > 1){
              Divider()
                .frame(width: UIScreen.main.bounds.size.width*0.4, height: 1)
                .background(Color("LightGray").opacity(0.6))
              Button(action: {
                let networkStatus: NetworkStatus = CheckNetworkStatus()
                if(networkStatus == NetworkStatus.reachable){
                  if(room.Playlist.Queue.count > 1 && !room.Controlled){
                    withAnimation(.easeOut(duration: 0.2)){ Show = false }
                    Task{
                      room.Playlist.TotalPlaytime = room.Playlist.QueueTotalPlaytime(Room: room)
                      try await FirebaseManager.UpdatePlaylistTotalPlaytime(Room: room)
                    }
                    Remove = true
                    if(Song == room.Playlist.Queue.sorted()[0] && !room.Controlled){
                      Task{
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
                    }
                    else{
                      Task{
                        room.Controlled = true
                        try await FirebaseManager.UpdateRoomControlled(Room: room)
                        if let i: Int = room.Playlist.History.firstIndex(where: { $0.ID == Song.ID }){
                          let historySong: AuxrSong = room.Playlist.History[i]
                          try await FirebaseManager.RemoveSongFromPlaylistHistory(Room: room, AuxrSong: historySong)
                        }
                        room.Playlist.Queue = room.Playlist.Queue.filter{ $0 != Song }
                        try await FirebaseManager.RemoveSongFromPlaylistQueue(Room: room, AuxrSong: Song)
                        room.Controlled = false
                        try await FirebaseManager.UpdateRoomControlled(Room: room)
                      }
                    }
                  }
                  else{ NoSong = true }
                }
                if(networkStatus == NetworkStatus.notConnected){ Offline = true }
              }){
                HStack{
                  Image(systemName: "slash.circle.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("Red"))
                    .frame(width: 20, height: 20, alignment: .center)
                  Text("Remove")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("Red"))
                }
                .padding(5)
                .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
              }
            }
          }
          Spacer().frame(height: 0)
        }
        .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
      }
    }
    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .trailing)
    .onTapGesture{ Show = false }
  }
}
