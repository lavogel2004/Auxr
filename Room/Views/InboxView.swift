import SwiftUI

struct InboxView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var room: Room
  @EnvironmentObject var user: User
  @EnvironmentObject var account: AuxrAccount
  @EnvironmentObject var appleMusic: AppleMusic
  
  @State private var RoomInvites: Bool = true
  @State private var FriendRequests: Bool = false
  @State private var SelectedRequest: AuxrRequest = AuxrRequest(type: .friend, Sender: "", Receiver: "", params: nil, Responded: false)
  @State private var AcceptFriendRequest: Bool = false
  @State private var AcceptRoomRequest: Bool = false
  @State private var DenyFriendRequest: Bool = false
  @State private var DenyFriendRequestResponse: Bool = false
  @State private var RoomPasscode: String = ""
  @State private var DenyRoomRequest: Bool = false
  @State private var DenyRoomRequestResponse: Bool = false
  @State private var ShowOfflineOverlay: Bool = false
  @State private var ShowInfoOverlay: Bool = false
  @State private var ShowJoinRoomOverlay: Bool = false
  @State private var ShowRemoveOverlay: Bool = false
  @State private var localInbox:  Set<AuxrRequest> = []
  @State private var Loading: Bool = false
  @State private var SongPlaying: Bool = false
  @State private var Completed: Bool = false
  @State private var Success: Bool = false
  @State private var noop: Bool = false
  @State private var reload: Bool = false
  @State private var ShowClearAllOverlay: Bool = false
  @State private var ClearAllResponse: Bool = false
  
  var body: some View {
    ZStack{
      if(AcceptFriendRequest){ GeneralOverlay(type: GeneralOverlayType.addedFriend, Show: $AcceptFriendRequest) }
      else if(DenyFriendRequest){ AccountOverlay(type: AccountOverlayType.denyFriendRequest, Show: $DenyFriendRequest, Response: $DenyFriendRequestResponse) }
      else if(DenyRoomRequest){ AccountOverlay(type: AccountOverlayType.denyRoomRequest, Show: $DenyRoomRequest, Response:  $DenyRoomRequestResponse) }
      else if(ShowRemoveOverlay){ GeneralOverlay(type: GeneralOverlayType.remove, Show: $ShowRemoveOverlay) }
      else if(ShowClearAllOverlay){ AccountOverlay(type: AccountOverlayType.clearInbox, Show: $ShowClearAllOverlay, Response: $ClearAllResponse) }
      Spacer().frame(height: 10)
      ZStack{
        HStack(spacing: 3){
          Text("Inbox")
            .font(.system(size: 30, weight: .semibold))
            .foregroundColor(Color("Text"))
          ZStack{
            Button(action: {
              ShowClearAllOverlay = true
            }){
              ZStack{
                Text("Clear All")
                  .font(.system(size: 12, weight: .bold))
                  .foregroundColor(Color("Tertiary"))
              }
              .offset(y: 3)
            }
          }.frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(3)
      }
      .padding(10)
      .frame(width:UIScreen.main.bounds.size.width*0.95, alignment: .topLeading)
      .offset(y: -UIScreen.main.bounds.size.height*0.4)
      if(ClearAllResponse){
        Spacer().frame(height: 0).onAppear{
          Task{
            do
            {
              if let acct = user.Account {
                try await AccountManager.clearInbox(account: acct)
              }
            }
            catch let error {
              print(error)
            }
          }
        }
      }
      
      ZStack{
        if(SongPlaying){ AudioVisualizer() }
      }
      .frame(width:UIScreen.main.bounds.size.width*0.88, alignment: .topTrailing)
      .offset(y: -UIScreen.main.bounds.size.height*0.43)
      
      // MARK: Inbox Scroll View
      if(account.Inbox.isEmpty){
        ZStack{
          Text("Inbox Empty")
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(Color("Capsule").opacity(0.6))
        }
        .frame(height: UIScreen.main.bounds.height*0.9, alignment: .center)
      }
      else{
        //        ZStack{
        //          HStack(spacing: 3){
        //            Button(action: {
        //              print("Clear All")
        //            }){
        //              Text("CLEAR ALL")
        //                .font(.system(size: 13, weight: .bold))
        //                .foregroundColor(Color("Red"))
        //            }
        //          }
        //          .padding(3)
        //        }
        //        .padding(10)
        //        .frame(width:UIScreen.main.bounds.size.width*0.9, alignment: .topTrailing)
        //        .offset(y: -UIScreen.main.bounds.size.height*0.39)
        
        ScrollView(showsIndicators: false){
          Spacer().frame(height: 1)
          VStack(alignment: .center, spacing: 0){
            ForEach(account.Inbox.sorted()){ request in
              InboxCell(requester_ID: request.Sender, Request: request, SelectedRequest: $SelectedRequest, AcceptFriendRequest: $AcceptFriendRequest, AcceptRoomRequest: $AcceptRoomRequest, DenyFriendRequest: $DenyFriendRequest, DenyRoomRequest: $DenyRoomRequest, Passcode: $RoomPasscode, Offline: $ShowOfflineOverlay, SongPlaying: $SongPlaying, Success: $Success)
                .padding(.top, 11)
            }
            if(account.Inbox.count > 6){
              Spacer().frame(width: 1, height: UIScreen.main.bounds.size.height*0.02)
            }
          }
        }
        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.height*0.75, alignment: .top)
      }
      if(Loading){
        SearchLoaderView(Searching: $Loading, Completed: $Completed, length: 0.5)
          .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.height*0.75, alignment: .bottom)
      }
      // MARK: Channel Loader
      if(AcceptRoomRequest){
        AccountOverlay(type: AccountOverlayType.joinRoom, Show: $ShowJoinRoomOverlay, Response: $noop)
        NavigationLink(value: router.room){ EmptyView() }
          .onAppear{
            Task{
              if(account.AppleMusicConnected){
                if(appleMusic.Subscription != .active){
                  appleMusic.CheckSubscription(completion: { _ in })
                }
              }
              router.currPath = router.room.path
              if(Success){
                Completed = true
              }
            }
          }
          .navigationDestination(isPresented: $Completed){ RoomView() }
      }
      
      if(AcceptFriendRequest ||
         DenyFriendRequestResponse ||
         DenyRoomRequestResponse
      ){
        Spacer().frame(height: 0)
          .onAppear{
            Task{
              if(AcceptFriendRequest){
                try await AccountManager.acceptFriendRequest(request: SelectedRequest, user: user)
              }
              if(DenyFriendRequestResponse){
                try await AccountManager.denyFriendRequest(request: SelectedRequest)
                DenyFriendRequestResponse = false
                ShowRemoveOverlay = true
              }
              if(DenyRoomRequestResponse){
                try await AccountManager.denyRoomInvite(request: SelectedRequest, account: account)
                DenyRoomRequestResponse = false
                ShowRemoveOverlay = true
              }
            }
          }
      }
      else if(reload){ Spacer().frame(height: 0) .onAppear{ reload = false } }
    }
    .onAppear{
      Loading = true
      reload = true
      Task{ try await room.Reset() }
    }
  }
}
