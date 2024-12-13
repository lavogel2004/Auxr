import SwiftUI

struct RoomOnboardingLoaderView: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  let rm_onbrd_mgr: RoomOnboardingManager = RoomOnboardingManager()
  let chnls_mgr: ChannelsManager = ChannelsManager()
  let TMR = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  @Binding var Loading: Bool
  @Binding var Success: Bool
  @Binding var Error: RoomOnboardingError
  
  @State private var LoadingTime = 2
  @State private var Animate = false
  
  var body: some View {
    ZStack{
      Color("Primary")
      
      HStack{
        Circle()
          .fill(Color("Tertiary"))
          .frame(width: 8, height: 8)
          .scaleEffect(Animate ? 1.0 : 0.5)
          .animation(.easeInOut(duration: 0.5).repeatForever(), value: Animate)
        Circle()
          .fill(Color("Tertiary"))
          .frame(width: 8, height: 8)
          .scaleEffect(Animate ? 1.0 : 0.5)
          .animation(.easeInOut(duration: 0.5).repeatForever().delay(0.3), value: Animate)
        Circle()
          .fill(Color("Tertiary"))
          .frame(width: 8, height: 8)
          .scaleEffect(Animate ? 1.0 : 0.5)
          .animation(.easeInOut(duration: 0.5).repeatForever().delay(0.6), value: Animate)
      }
      .task{ Animate = true }
      
    }
    .frame(width: UIScreen.main.bounds.size.width*0.5, height: 45)
    .cornerRadius(10)
    .onReceive(TMR){ _ in
      if(LoadingTime > 0){ LoadingTime -= 1 }
      else{ Loading = false }
    }
    .onAppear{
      // MARK: Loader Handler
      Task{
        if(!user.pai.isEmpty){
          if(room.Creator(User: user)){
            let cError = await chnls_mgr.CreateChannel(User: user, Room: room, AppleMusic: appleMusic)
            if(cError == ChannelError.none){ Success = true }
            else{ Error = chnls_mgr.ConvertChannelErrorToRoomOnboardingError(cError: cError) }
            if(Error == RoomOnboardingError.none){ Success = true }
          }
          else{
            let cError = try await chnls_mgr.JoinChannel(User: user, Room: room, Passcode: room.Passcode, AppleMusic: appleMusic)
            if(cError == ChannelError.none){ Success = true }
            else{ Error = chnls_mgr.ConvertChannelErrorToRoomOnboardingError(cError: cError) }
          }
        }
        else{
          if(room.Creator.ID == user.ID){
            Error = await rm_onbrd_mgr.CreateRoom(User: user, Room: room, AppleMusic: appleMusic)
            if(Error == RoomOnboardingError.none){ Success = true }
          }
          else{
            Error = try await rm_onbrd_mgr.JoinRoom(User: user, Room: room, AppleMusic: appleMusic)
            if(Error == RoomOnboardingError.none){ Success = true }
          }
        }
      }
    }
  }
}
