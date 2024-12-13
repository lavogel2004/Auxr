import SwiftUI

struct ListenerMenu: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  
  @Binding var Show: Bool
  @Binding var SelectedUser: User
  @Binding var PlayPauseEnabled: Bool
  @Binding var SkipEnabled: Bool
  @Binding var RemoveEnabled: Bool
  @Binding var Removed: Bool
  
  @State private var ShowOfflineOverlay: Bool = false
  
  var body: some View {
    ZStack{
      if(ShowOfflineOverlay){ OfflineOverlay(networkStatus: NetworkStatus.notConnected, Show: $ShowOfflineOverlay) }
      if(Show){
        VStack(alignment: .leading, spacing: 5){
          Spacer().frame(height: 0)
          
          // MARK: User Play/Pause Permission
          Button(action: {
            if(SelectedUser.PlayPausePermission ||
               room.PlayPausePermission ||
               room.Creator(User: SelectedUser)){
              SelectedUser.PlayPausePermission = false
            }
            else if(!SelectedUser.PlayPausePermission &&
                    !room.PlayPausePermission &&
                    !room.Creator(User: SelectedUser)){
              SelectedUser.PlayPausePermission = true
              PlayPauseEnabled = true
            }
            Task{ try await FirebaseManager.UpdateUserPlayPausePermission(User: SelectedUser, Room: room) }
          }){
            if(SelectedUser.PlayPausePermission ||
               room.PlayPausePermission ||
               room.Creator(User: SelectedUser)){
              HStack{
                Image(systemName: "play.fill")
                  .font(.system(size: 15, weight: .bold))
                  .foregroundColor(Color("Tertiary"))
                  .frame(width: 20, height: 20, alignment: .center)
                Text("Play/Pause")
                  .font(.system(size: 13, weight: .bold))
                  .foregroundColor(Color("Text"))
              }
              .padding(5)
              .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
            }
            if(!SelectedUser.PlayPausePermission &&
               !room.PlayPausePermission &&
               !room.Creator(User: SelectedUser)){
              HStack{
                Image(systemName: "play")
                  .font(.system(size: 15, weight: .bold))
                  .foregroundColor(Color("Tertiary").opacity(0.6))
                  .frame(width: 20, height: 20, alignment: .center)
                Text("Play/Pause")
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
          
          // MARK: User Skip Permission
          Button(action: {
            let networkStatus: NetworkStatus = CheckNetworkStatus()
            if(networkStatus == NetworkStatus.reachable){
              if(SelectedUser.SkipPermission ||
                 room.SkipPermission ||
                 room.Creator(User: SelectedUser)){
                SelectedUser.SkipPermission = false
              }
              else if(!SelectedUser.SkipPermission  &&
                      !room.SkipPermission &&
                      !room.Creator(User: SelectedUser)){
                SelectedUser.SkipPermission = true
                SkipEnabled = true
              }
              Task{ try await FirebaseManager.UpdateUserSkipPermission(User: SelectedUser, Room: room) }
            }
            if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
          }){
            if(SelectedUser.SkipPermission ||
               room.SkipPermission ||
               room.Creator(User: SelectedUser)){
              HStack{
                Image(systemName: "forward.fill")
                  .font(.system(size: 15, weight: .bold))
                  .foregroundColor(Color("Tertiary"))
                  .frame(width: 20, height: 20, alignment: .center)
                Text("Skip")
                  .font(.system(size: 13, weight: .bold))
                  .foregroundColor(Color("Text"))
              }
              .padding(5)
              .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
            }
            if(!SelectedUser.SkipPermission &&
               !room.SkipPermission &&
               !room.Creator(User: SelectedUser)){
              HStack{
                Image(systemName: "forward")
                  .font(.system(size: 15, weight: .bold))
                  .foregroundColor(Color("Tertiary").opacity(0.6))
                  .frame(width: 20, height: 20, alignment: .center)
                Text("Skip")
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
          
          // MARK: User Remove Permission
          Button(action: {
            let networkStatus: NetworkStatus = CheckNetworkStatus()
            if(networkStatus == NetworkStatus.reachable){
              if(SelectedUser.RemovePermission ||
                 room.RemovePermission ||
                 room.Creator(User: SelectedUser)){
                SelectedUser.RemovePermission = false
              }
              else if(!SelectedUser.RemovePermission &&
                      !room.RemovePermission &&
                      !room.Creator(User: SelectedUser)){
                SelectedUser.RemovePermission = true
                RemoveEnabled = true
              }
              Task{ try await FirebaseManager.UpdateUserRemovePermission(User: SelectedUser, Room: room) }
            }
            if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
          }){
            if(SelectedUser.RemovePermission ||
               room.RemovePermission ||
               room.Creator(User: SelectedUser)){
              HStack{
                Image(systemName: "xmark")
                  .font(.system(size: 15, weight: .bold))
                  .foregroundColor(Color("Tertiary"))
                  .frame(width: 20, height: 20, alignment: .center)
                Text("Remove")
                  .font(.system(size: 13, weight: .bold))
                  .foregroundColor(Color("Text"))
              }
              .padding(5)
              .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
            }
            if(!SelectedUser.RemovePermission &&
               !room.RemovePermission &&
               !room.Creator(User: SelectedUser)){
              HStack{
                Image(systemName: "xmark")
                  .font(.system(size: 15, weight: .bold))
                  .foregroundColor(Color("Tertiary").opacity(0.6))
                  .frame(width: 20, height: 20, alignment: .center)
                Text("Remove")
                  .font(.system(size: 13, weight: .bold))
                  .foregroundColor(Color("Text"))
              }
              .padding(5)
              .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
            }
          }
          
          // MARK: Remove Button
          if(!room.Creator(User: SelectedUser)){
            Divider()
              .frame(width: UIScreen.main.bounds.size.width*0.4, height: 1)
              .background(Color("LightGray").opacity(0.6))
            Button(action: {
              let networkStatus: NetworkStatus = CheckNetworkStatus()
              if(networkStatus == NetworkStatus.reachable){
                Task{
                  try await AccountManager.leaveChannel(account_id: SelectedUser.pai, room: room)
                  try await FirebaseManager.RemoveGuest(Room: room, User: SelectedUser)
                }
                Removed = true
                Show = false
              }
              if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
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
          Spacer().frame(height: 0)
        }
        .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
      }
    }
    .onTapGesture { Show = false }
  }
}
