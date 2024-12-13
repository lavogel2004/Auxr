import SwiftUI

struct SelectedProfileView: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var account: AuxrAccount
  @EnvironmentObject var appleMusic: AppleMusic
  
  let friendID: String
  @Environment(\.presentationMode) var Presentation
  
  @State private var Friend: AuxrAccount?
  @State private var IsFriends: Bool = false
  @State private var FriendRequestPending: Bool = false
  @State private var FriendRequestToSender: Bool = false
  @State private var Filter: ProfileViewFilter = ProfileViewFilter.likes
  @State private var ProfilePicture: UIImage? = nil
  @State private var AcceptFriendRequest: Bool = false
  @State private var SendFriendRequest: Bool = false
  @State private var RemoveFriend: Bool = false
  @State private var RemoveFriendResponse: Bool = false
  @State private var CancelFriendRequest: Bool = false
  @State private var CancelFriendRequestResponse: Bool = false
  @State private var DenyFriendRequest: Bool = false
  @State private var DenyFriendRequestResponse: Bool = false
  @State private var ShowRemoveOverlay: Bool = false
  @State private var SongPlaying: Bool = false
  
  var body: some View {
    ZStack{
      if(AcceptFriendRequest){ GeneralOverlay(type: GeneralOverlayType.addedFriend, Show: $AcceptFriendRequest) }
      else if(CancelFriendRequest){ AccountOverlay(type: AccountOverlayType.cancelFriendRequest, Show: $CancelFriendRequest, Response: $CancelFriendRequestResponse) }
      else if(DenyFriendRequest){ AccountOverlay(type: AccountOverlayType.denyFriendRequest, Show: $DenyFriendRequest, Response: $DenyFriendRequestResponse) }
      else if(RemoveFriend){ AccountOverlay(type: AccountOverlayType.removeFriend, Show: $RemoveFriend, Response: $RemoveFriendResponse) }
      if(ShowRemoveOverlay){ GeneralOverlay(type: GeneralOverlayType.remove, Show: $ShowRemoveOverlay) }
      ZStack{
        Spacer()
          .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
          .background(Color("LightGray").edgesIgnoringSafeArea(.all))
      }
      .zIndex(0)
      HStack{
        Button(action: { Presentation.wrappedValue.dismiss() }){
          Image(systemName: "chevron.left")
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(Color("Tertiary"))
            .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .leading)
            .padding(.leading, 10)
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.95, alignment: .topLeading)
      .offset(y: -UIScreen.main.bounds.size.height/2*0.88)
      .zIndex(2)
      ZStack{
        VStack(spacing: 0){
          VStack(spacing: 10){
            HStack(spacing: UIScreen.main.bounds.size.width*0.1){
              VStack(spacing: 5){
                ZStack{
                  if let ProfilePicture = ProfilePicture{
                    Image(uiImage: ProfilePicture)
                      .resizable()
                      .clipShape(Circle())
                      .aspectRatio(contentMode: .fill)
                      .frame(width: UIScreen.main.bounds.size.width*0.25, height: UIScreen.main.bounds.size.width*0.25)
                      .background(Circle().fill(Color("Capsule").opacity(0.3)))
                  }
                  else{
                    Image(systemName: "person.fill")
                      .font(.system(size: 25, weight: .bold))
                      .clipShape(Circle())
                      .foregroundColor(Color("Capsule").opacity(0.6))
                      .frame(width: UIScreen.main.bounds.size.width*0.25, height: UIScreen.main.bounds.size.width*0.25)
                      .background(Circle().fill(Color("Capsule").opacity(0.3)))
                  }
                }
                .frame(width: UIScreen.main.bounds.size.width*0.18, alignment: .center)
                ZStack{
                  Text(Friend?.DisplayName ?? "")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.18, height: 30, alignment: .center)
                .offset(y: -5)
              }
              VStack(spacing: 10){
                ZStack{
                  VStack{
                    Text(Friend?.Username ?? "")
                      .font(.system(size: 25, weight: .bold))
                      .foregroundColor(Color("Text"))
                    if(IsFriends){
                      Text("Friends")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color("Tertiary"))
                    }
                    else if(FriendRequestPending){
                      Text("Friend Request Pending")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color("Tertiary"))
                    }
                  }
                }
                .frame(width: UIScreen.main.bounds.size.width, height: 30, alignment: .top)
                .offset(y: -UIScreen.main.bounds.size.height*0.02)
                HStack(spacing: 5){
                  NavigationLink(destination: FriendsProfileView(accountID: friendID).environmentObject(account)){
                    VStack(spacing: 2){
                      Text(String(Friend?.Friends.count ?? 0))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color("Text"))
                        .frame(height: 20)
                      Text("Friends")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("Text"))
                        .frame(height: 20)
                    }
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .bottom)
                  .disabled(Friend?.PrivateMode ?? false && !IsFriends)
                  VStack(spacing: 2){
                    Text(String(Friend?.Points ?? 0))
                      .font(.system(size: 15, weight: .semibold))
                      .foregroundColor(Color("Text"))
                    Text("Points")
                      .font(.system(size: 14, weight: .medium))
                      .foregroundColor(Color("Text"))
                      .frame(height: 20)
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .bottom)
                  VStack(spacing: 2){
                    Text(String(Friend?.Likes.count ?? 0))
                      .font(.system(size: 15, weight: .semibold))
                      .foregroundColor(Color("Text"))
                    Text("Likes")
                      .font(.system(size: 14, weight: .medium))
                      .foregroundColor(Color("Text"))
                      .frame(height: 20)
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .bottom)
                }
                .frame(width: UIScreen.main.bounds.size.width*0.55, alignment: .center)
                HStack{
                  if(!IsFriends){
                    if(!FriendRequestPending){
                      Button(action: {
                        Task{ try await AccountManager.sendFriendRequest(account_id: friendID, user: user) }
                        FriendRequestPending = true
                      }){
                        Text("Send Friend Request")
                          .foregroundColor(Color("Label"))
                          .font(.system(size: 14, weight: .medium))
                      }
                      .frame(width: UIScreen.main.bounds.size.width*0.55, height: 20, alignment: .center)
                      .padding(5)
                      .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")).shadow(color: Color("Shadow"), radius: 1))
                    }
                    else if(FriendRequestPending && !FriendRequestToSender){
                      Button(action: {
                        CancelFriendRequest = true
                      }){
                        Text("Pending")
                          .foregroundColor(Color("Tertiary"))
                          .font(.system(size: 14, weight: .medium))
                      }
                      .frame(width: UIScreen.main.bounds.size.width*0.55, height: 20, alignment: .center)
                      .padding(5)
                      .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Secondary"), radius: 1))
                    }
                    else if(FriendRequestPending && FriendRequestToSender){
                      Button(action: {
                        AcceptFriendRequest = true
                      }){
                        Text("Accept")
                          .foregroundColor(Color("Label"))
                          .font(.system(size: 14, weight: .medium))
                      }
                      .frame(width: UIScreen.main.bounds.size.width*0.3, height: 20, alignment: .center)
                      .padding(5)
                      .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")).shadow(color: Color("Tertiary"), radius: 1))
                      Button(action: {
                        DenyFriendRequest = true
                      }){
                        Text("Deny")
                          .foregroundColor(Color("Tertiary"))
                          .font(.system(size: 14, weight: .medium))
                      }
                      .frame(width: UIScreen.main.bounds.size.width*0.205, height: 20, alignment: .center)
                      .padding(5)
                      .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Secondary"), radius: 1))
                    }
                  }
                  else{
                    Button(action: { RemoveFriend = true }){
                      Text("Remove Friend")
                        .foregroundColor(Color("Tertiary"))
                        .font(.system(size: 14, weight: .medium))
                    }
                    .frame(width: UIScreen.main.bounds.size.width*0.3, height: 20, alignment: .center)
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Secondary"), radius: 1))
                    NavigationLink(destination: InviteChannelsView(SelectedFriendID: friendID).environmentObject(account)){
                      Text("Invite")
                        .foregroundColor(Color("Label"))
                        .font(.system(size: 14, weight: .medium))
                    }
                    .frame(width: UIScreen.main.bounds.size.width*0.205, height: 20, alignment: .center)
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")).shadow(color: Color("Shadow"), radius: 1))
                  }
                }
              }
              .frame(width: UIScreen.main.bounds.size.width*0.55, height: UIScreen.main.bounds.size.height*0.2, alignment: .center)
            }
          }
          .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.38, alignment: .bottom)
          .padding(.bottom, UIScreen.main.bounds.size.height*0.01)
          .background(Color("Primary"))
          .offset(y: -UIScreen.main.bounds.size.height*0.2)
          .zIndex(2)
          if(!(Friend?.PrivateMode ?? false) || IsFriends){
            ZStack{
              VStack{
                HStack(spacing: UIScreen.main.bounds.size.width*0.15){
                  Button(action: {
                    Filter = ProfileViewFilter.likes
                  }){
                    HStack(spacing: 10){
                      VStack(spacing: 10){
                        Image(systemName: "heart.fill")
                          .foregroundColor(Color("Tertiary"))
                          .font(.system(size: 20, weight: .medium))
                        RoundedRectangle(cornerRadius: 3)
                          .fill((Filter == ProfileViewFilter.likes) ? Color("Tertiary") : Color.clear)
                          .frame(width: 20, height: 2)
                      }
                      ZStack{
                        if(SongPlaying){ ZStack{ AudioVisualizer() } .frame(width: UIScreen.main.bounds.size.width*0.1) }
                        else{ Spacer().frame(width: UIScreen.main.bounds.size.width*0.1) }
                      }
                      .offset(y: -1.5)
                    }
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.5, alignment: .center)
                  Button(action: {
                    Filter = ProfileViewFilter.rooms
                  }){
                    VStack(spacing: 10){
                      ZStack{
                        Image("LogoNoText")
                          .resizable()
                          .frame(width: 30, height: 30)
                      }
                      .frame(width: 20, height: 20)
                      .offset(y: -2)
                      RoundedRectangle(cornerRadius: 3)
                        .fill((Filter == ProfileViewFilter.rooms) ? Color("Tertiary") : Color.clear)
                        .frame(width: 25, height: 2)
                    }
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.5, alignment: .center)
                }
                .frame(width: UIScreen.main.bounds.size.width, alignment: .center)
                .padding(.leading, 10)
                .padding(.bottom, UIScreen.main.bounds.size.height*0.01)
                
                if(Filter == ProfileViewFilter.likes){
                  if(Friend?.Likes.isEmpty ?? false){
                    VStack(spacing: 2){
                      HStack(spacing: 4){
                        ZStack{
                          Image(systemName: "heart.fill")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color("Capsule").opacity(0.6))
                        }
                        .offset(y: -1.5)
                        Text("No Likes")
                          .font(.system(size: 15, weight: .medium))
                          .foregroundColor(Color("Capsule").opacity(0.6))
                      }
                      .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.48, alignment: .top)
                      .padding(.leading, 10)
                    }
                  }
                  else{
                    ZStack{
                      ScrollView(showsIndicators: false){
                        Spacer().frame(height: 1)
                        VStack(alignment: .center, spacing: 20){
                          if(!(Friend?.HideLikes ?? false)){
                            ForEach(Friend?.Likes.sorted() ?? []){ song in
                              ProfileLikeSongCell(Song: song, profileID: friendID, Remove: $ShowRemoveOverlay, SongPlaying: $SongPlaying)
                            }
                            if(Friend?.Likes.count ?? 0 > 5){
                              Spacer().frame(width: 1, height: UIScreen.main.bounds.size.height*0.04)
                            }
                          }
                          else{
                            VStack(spacing: 2){
                              HStack(spacing: 4){
                                Image(systemName: "exclamationmark.lock.fill")
                                  .font(.system(size: 15, weight: .medium))
                                  .foregroundColor(Color("Capsule").opacity(0.6))
                                Text("Hidden Likes")
                                  .font(.system(size: 15, weight: .medium))
                                  .foregroundColor(Color("Capsule").opacity(0.6))
                              }
                              Text("Likes are currently hidden")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color("Capsule").opacity(0.6))
                            }
                            .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.65, alignment: .top)
                          }
                        }
                        .frame(width: UIScreen.main.bounds.size.width)
                      }
                      .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.65, alignment: .top)
                    }
                    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.55, alignment: .top)
                  }
                }
                if(Filter == ProfileViewFilter.rooms){
                  if(Friend?.Channels.isEmpty ?? false){
                    VStack(spacing: 2){
                      HStack(spacing: 4){
                        ZStack{
                          Image("SmallLogoNoText")
                            .resizable()
                            .frame(width: 23, height: 23)
                            .foregroundColor(Color("Capsule").opacity(0.6))
                        }
                        .offset(y: -3)
                        ZStack{
                          Text("No Sessions")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color("Capsule").opacity(0.6))
                        }
                      }
                    }
                    .frame(width: UIScreen.main.bounds.size.width*0.9, height: UIScreen.main.bounds.size.height*0.57, alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Secondary"), radius: 1))
                  }
                  else{
                    ZStack{
                      ScrollView(showsIndicators: false){
                        Spacer().frame(height: 7.5)
                        VStack(alignment: .center, spacing: 5){
                          if(!(Friend?.HideChannels ?? false)){
                            ForEach(Friend?.Channels.sorted() ?? []){ channel in
                              ProfileChannelCell(Channel: channel)
                                .padding(.top, 5)
                            }
                          }
                          else{
                            VStack(spacing: 2){
                              HStack(spacing: 4){
                                Image(systemName: "exclamationmark.lock.fill")
                                  .font(.system(size: 15, weight: .medium))
                                  .foregroundColor(Color("Capsule").opacity(0.6))
                                Text("Hidden Sessions")
                                  .font(.system(size: 15, weight: .medium))
                                  .foregroundColor(Color("Capsule").opacity(0.6))
                              }
                              Text("Sessions are currently hidden")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(Color("Capsule").opacity(0.6))
                            }
                            .frame(width: UIScreen.main.bounds.size.width*0.9, height: UIScreen.main.bounds.size.height*0.57, alignment: .center)
                          }
                        }
                      }
                    }
                    .frame(width: UIScreen.main.bounds.size.width*0.9, height: UIScreen.main.bounds.size.height*0.57)
                    .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Secondary"), radius: 1))
                  }
                }
              }
              .offset(y: -UIScreen.main.bounds.size.height*0.18)
            }
          }
          else{
            VStack(spacing: 2){
              HStack(spacing: 4){
                Image(systemName: "exclamationmark.lock.fill")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Capsule").opacity(0.6))
                Text("Private Profile")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Capsule").opacity(0.6))
              }
              Text("Become friends to discover new music together")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color("Capsule").opacity(0.6))
            }
            .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.65, alignment: .center)
            .offset(y: -UIScreen.main.bounds.size.height*0.18)
          }
        }
        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.83, alignment: .top)
        .zIndex(2)
      }
      .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, alignment: .center)
      .zIndex(0)
      
      if(AcceptFriendRequest ||
         RemoveFriendResponse ||
         CancelFriendRequestResponse ||
         DenyFriendRequestResponse){
        Spacer().frame(height: 0)
          .onAppear{
            if(RemoveFriendResponse){
              Task{ try await AccountManager.removeFriend(friendID: friendID) }
              IsFriends = false
              RemoveFriendResponse = false
              ShowRemoveOverlay = true
            }
            if(CancelFriendRequestResponse){
              if let i: Int = account.FriendRequests.firstIndex(where: {
                $0.Receiver == friendID }){
                let request: AuxrRequest = account.FriendRequests[i]
                Task{ try await AccountManager.denyFriendRequest(request: request) }
                FriendRequestPending = false
                CancelFriendRequestResponse = false
                ShowRemoveOverlay = true
              }
            }
            if(AcceptFriendRequest){
              if let i: Int = account.FriendRequests.firstIndex(where: {
                $0.Receiver == account.ID }){
                let request: AuxrRequest = account.FriendRequests[i]
                Task{ try await AccountManager.acceptFriendRequest(request: request, user: user) }
              }
              FriendRequestPending = false
              IsFriends = true
            }
            if(DenyFriendRequestResponse){
              if let i: Int = account.FriendRequests.firstIndex(where: {
                $0.Sender == friendID }){
                let request: AuxrRequest = account.FriendRequests[i]
                Task{ try await AccountManager.denyFriendRequest(request: request) }
              }
              FriendRequestPending = false
              FriendRequestToSender = false
              IsFriends = false
              DenyFriendRequestResponse = false
            }
          }
      }
      
    }
    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, alignment: .center)
    .navigationBarHidden(true)
    .onAppear{
      Task{
        if let i: Int = account.FriendRequests.firstIndex(where: { $0.Sender == friendID }){
          if(!account.FriendRequests[i].Responded){ FriendRequestPending = true }
          else{ FriendRequestPending = false }
          FriendRequestToSender = true
        }
        else if let i: Int = account.FriendRequests.firstIndex(where: { $0.Receiver == friendID }){
          if(!account.FriendRequests[i].Responded){ FriendRequestPending = true }
          else{ FriendRequestPending = false }
        }
        Friend = try await AccountManager.getAccount(account_id: friendID)
        if let i: Int = account.Friends.firstIndex(where: { $0.ID == friendID }){
          if(!account.Friends[i].ID.isEmpty){ IsFriends = true }
          else{ IsFriends = false }
        }
        ProfilePicture = try await AccountManager.getProfilePicture(account_id: friendID)
      }
    }
    .gesture(DragGesture(minimumDistance: 25, coordinateSpace: .global)
      .onEnded{ position in
        let HorizontalDrag = position.translation.width
        let VerticalDrag = position.translation.height
        if(abs(HorizontalDrag) > abs(VerticalDrag)){
          if(HorizontalDrag > 0){ Presentation.wrappedValue.dismiss() }
        }
      })
    .onAppear{
      appleMusic.player.stop()
      appleMusic.player.queue.entries = []
      appleMusic.Queue = []
    }
    .onDisappear{
      appleMusic.player.stop()
      appleMusic.player.queue.entries = []
      appleMusic.Queue = []
    }
  }
}

