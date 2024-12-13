import SwiftUI

struct FriendInvitePopover: View {
  @AppStorage("isDarkMode") private var isDarkMode = false
  
  @EnvironmentObject var user: User
  
  let RoomID: String
  
  @Binding var Show: Bool
  @Binding var ShowOtherOptions: Bool
  @Binding var ShowShareOverlay: Bool
  
  @State private var SelectedFriendID: String = ""
  @State private var Loading: Bool = false
  @State private var LoadedResults: Int = 0
  @State private var Completed: Bool = false
  @State private var Channel: Room? = nil
  @State private var SendInvite: Bool = false
  @State private var CancelInvite: Bool = false
  @State private var CancelInviteResponse: Bool = false
  @State private var OtherOptions: Bool = false
  @State private var ShowOfflineOverlay: Bool = false
  @State private var ShowRemoveOverlay: Bool = false
  @State private var VerticalDragOffset: CGFloat = 0
  var body: some View {
    ZStack{
      Color("Secondary").edgesIgnoringSafeArea(.all)
      if let account: AuxrAccount = user.Account{
        ZStack{
          if(ShowOfflineOverlay){ OfflineOverlay(networkStatus: NetworkStatus.notConnected, Show: $ShowOfflineOverlay) }
          if(ShowRemoveOverlay){ GeneralOverlay(type: GeneralOverlayType.remove, Show: $ShowRemoveOverlay) }
          if(SendInvite){ GeneralOverlay(type: GeneralOverlayType.inviteChannel, Show: $SendInvite) }
          if(CancelInvite){ AccountOverlay(type: AccountOverlayType.cancelRoomRequest, Show: $CancelInvite, Response: $CancelInviteResponse) }
          
          HStack(alignment: .top){
            Button(action: { withAnimation(.easeInOut(duration: 0.2)){
              ShowOtherOptions = false
              ShowShareOverlay = false
              Show = false
            }}){
              Image(systemName: "chevron.down")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color("Tertiary"))
                .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .leading)
                .padding(.leading, 10)
            }
          }
          .frame(width: UIScreen.main.bounds.size.width*0.95, alignment: .topLeading)
          .offset(y: -UIScreen.main.bounds.size.height/2*0.82)
          
          ZStack{
            ZStack{
              VStack(spacing: 10){
                HStack(spacing: 3){
                  Text(Channel?.Name ?? "...")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("Text"))
                    .frame(height: 20, alignment: .bottom)
                  ZStack{
                    Text("#\(Channel?.Passcode  ?? "...")")
                      .font(.system(size: 17, weight: .semibold))
                      .foregroundColor(Color("Text"))
                      .frame(height: 20, alignment: .bottom)
                  }
                }
                HStack{
                  ZStack{
                    Text("Invite Friends")
                      .font(.system(size: 12, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.4, height: 25, alignment: .leading)
                  ZStack{
                    Button(action: {
                      withAnimation(.easeIn(duration: 0.4)){
                        ShowOtherOptions = true
                        ShowShareOverlay = true
                        Show = false
                      }
                    }){
                      Text("More Options")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color("Capsule").opacity(0.6))
                    }
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.4, height: 25, alignment: .trailing)
                }
              }
            }
          }
          .frame(width: UIScreen.main.bounds.size.width*0.9, height: UIScreen.main.bounds.size.height*0.75, alignment: .top)
          ZStack{
            if(account.Friends.isEmpty){
              VStack(spacing: 2){
                HStack(spacing: 4){
                  Text("No Friends")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("Capsule").opacity(0.6))
                }
                Text("Add friends to listen together")
                  .font(.system(size: 11, weight: .medium))
                  .foregroundColor(Color("Capsule").opacity(0.6))
              }
            }
            else{
              VStack{
                Text("Press To Invite")
                  .font(.system(size: 11, weight: .medium))
                  .foregroundColor(Color("Capsule").opacity(0.6))
                ScrollView(showsIndicators: false){
                  VStack(spacing: 11){
                    Spacer().frame(height: 0)
                    ForEach(account.Friends.sorted()){ friend in
                      FriendPopoverCell(friendID: friend.ID, roomID: RoomID, SelectedFriend: $SelectedFriendID, Loading: $Loading, LoadedResults: $LoadedResults, Completed: $Completed, SendInvite: $SendInvite, CancelInvite: $CancelInvite, Offline: $ShowOfflineOverlay)
                    }
                    Spacer().frame(height: 0)
                  }
                  if(account.Friends.count > 8){
                    Spacer().frame(width: 1, height: UIScreen.main.bounds.size.height*0.1)
                  }
                }
              }
              .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.85, alignment: .top)
              .padding(10)
            }
          }
          .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, alignment: .top)
          .offset(y: UIScreen.main.bounds.size.height*0.2)
          .gesture(
            DragGesture(coordinateSpace: .global)
              .onChanged{ value in
                if(value.translation.height > 0){
                  let dragDistance = min(value.translation.height, 20)
                  self.VerticalDragOffset = dragDistance
                }
                if(value.translation.height > 20){
                  DispatchQueue.main.asyncAfter(deadline: .now()){
                    withAnimation(.easeInOut(duration: 0.5)){
                      VerticalDragOffset = 0
                      ShowOtherOptions = false
                      ShowShareOverlay = false
                      Show = false
                    }
                  }
                }
              }
          )
        }
      }
      if(CancelInviteResponse){
        Spacer().frame(height: 0)
          .onAppear{
            Task{
              if let account: AuxrAccount = user.Account{
                if let i: Int = account.RoomRequests.firstIndex(where: {
                  $0.room_id == RoomID && $0.Receiver == SelectedFriendID }){
                  let request = account.RoomRequests[i]
                  try await AccountManager.denyRoomInvite(request: request, account: account)
                  CancelInviteResponse = false
                  ShowRemoveOverlay = true
                }
              }
            }
          }
      }
    }
    .navigationBarHidden(true)
    .colorScheme(isDarkMode ? .dark : .light)
    .onAppear{
      Task{
        if(Channel == nil){ Channel = try await FirebaseManager.FetchRoomByID(ID: RoomID) }
      }
    }
    .gesture(
      DragGesture(coordinateSpace: .global)
        .onChanged{ value in
          if(value.translation.height > 0){
            let dragDistance = min(value.translation.height, 20)
            self.VerticalDragOffset = dragDistance
          }
          if(value.translation.height > 20){
            DispatchQueue.main.asyncAfter(deadline: .now()){
              withAnimation(.easeInOut(duration: 0.5)){
                VerticalDragOffset = 0
                ShowOtherOptions = false
                ShowShareOverlay = false
                Show = false
              }
            }
          }
        }
    )
  }
}
