import SwiftUI

struct LoginLoaderView: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  let usr_act_onbrd_mgr: AuxrAccountOnboardingManager = AuxrAccountOnboardingManager()
  let TMR = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  @Binding var Username: String
  @Binding var Password: String
  @Binding var Loading: Bool
  @Binding var Success: Bool
  @Binding var Error: AuxrAccountOnboardingError
  
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
      Task{
        Error = await usr_act_onbrd_mgr.LoginUser(User: user, Username: Username, Password: Password, AppleMusic: appleMusic)
        if(Error == AuxrAccountOnboardingError.none){ Success = true }
      }
    }
  }
}
