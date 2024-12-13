import SwiftUI

enum AccountViews: String, CaseIterable, Identifiable {
  case channels,
       friends,
       inbox,
       profile
  var id: Self { self }
}

struct AccountView: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  @EnvironmentObject var account: AuxrAccount
  @EnvironmentObject var router: Router
  
  @State private var StartFriendsFilter: FriendsFilter = FriendsFilter.addFriends
  @State private var ShowCreateJoinMenu: Bool = false
  @State private var ShowFriendsResults: Bool = false
  @State private var Completed: Bool = false
  
  init(){
    UITableView.appearance().backgroundColor = UIColor(Color("Primary"))
    UIScrollView.appearance().bounces = false
  }
  
  var body: some View {
    ZStack{
      Color("Primary").edgesIgnoringSafeArea(.all)
      VStack{
        switch(router.selectedNavView){
          // MARK: Channels View
        case AccountViews.channels:
          ChannelsView().environmentObject(account)
          
          // MARK: Friends View
        case AccountViews.friends:
          FriendsView(Filter: $StartFriendsFilter).environmentObject(account)
          
          // MARK: Inbox View
        case AccountViews.inbox:
          InboxView().environmentObject(account)
        
          // MARK: Profile View
        case AccountViews.profile:
          ProfileView().environmentObject(account)
        }
      }
      
      // MARK: Create/Join Menu
      if(ShowCreateJoinMenu){
        ZStack{
          CreateJoinMenu(Show: $ShowCreateJoinMenu)
            .offset(y: UIScreen.main.bounds.size.height*0.34)
        }
        .padding(.bottom, UIScreen.main.bounds.size.height*0.015)
      }
      
      // MARK: Navigation Bar
      ZStack{ NavigationBar(CreateJoinMenu: $ShowCreateJoinMenu).environmentObject(account) }
        .offset(y: UIScreen.main.bounds.size.height*0.45)
    }
    .onAppear{
      if(account.AppleMusicConnected){
        if(appleMusic.Subscription != .active){
          appleMusic.CheckSubscription(completion: { _ in })
        }
      }
      user.Nickname = (!account.DisplayName.isEmpty) ? account.DisplayName : account.Username
    }
    .ignoresSafeArea(.keyboard, edges: .all)
    .navigationBarHidden(true)
    .onAppear{
      let initRoom: Room = Room()
      Task{ try await room.ReplaceAll(Room: initRoom) }
    }
  }
}
