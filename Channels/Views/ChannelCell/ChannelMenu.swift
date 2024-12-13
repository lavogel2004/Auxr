import SwiftUI

struct ChannelMenu: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var account: AuxrAccount
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  @Binding var Show: Bool
  @Binding var RoomID: String
  @Binding var Passcode: String
  @Binding var Joining: Bool
  @Binding var Joined: Bool
  @Binding var NameChange: Bool
  @Binding var Share: Bool
  @Binding var Remove: Bool
  @Binding var Offline: Bool
  
  @State private var channel: Room? = nil
  
  var body: some View {
    ZStack{
      if(channel != nil){
        ZStack{
          if(Show){
            VStack(alignment: .leading, spacing: 5){
              Spacer().frame(height: 0)
              // MARK: Join Button
              if(appleMusic.Authorized != .denied || appleMusic.Authorized != .restricted){
                Button(action: {
                  let networkStatus: NetworkStatus = CheckNetworkStatus()
                  if(networkStatus == NetworkStatus.reachable){
                    if(appleMusic.Authorized != .denied || appleMusic.Authorized != .restricted){
                      if let joinedChannel: Room = channel{
                        room.ID = joinedChannel.ID
                        room.Passcode = joinedChannel.Passcode
                        Passcode = joinedChannel.Passcode
                        Joining = true
                        Joined = true
                      }
                    }
                  }
                  if(networkStatus == NetworkStatus.notConnected){ Offline = true }
                }){
                  HStack{
                    Image(systemName: "ipad.and.arrow.forward")
                      .font(.system(size: 15, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                      .frame(width: 20, height: 20, alignment: .center)
                    Text("Connect")
                      .font(.system(size: 13, weight: .bold))
                      .foregroundColor(Color("Text"))
                  }
                  .padding(5)
                  .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
                }
              }
              Divider()
                .frame(width: UIScreen.main.bounds.size.width*0.4, height: 1)
                .background(Color("LightGray").opacity(0.6))
              // MARK: Invite Button
              if((channel?.Creator(User: user) ?? false) || (channel?.SharePermission ?? false)){
                Button(action: {
                  Share = true
                  Show = false
                }){
                  HStack{
                    Image(systemName: "person.fill.badge.plus")
                      .font(.system(size: 15, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                      .frame(width: 20, height: 20, alignment: .center)
                    Text("Invite")
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
              // MARK: Channel Listeners Button
              NavigationLink(destination: ChannelListenersView(RoomID: channel?.ID ?? "").environmentObject(account)){
                HStack{
                  Image(systemName: "eye.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: 20, height: 20, alignment: .center)
                  Text("Listeners")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("Text"))
                }
                .padding(5)
                .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
              }
              if(channel?.Creator(User: user) ?? false){
                Divider()
                  .frame(width: UIScreen.main.bounds.size.width*0.4, height: 1)
                  .background(Color("LightGray").opacity(0.6))
                // MARK: Channel Settings Button
                NavigationLink(destination: ChannelSettingsView(RoomID: channel?.ID ?? "" , Selected: $Show, NameChange: $NameChange)){
                  HStack{
                    Image(systemName: "gearshape.fill")
                      .font(.system(size: 15, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                      .frame(width: 20, height: 20, alignment: .center)
                    Text("Settings")
                      .font(.system(size: 13, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                  }
                  .padding(5)
                  .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
                }
              }
              else{
                Divider()
                  .frame(width: UIScreen.main.bounds.size.width*0.4, height: 1)
                  .background(Color("LightGray").opacity(0.6))
                // MARK: Channel Settings Button
                Button(action: { Remove = true }){
                  HStack{
                    Image(systemName: "slash.circle.fill")
                      .font(.system(size: 15, weight: .bold))
                      .foregroundColor(Color("Red"))
                      .frame(width: 20, height: 20, alignment: .center)
                    Text("Leave")
                      .font(.system(size: 13, weight: .bold))
                      .foregroundColor(Color("Red"))
                  }
                  .padding(5)
                  .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
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
          if let chnl = channel{
            Task{ Passcode = chnl.Passcode }
          }
        }
      }
    }
    .onAppear{ Task{ if(channel == nil){ channel = try await FirebaseManager.FetchRoomByID(ID: RoomID) } } }
    .zIndex(1)
  }
}
