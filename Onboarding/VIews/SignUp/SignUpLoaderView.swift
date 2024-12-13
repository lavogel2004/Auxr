import SwiftUI

struct SignUpLoaderView: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  let usr_act_onbrd_mgr: AuxrAccountOnboardingManager = AuxrAccountOnboardingManager()
  let TMR = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  @Binding var Username: String
  @Binding var Password: String
  @Binding var ConfirmPassword: String
  @Binding var ReferralCode: String
  @Binding var Loading: Bool
  @Binding var Success: Bool
  @Binding var Error: AuxrAccountOnboardingError
  
  @State private var LoadingTime = 3
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
        Error = await usr_act_onbrd_mgr.CreateAuxrAccount(User: user, Username: Username, Password: Password, ConfirmPassword: ConfirmPassword, ReferralCode: ReferralCode)
        if(appleMusic.Authorized == .notDetermined){ try await appleMusic.Authorize() }
        if(appleMusic.Authorized == .denied || appleMusic.Authorized == .restricted){
          Error = AuxrAccountOnboardingError.appleMusicAuthorization
        }
        if(Error == AuxrAccountOnboardingError.none && (user.Account != nil)){
          do
          {
            try await ReferralManager.incrementReferral(referral_code: ReferralCode, current_user: user)
          }
          catch let error
          {
            print(error)
          }
          Success = true
        }
      }
    }
  }
}
