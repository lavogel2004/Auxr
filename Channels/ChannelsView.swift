import SwiftUI

struct ChannelsView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var room: Room
  @EnvironmentObject var user: User
  @EnvironmentObject var account: AuxrAccount
  @EnvironmentObject var appleMusic: AppleMusic
  
  let chnls_mgr: ChannelsManager = ChannelsManager()
  @State private var Joining: Bool = false
  @State private var Loading: Bool = false
  @State private var LoadedResults: Int = 0
  @State private var Success: Bool = false
  @State private var Completed: Bool = false
  @State private var Error: ChannelError = ChannelError.none
  @State private var SelectedChannel: String = ""
  @State private var SelectedChannelPasscode: String = ""
  @State private var ShowChannelMenu: Bool = false
  
  @State private var ShowOfflineOverlay: Bool = false
  @State private var ShowShareOverlay: Bool = false
  @State private var ShowFriendPopover: Bool = false
  @State private var OtherShareOptions: Bool = false
  @State private var ShowCopyOverlay: Bool = false
  @State private var ShowInfoOverlay: Bool = false
  @State private var ShowJoinRoomOverlay: Bool = false
  @State private var NameChange: Bool = false
  @State private var ShowRemoveOverlay: Bool = false
  @State private var Remove: Bool = false
  @State private var RemoveResponse: Bool = false
  @State private var noop: Bool = false
  @State private var reload: Bool = false
  @State private var Refreshing = false
  @State private var VerticalDragOffset: CGFloat = 0
  @State private var Animate = false
  
  var body: some View {
    ZStack{
      ZStack{
        Image("LogoNoText")
          .resizable()
          .frame(width: UIScreen.main.bounds.size.width*0.41, height: UIScreen.main.bounds.size.width*0.41)
          .opacity(0.3)
      }
      .zIndex(1)
      ZStack{
        if(ShowOfflineOverlay){ OfflineOverlay(networkStatus: NetworkStatus.notConnected, Show: $ShowOfflineOverlay) }
        if(ShowShareOverlay){ ShareOverlay(Passcode: SelectedChannelPasscode, Show: $ShowShareOverlay, Copied: $ShowCopyOverlay, ShowFriendPopover: $ShowFriendPopover, OtherOptions: $OtherShareOptions) }
        if(ShowCopyOverlay){ GeneralOverlay(type: GeneralOverlayType.copy, Show: $ShowCopyOverlay) }
        if(Remove){ AccountOverlay(type: AccountOverlayType.removeChannel, Show: $Remove, Response: $RemoveResponse).onAppear{ ShowChannelMenu = false } }
        else if(ShowRemoveOverlay){ GeneralOverlay(type: GeneralOverlayType.remove, Show: $ShowRemoveOverlay) }
        
        if(!Success){
          ZStack{
            HStack(spacing: 3){
              Text("Sessions")
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(Color("Text"))
//              Button(action: { ShowInfoOverlay = true }){
//                ZStack{
//                  Image(systemName: "questionmark.circle.fill")
//                    .foregroundColor(Color("Tertiary"))
//                    .font(.system(size: 15, weight: .semibold))
//                }
//                .frame(width: 30, alignment: .center)
//              }
            }
            .padding(3)
          }
          .padding(10)
          .frame(width:UIScreen.main.bounds.size.width*0.95, alignment: .topLeading)
          .offset(y: -UIScreen.main.bounds.size.height*0.4)
          // MARK: Channels Scroll View
          if(!account.Channels.isEmpty){
            ZStack{
              ScrollView(showsIndicators: false){
                Spacer().frame(height: 1)
                VStack(alignment: .center, spacing: 0){
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
                    .padding(.bottom, 25)
                    .offset(y: 10)
                  }
                  ForEach(account.Channels.sorted()){ channel in
                    ChannelCell(Channel: channel, Loading: $Loading, LoadedResults: $LoadedResults, Completed: $Completed, Selected: $SelectedChannel, ShowMenu: $ShowChannelMenu, Passcode: $SelectedChannelPasscode, Joining: $Joining, Joined: $ShowJoinRoomOverlay, NameChange: $NameChange, Refresh: $Refreshing, Offline: $ShowOfflineOverlay).environmentObject(account)
                      .padding(.top, 15)
                    if(channel.RoomData.roomID == SelectedChannel){
                      if(ShowChannelMenu){
                        ChannelMenu(Show: $ShowChannelMenu, RoomID: $SelectedChannel, Passcode: $SelectedChannelPasscode, Joining: $Joining, Joined: $ShowJoinRoomOverlay, NameChange: $NameChange, Share: $ShowShareOverlay, Remove: $Remove, Offline: $ShowOfflineOverlay).environmentObject(account)
                          .offset(x: UIScreen.main.bounds.size.width*0.025, y: -11)
                      }
                    }
                  }
                  .disabled(Refreshing)
                  if(account.Channels.count > 5){ Spacer().frame(width: 1, height: UIScreen.main.bounds.size.height*0.1) }
                }
              }
              .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.height*0.78, alignment: .top)
              .offset(y: UIScreen.main.bounds.size.height*0.02)
              
            }
          }
          else{
            VStack(spacing: 2){
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
              VStack(spacing: 2){
                HStack(spacing: 4){
                  ZStack{
                    Image("SmallLogoNoText")
                      .resizable()
                      .frame(width: 26, height: 26)
                      .foregroundColor(Color("Capsule").opacity(0.6))
                  }
                  .offset(y: 2)
                  ZStack{
                    Text("No Sessions")
                      .font(.system(size: 15, weight: .medium))
                      .foregroundColor(Color("Capsule").opacity(0.6))
                  }
                  .offset(y: 6)
                }
                ZStack{
                  Text("Listen together by creating or joining")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color("Capsule").opacity(0.6))
                }
                .offset(y: 2)
              }
            }
            .frame(height: UIScreen.main.bounds.height*0.9, alignment: .center)
            .offset(y: -UIScreen.main.bounds.size.height*0.33)
          }
        }
        // MARK: Channel Loader
        if(Joining){
          AccountOverlay(type: AccountOverlayType.joinRoom, Show: $ShowJoinRoomOverlay, Response: $noop)
          NavigationLink(value: router.room){ EmptyView() }
            .onAppear{
              Task{
                if(account.AppleMusicConnected){
                  if(appleMusic.Subscription != .active){
                    appleMusic.CheckSubscription(completion: { _ in })
                  }
                }
                user.Nickname = (!account.DisplayName.isEmpty) ? account.DisplayName : account.Username
                Error = try await chnls_mgr.JoinChannel(User: user, Room: room, Passcode: SelectedChannelPasscode, AppleMusic: appleMusic)
                if(Error == ChannelError.none){ Success = true }
                router.currPath = router.room.path
                if(Success){
                  Completed = true
                }
              }
            }
            .navigationDestination(isPresented: $Completed){ RoomView() }
        }
        
        if(RemoveResponse){
          Spacer().frame(height: 0).onAppear{
            Task{
              let networkStatus: NetworkStatus = CheckNetworkStatus()
              if(networkStatus == NetworkStatus.reachable){
                var rm = try await FirebaseManager.FetchRoomByID(ID: SelectedChannel)
                if(rm.Host.pai == user.pai){
                  rm.Guests.append(user)
                  rm = try await FirebaseManager.AddGuest(Room: rm, User: user)
                  rm.Host = rm.Creator
                  rm = try await FirebaseManager.UpdateHost(Room: rm, User: rm.Creator)
                  try await FirebaseManager.RemoveGuest(Room: rm, User: rm.Creator)
                }
                try await FirebaseManager.RemoveGuest(Room: rm, User: user)
                try await AccountManager.leaveChannel(account_id: user.pai, room: rm)
                reload = true
                ShowRemoveOverlay = true
                RemoveResponse = false
              }
              else{ ShowOfflineOverlay = true }
            }
          }
        }
        if(Loading){ SearchLoaderView(Searching: $Loading, Completed: $Completed, length: 0.5)
            .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.height*0.75, alignment: .bottom)
        }
        if(reload){ Spacer().frame(height: 0) .onAppear{ reload = false } }
      }
      .zIndex(2)
      .onTapGesture { ShowChannelMenu = false }
      .onAppear{
        Loading = true
        reload = true
      }
      .popover(isPresented: $ShowFriendPopover){
        FriendInvitePopover(RoomID: SelectedChannel, Show: $ShowFriendPopover, ShowOtherOptions: $OtherShareOptions, ShowShareOverlay: $ShowShareOverlay)
          .onAppear{ ShowShareOverlay = false }
      }
      .gesture(
        DragGesture(coordinateSpace: .global)
          .onEnded { value in
            if(value.translation.height > 35){
              Refreshing = true
              withAnimation(.easeInOut(duration: 0.2)){
                VerticalDragOffset = 55
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
            if value.translation.height > 0 {
              withAnimation(.easeInOut(duration: 0.1)){
                self.VerticalDragOffset = value.translation.height
              }
            }
          }
      )
    }
  }
}
