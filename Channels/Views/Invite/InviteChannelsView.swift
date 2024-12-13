import SwiftUI

struct InviteChannelsView: View {
  @Environment(\.presentationMode) var Presentation
  @EnvironmentObject var appleMusic: AppleMusic
  @EnvironmentObject var account: AuxrAccount
  
  let SelectedFriendID: String
  
  @State private var SelectedChannelID: String = ""
  @State private var SendInvite: Bool = false
  @State private var CancelInvite: Bool = false
  @State private var CancelInviteResponse: Bool = false
  @State private var ShowOfflineOverlay: Bool = false
  @State private var ShowInvitedOverlay: Bool = false
  @State private var ShowRemoveOverlay: Bool = false
  @State private var Loading: Bool = false
  @State private var Loaded: Bool = false
  @State private var Completed: Bool = false
  @State private var Reload: Bool = false
  
  var body: some View {
    ZStack{
      Color("Secondary").edgesIgnoringSafeArea(.all)
      
      if(ShowOfflineOverlay){ OfflineOverlay(networkStatus: NetworkStatus.notConnected, Show: $ShowOfflineOverlay) }
      if(ShowInvitedOverlay){ GeneralOverlay(type: GeneralOverlayType.inviteChannel, Show: $ShowInvitedOverlay) }
      if(CancelInvite){ AccountOverlay(type: AccountOverlayType.cancelRoomRequest, Show: $CancelInvite, Response: $CancelInviteResponse) }
      else if(ShowRemoveOverlay){ GeneralOverlay(type: GeneralOverlayType.remove, Show: $ShowRemoveOverlay) }
      
      ZStack{
        Button(action: { Presentation.wrappedValue.dismiss()}){
          Image(systemName: "chevron.left")
            .frame(width: UIScreen.main.bounds.size.width*0.2, height: 20, alignment: .leading)
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(Color("Tertiary"))
            .padding(.leading, 10)
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.95, alignment: .topLeading)
      .offset(y: -UIScreen.main.bounds.size.height/2*0.85)
      
      VStack(spacing: 10){
        if(Loading){
          ZStack{
            SearchLoaderView(Searching: $Loading, Completed: $Completed, length: 0.5)
              .onAppear{
                Task{
                  let networkStatus: NetworkStatus = CheckNetworkStatus()
                  if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
                }
              }
          }
          .frame(height: UIScreen.main.bounds.size.height*0.9, alignment: .bottom)
        }
        
        if(Completed){
          HStack(spacing: 5){
            Image("LogoNoText")
              .resizable()
              .frame(width: UIScreen.main.bounds.size.height*0.13, height: UIScreen.main.bounds.size.height*0.13)
            ZStack{
              Text("Sessions")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color("Label"))
            }
            .padding(5)
            .background(Capsule().fill(Color("Capsule")).opacity(0.3))
          }
          .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .center)
          
          if(!account.Channels.isEmpty){
            ZStack{
              ZStack{
                ScrollView(showsIndicators: false){
                  ForEach(account.Channels.sorted()){ channel in
                    InviteChannelCell(Channel: channel, SelectedFriendID: SelectedFriendID, SelectedChannelID: $SelectedChannelID, Loaded: $Loaded, SendInvite: $ShowInvitedOverlay, CancelInvite: $CancelInvite, Offline: $ShowOfflineOverlay)
                  }
                }
              }
              .padding(10)
            }
            .frame(width: UIScreen.main.bounds.size.width*0.9, height: UIScreen.main.bounds.size.height*0.65)
            .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")).shadow(color: Color("Primary"), radius: 1))
          }
          else{
            ZStack{
              VStack(spacing: 2){
                HStack(alignment: .center, spacing: 4){
                  Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("Capsule").opacity(0.6))
                  Text("No Sessions")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("Capsule").opacity(0.6))
                }
                Text("Listen together by creating or joining")
                  .font(.system(size: 11, weight: .medium))
                  .foregroundColor(Color("Capsule").opacity(0.6))
              }
            }
            .frame(width: UIScreen.main.bounds.size.width*0.9, height: UIScreen.main.bounds.size.height*0.65)
            .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")).shadow(color: Color("Primary"), radius: 1))
          }
          HStack(spacing: 2){
            Text(String(account.Channels.count))
              .font(.system(size: 10, weight: .bold))
              .foregroundColor(Color("System"))
            Text("Sessions")
              .font(.system(size: 10, weight: .bold))
              .foregroundColor(Color("System"))
          }
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.9, height: UIScreen.main.bounds.size.height*0.85, alignment: .bottom)
      
      if(CancelInviteResponse){
        Spacer().frame(height: 0).onAppear{
          Task{
            if let i: Int = account.RoomRequests.firstIndex(where: {
              $0.room_id == SelectedChannelID }){
              let request = account.RoomRequests[i]
              try await AccountManager.denyRoomInvite(request: request, account: account)
              CancelInviteResponse = false
              ShowRemoveOverlay = true
            }
          }
        }
      }
    }
    .navigationBarHidden(true)
    .onAppear{ Loading = true }
    .gesture(DragGesture(minimumDistance: 15, coordinateSpace: .global)
      .onEnded { position in
        let HorizontalDrag = position.translation.width
        let VerticalDrag = position.translation.height
        if(abs(HorizontalDrag) > abs(VerticalDrag)){
          if(HorizontalDrag > 0){ Presentation.wrappedValue.dismiss() }
        }
      })
  }
}
