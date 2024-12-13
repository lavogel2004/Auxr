import SwiftUI
import MusicKit

struct InboxCell: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var account: AuxrAccount
  @EnvironmentObject var appleMusic: AppleMusic
  
  let requester_ID: String
  let Request: AuxrRequest
  let chnls_mgr: ChannelsManager = ChannelsManager()
  
  @Binding var SelectedRequest: AuxrRequest
  @Binding var AcceptFriendRequest: Bool
  @Binding var AcceptRoomRequest: Bool
  @Binding var DenyFriendRequest: Bool
  @Binding var DenyRoomRequest: Bool
  @Binding var Passcode: String
  @Binding var Offline: Bool
  @Binding var SongPlaying: Bool
  @Binding var Success: Bool
  
  @State private var Requester: AuxrAccount? = nil
  @State private var RequestedRoom: Room? = nil
  @State private var AM_Song: Song? = nil
  @State private var TimeElapsed: String = ""
  @State private var ProfileImage: UIImage? = nil
  
  var body: some View {
    ZStack{
      if(Requester != nil){
        VStack{
          switch(Request.type){
          case AuxrRequestType.friend:
            VStack{
              if(Requester != nil){
                HStack(spacing: 10){
                  if let UserImage = ProfileImage{
                    Image(uiImage: UserImage)
                      .resizable()
                      .clipShape(Circle())
                      .aspectRatio(contentMode: .fill)
                      .frame(width: UIScreen.main.bounds.size.height*0.045, height: UIScreen.main.bounds.size.height*0.045)
                      .background(Circle().fill(Color("Capsule").opacity(0.3)))
                  }
                  else{
                    Circle()
                      .fill(Color("Capsule").opacity(0.3))
                      .frame(width: UIScreen.main.bounds.size.height*0.045, height: UIScreen.main.bounds.size.height*0.045)
                      .onAppear{
                        Task{ ProfileImage = try await AccountManager.getProfilePicture(account_id: requester_ID) }
                      }
                  }
                  NavigationLink(destination: SelectedProfileView(friendID: requester_ID).environmentObject(account)){
                    VStack(spacing: 2){
                      Text(Requester?.Username ?? "AUXRUser")
                        .lineLimit(1)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color("Text"))
                        .frame(width: UIScreen.main.bounds.size.width*0.48, alignment: .leading)
                      Text("wants to be your friend.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("Text"))
                        .frame(width: UIScreen.main.bounds.size.width*0.48, alignment: .leading)
                      Text("\(TimeElapsed)")
                        .foregroundColor(Color("Capsule").opacity(0.6))
                        .font(.system(size: 9, weight: .bold))
                        .frame(width: UIScreen.main.bounds.size.width*0.48, alignment: .leading)
                    }
                    .frame(maxWidth: UIScreen.main.bounds.size.width*0.48, alignment: .leading)
                  }
                  HStack(spacing: UIScreen.main.bounds.size.width*0.05){
                    Button(action: {
                      Task{
                        SelectedRequest = Request
                        AcceptFriendRequest = true
                        try await AccountManager.acceptFriendRequest(request: Request, user: user)
                        if let account = user.Account{
                          try await AccountManager.addPoints(account: account, p: 1)
                        }
                        let FriendAccount = try await AccountManager.getAccount(account_id: Request.Sender)
                        try await AccountManager.addPoints(account: FriendAccount, p: 1)
                      }
                    }){
                      ZStack{
                        ZStack{
                          Text("ACCEPT")
                            .foregroundColor(Color("Label"))
                            .font(.system(size: 13, weight: .semibold))
                        }
                        .frame(width: UIScreen.main.bounds.size.width*0.2, height: 25)
                      }
                      .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")).shadow(color: Color("Shadow"), radius: 1))
                    }
                    Button(action: {
                      Task{
                        SelectedRequest = Request
                        DenyFriendRequest = true
                      }
                    }){
                      ZStack{
                        Image(systemName: "xmark")
                          .foregroundColor(Color("Capsule").opacity(0.6))
                          .font(.system(size: 12, weight: .bold))
                      }
                      .padding(5)
                    }
                    .offset(x: -UIScreen.main.bounds.size.width*0.02)
                  }
                }
                .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                .padding(10)
              }
              else{ Spacer().onAppear{ Task{ Requester = try await AccountManager.getAccount(account_id: requester_ID) } } }
            }
            .onAppear{
              Task{
                Requester = try await AccountManager.getAccount(account_id: requester_ID)
                ProfileImage = try await AccountManager.getProfilePicture(account_id: requester_ID)
                TimeElapsed = TimeElapsedString(Time: Request.timestamp)
              }
            }
          case AuxrRequestType.room:
            VStack{
              if(RequestedRoom != nil){
                HStack(spacing: 10){
                  if let UserImage = ProfileImage{
                    Image(uiImage: UserImage)
                      .resizable()
                      .clipShape(Circle())
                      .aspectRatio(contentMode: .fill)
                      .frame(width: UIScreen.main.bounds.size.height*0.045, height: UIScreen.main.bounds.size.height*0.045)
                      .background(Circle().fill(Color("Capsule").opacity(0.3)))
                  }
                  else{
                    Image(systemName: "person.fill")
                      .font(.system(size: 25, weight: .bold))
                      .clipShape(Circle())
                      .foregroundColor(Color("Capsule").opacity(0.6))
                      .frame(width: UIScreen.main.bounds.size.height*0.045, height: UIScreen.main.bounds.size.height*0.045)
                      .background(Circle().fill(Color("Capsule").opacity(0.3)))
                      .onAppear{
                        Task{ ProfileImage = try await AccountManager.getProfilePicture(account_id: requester_ID) }
                      }
                  }
                  NavigationLink(destination: SelectedProfileView(friendID: requester_ID).environmentObject(account)){
                    VStack(spacing: 2){
                      Text(Requester?.Username ?? "User")
                        .lineLimit(1)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color("Text"))
                        .frame(width: UIScreen.main.bounds.size.width*0.48, alignment: .leading)
                      Text("invited you to \(RequestedRoom?.Name ?? "a playlsit.")")
                        .lineLimit(1)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("Text"))
                        .frame(width: UIScreen.main.bounds.size.width*0.48, alignment: .leading)
                      Text("\(TimeElapsed)")
                        .foregroundColor(Color("Capsule").opacity(0.6))
                        .font(.system(size: 9, weight: .bold))
                        .frame(width: UIScreen.main.bounds.size.width*0.48, alignment: .leading)
                    }
                    .frame(maxWidth: UIScreen.main.bounds.size.width*0.48, alignment: .leading)
                  }
                  HStack(spacing: UIScreen.main.bounds.size.width*0.05){
                    Button(action: {
                      Task{
                        SelectedRequest = Request
                        let networkStatus: NetworkStatus = CheckNetworkStatus()
                        if(networkStatus == NetworkStatus.reachable){
                          if(appleMusic.Authorized != .denied || appleMusic.Authorized != .restricted){
                            if let rm: Room = RequestedRoom{
                              room.ID = rm.ID
                              room.Passcode = rm.Passcode
                              Passcode = rm.Passcode
                              try await AccountManager.acceptRoomInvite(request: SelectedRequest, account: account)
                              user.Nickname = (!account.DisplayName.isEmpty) ? account.DisplayName : account.Username
                              let Error = try await chnls_mgr.JoinChannel(User: user, Room: room, Passcode: rm.Passcode, AppleMusic: appleMusic)
                              if(Error == ChannelError.none){ Success = true }
                              AcceptRoomRequest = true
                              let FriendAccount = try await AccountManager.getAccount(account_id: Request.Sender)
                              try await AccountManager.addPoints(account: FriendAccount, p: 1)
                            }
                          }
                        }
                        if(networkStatus == NetworkStatus.notConnected){ Offline = true }
                      }
                    }){
                      ZStack{
                        ZStack{
                          Text("JOIN")
                            .foregroundColor(Color("Label"))
                            .font(.system(size: 13, weight: .semibold))
                        }
                        .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
                        .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")).shadow(color: Color("Shadow"), radius: 1))
                      }
                      .frame(width: UIScreen.main.bounds.size.width*0.2)
                    }
                    Button(action: {
                      Task{
                        SelectedRequest = Request
                        DenyRoomRequest = true
                      }
                    }){
                      ZStack{
                        Image(systemName: "xmark")
                          .foregroundColor(Color("Capsule").opacity(0.6))
                          .font(.system(size: 12, weight: .bold))
                      }
                      .padding(5)
                    }
                    .offset(x: -UIScreen.main.bounds.size.width*0.03)
                  }
                }
                .frame(width: UIScreen.main.bounds.size.width*0.88, alignment: .leading)
                .padding(10)
              }
              else{ Spacer().onAppear{ Task{ RequestedRoom = try await FirebaseManager.FetchRoomByID(ID: Request.room_id ?? "") } } }
            }
            .onAppear{
              Task{
                RequestedRoom = try await FirebaseManager.FetchRoomByID(ID: Request.room_id ?? "")
                if(RequestedRoom == nil){ RequestedRoom = try await FirebaseManager.FetchRoomByID(ID: Request.room_id ?? "") }
                Requester = try await AccountManager.getAccount(account_id: requester_ID)
                ProfileImage = try await AccountManager.getProfilePicture(account_id: requester_ID)
                TimeElapsed = TimeElapsedString(Time: Request.timestamp)
              }
            }
          case AuxrRequestType.like:
            VStack{
              if(AM_Song != nil){
                HStack(spacing: 10){
                  if let UserImage = ProfileImage{
                    Image(uiImage: UserImage)
                      .resizable()
                      .clipShape(Circle())
                      .aspectRatio(contentMode: .fill)
                      .frame(width: UIScreen.main.bounds.size.height*0.045, height: UIScreen.main.bounds.size.height*0.045)
                      .background(Circle().fill(Color("Capsule").opacity(0.3)))
                      .onAppear{
                        Task{ ProfileImage = try await AccountManager.getProfilePicture(account_id: requester_ID) }
                      }
                  }
                  else{
                    Image(systemName: "person.fill")
                      .font(.system(size: 25, weight: .bold))
                      .clipShape(Circle())
                      .foregroundColor(Color("Capsule").opacity(0.6))
                      .frame(width: UIScreen.main.bounds.size.height*0.045, height: UIScreen.main.bounds.size.height*0.045)
                      .background(Circle().fill(Color("Capsule").opacity(0.3)))
                  }
                  NavigationLink(destination: SelectedProfileView(friendID: requester_ID).environmentObject(account)){
                    VStack(spacing: 2){
                      HStack(spacing: 3){
                        Text(Requester?.Username ?? "User")
                          .lineLimit(1)
                          .font(.system(size: 14, weight: .bold))
                          .foregroundColor(Color("Text"))
                          .frame(alignment: .leading)
                        Text("liked")
                          .font(.system(size: 14, weight: .bold))
                          .foregroundColor(Color("Tertiary"))
                        Image(systemName: "heart.fill")
                          .font(.system(size: 14, weight: .bold))
                          .foregroundColor(Color("Tertiary"))
                      }
                      .frame(width: UIScreen.main.bounds.size.width*0.48, alignment: .leading)
                      Text("\(AM_Song?.title ?? "") by \(AM_Song?.artistName ?? "")")
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("Text"))
                        .frame(width: UIScreen.main.bounds.size.width*0.48, alignment: .leading)
                      HStack{
                        Text("\(TimeElapsed)")
                          .foregroundColor(Color("Capsule").opacity(0.6))
                          .font(.system(size: 9, weight: .bold))
                      }
                      .frame(width: UIScreen.main.bounds.size.width*0.48, alignment: .leading)
                    }
                    .frame(maxWidth: UIScreen.main.bounds.size.width*0.48, alignment: .leading)
                  }
                  HStack(spacing: UIScreen.main.bounds.size.width*0.05){
                    ZStack{
                      Button(action: {
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
                      }){
                        ZStack{
                          if let AlbumImage:Artwork = AM_Song?.artwork{
                            ZStack{
                              ArtworkImage(AlbumImage, width: UIScreen.main.bounds.size.height*0.06)
                            }
                            .padding(3)
                            .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
                            .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .center)
                          }
                          else{
                            ZStack{
                              Image(systemName: "music.note")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color("Tertiary"))
                                .frame(width: UIScreen.main.bounds.size.height*0.07, height: UIScreen.main.bounds.size.height*0.06)
                                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
                            }
                            .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .center)
                          }
                        }
                      }
                      .disabled(!account.AppleMusicConnected)
                    }
                    Button(action: { Task{ try await AccountManager.dismissLikeNotification(request: Request) } }){
                      ZStack{
                        Image(systemName: "xmark")
                          .foregroundColor(Color("Capsule").opacity(0.6))
                          .font(.system(size: 12, weight: .bold))
                      }
                      .padding(5)
                    }
                    .offset(x: -UIScreen.main.bounds.size.width*0.03)
                  }
                }
                .frame(width: UIScreen.main.bounds.size.width*0.88, alignment: .leading)
                .padding(10)
              }
              else{ Spacer().onAppear{ Task{  AM_Song = try await appleMusic.ConvertSongID(SongID: Request.song_id ?? "") } } }
            }
            .onAppear{
              Task{
                AM_Song = try await appleMusic.ConvertSongID(SongID: Request.song_id ?? "")
                if(AM_Song == nil){ AM_Song = try await appleMusic.ConvertSongID(SongID: Request.song_id ?? "") }
                ProfileImage = try await AccountManager.getProfilePicture(account_id: requester_ID)
                Requester = try await AccountManager.getAccount(account_id: requester_ID)
              }
            }
          }
        }
        .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .center)
      }
      else{
        ZStack{
          HStack(spacing: 10){
            Circle()
              .fill(Color("Capsule").opacity(0.3))
              .frame(width: UIScreen.main.bounds.size.height*0.045, height: UIScreen.main.bounds.size.height*0.045)
            VStack(alignment: .leading, spacing: 2){
              Capsule()
                .fill(Color("Capsule").opacity(0.3))
                .frame(width: UIScreen.main.bounds.size.height*0.2, height: 9, alignment: .leading)
                .padding(3)
              Capsule()
                .fill(Color("Capsule").opacity(0.3))
                .frame(width: UIScreen.main.bounds.size.height*0.25, height: 9, alignment: .leading)
                .padding(3)
            }
            .frame(maxWidth: UIScreen.main.bounds.size.width*0.48, alignment: .leading)
          }
          .onAppear{
            Task{
              ProfileImage = try await AccountManager.getProfilePicture(account_id: requester_ID)
              TimeElapsed = TimeElapsedString(Time: Request.timestamp)
              Requester = try await AccountManager.getAccount(account_id: requester_ID)
              RequestedRoom = try await FirebaseManager.FetchRoomByID(ID: Request.room_id ?? "")
              if let rm: Room = RequestedRoom{ Passcode = rm.Passcode }
            }
          }
        }
        .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
        .padding(10)
        .onAppear{
          Task{
            ProfileImage = try await AccountManager.getProfilePicture(account_id: requester_ID)
            TimeElapsed = TimeElapsedString(Time: Request.timestamp)
            Requester = try await AccountManager.getAccount(account_id: requester_ID)
            RequestedRoom = try await FirebaseManager.FetchRoomByID(ID: Request.room_id ?? "")
            if let rm: Room = RequestedRoom{ Passcode = rm.Passcode }
          }
        }
        
      }
    }
    .onAppear{
      Task{
        ProfileImage = try await AccountManager.getProfilePicture(account_id: requester_ID)
        TimeElapsed = TimeElapsedString(Time: Request.timestamp)
        Requester = try await AccountManager.getAccount(account_id: requester_ID)
        RequestedRoom = try await FirebaseManager.FetchRoomByID(ID: Request.room_id ?? "")
        if let rm: Room = RequestedRoom{ Passcode = rm.Passcode }
      }
    }
  }
}
