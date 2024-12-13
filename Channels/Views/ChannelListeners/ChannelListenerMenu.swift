import SwiftUI

struct ChannelListenerMenu: View {
  @Environment(\.presentationMode) var Presentation
  @EnvironmentObject var router: Router
  @EnvironmentObject var user: User
  @EnvironmentObject var account: AuxrAccount
  @EnvironmentObject var appleMusic: AppleMusic
  
  let RoomID: String
  let SelectedUser: User
  
  @Binding var Show: Bool
  @Binding var SwapHost: Bool
  @Binding var SwapHostResponse: Bool
  @Binding var SwapHostError: Bool
  @Binding var AddedUser: Bool
  @Binding var AlreadyAdded: Bool
  @Binding var Removed: Bool
  @Binding var Offline: Bool
  
  @State private var channel: Room? = nil
  @State private var options: Int = 0
  @State private var noOptions: Bool = false
  
  var body: some View {
    ZStack{
      if(Show && (channel != nil)){
        VStack(alignment: .leading, spacing: 5){
          Spacer().frame(height: 0)
          if(!SelectedUser.pai.isEmpty){
            // MARK: View Profile Button
            if(SelectedUser.pai == account.ID){
              Button(action: {
                let networkStatus: NetworkStatus = CheckNetworkStatus()
                if(networkStatus == NetworkStatus.reachable){
                  Presentation.wrappedValue.dismiss()
                  router.selectedNavView = AccountViews.profile
                }
                if(networkStatus == NetworkStatus.notConnected){
                  UIApplication.shared.dismissKeyboard()
                  Offline = true
                }
              }){
                HStack{
                  Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: 20, height: 20, alignment: .center)
                  Text("Profile")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("Text"))
                }
                .padding(5)
                .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
              }
            }
            else{
              NavigationLink(destination: SelectedProfileView(friendID: SelectedUser.pai).environmentObject(account)){
                HStack{
                  Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: 20, height: 20, alignment: .center)
                  Text("Profile")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("Text"))
                }
                .padding(5)
                .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
              }
            }
            
            // MARK: Make channel Listener Host Button
            if((channel?.Creator(User: user) ?? false) ||
               ((channel?.BecomeHostPermission ?? false) && (SelectedUser.pai == account.ID))){
              Divider()
                .frame(width: UIScreen.main.bounds.size.width*0.4, height: 1)
                .background(Color("LightGray").opacity(0.6))
              Button(action: {
                let networkStatus: NetworkStatus = CheckNetworkStatus()
                if(networkStatus == NetworkStatus.reachable){ SwapHost = true }
                if(networkStatus == NetworkStatus.notConnected){ Offline = true }
              }){
                HStack{
                  Image(systemName: "person.2.wave.2.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: 20, height: 20, alignment: .center)
                  Text("Be Host")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("Text"))
                }
                .padding(5)
                .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
              }
              if(SwapHostResponse){
                Spacer().frame(height: 0).onAppear{
                  if(!(channel?.PlaySong ?? false)){
                    Show = false
                    Task{ try await FirebaseManager.SwapHost(Passcode: channel?.Passcode ?? "", User: SelectedUser) }
                    SwapHostResponse = false
                  }
                  else{ SwapHostError = true }
                }
              }
            }
            
            // MARK: Add Friend Button
            if(!account.Friends.contains(where: { $0.ID == SelectedUser.pai })){
              if(SelectedUser.pai != account.ID){
                Divider()
                  .frame(width: UIScreen.main.bounds.size.width*0.4, height: 1)
                  .background(Color("LightGray").opacity(0.6))
                Button(action: {
                  Task{
                    let networkStatus: NetworkStatus = CheckNetworkStatus()
                    if(networkStatus == NetworkStatus.reachable){
                      if(!account.FriendRequests.contains(where: { $0.ID == SelectedUser.pai })){
                        AddedUser = true
                        try await AccountManager.sendFriendRequest(account_id: SelectedUser.pai, user: user)
                      }
                      else{ AlreadyAdded = true }
                    }
                    if(networkStatus == NetworkStatus.notConnected){
                      UIApplication.shared.dismissKeyboard()
                      Offline = true
                    }
                  }
                }){
                  HStack{
                    Image(systemName: "plus")
                      .font(.system(size: 17, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                      .frame(width: 20, height: 20, alignment: .center)
                    Text("Friend User")
                      .font(.system(size: 13, weight: .bold))
                      .foregroundColor(Color("Text"))
                  }
                  .padding(5)
                  .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
                }
              }
            }
          }
          else{
            HStack{
              Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color("Tertiary"))
                .frame(width: 20, height: 20, alignment: .center)
              Text("No Account")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color("Text"))
            }
            .padding(5)
            .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
          }
          
          if(channel?.Creator(User: user) ?? false){
            if(SelectedUser.pai != account.ID){
              Divider()
                .frame(width: UIScreen.main.bounds.size.width*0.4, height: 1)
                .background(Color("LightGray").opacity(0.6))
              // MARK: Kick channel Listener Button
              Button(action: {
                let networkStatus: NetworkStatus = CheckNetworkStatus()
                if(networkStatus == NetworkStatus.reachable){
                  Task{
                    if let chnl: Room = channel{
                      try await AccountManager.leaveChannel(account_id: SelectedUser.pai, room: chnl)
                      try await FirebaseManager.RemoveGuest(Room: chnl, User: SelectedUser)
                    }
                  }
                  Removed = true
                  Show = false
                }
                if(networkStatus == NetworkStatus.notConnected){ Offline = true }
              }){
                HStack{
                  Image(systemName: "slash.circle.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("Red"))
                    .frame(width: 20, height: 20, alignment: .center)
                  Text("Kick")
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
    .frame(width: UIScreen.main.bounds.size.width*0.8, alignment: .trailing)
    .onTapGesture{ Show = false }
    .onAppear{
      Task{ channel = try await FirebaseManager.FetchRoomByID(ID: RoomID) }
      if(SelectedUser.pai != account.ID){ options += 1 }
      if((channel?.Creator(User: user) ?? false) ||
         (channel?.BecomeHostPermission ?? false)
      ){
        if(SelectedUser.pai != account.ID){ options += 1 }
      }
      if(!account.Friends.contains(where: { $0.ID == SelectedUser.pai })){
        if(SelectedUser.pai != account.ID){ options += 1 }
      }
      if(channel?.Creator(User: user) ?? false){
        if(SelectedUser.pai != account.ID){ options += 1 }
      }
      if(options <= 0){ noOptions = true }
    }
  }
}
