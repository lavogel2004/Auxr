import SwiftUI
import Combine

struct PasswordPrompt: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var user: User
  @EnvironmentObject var appleMusic: AppleMusic
  @Environment(\.presentationMode) var Presentation
  
  var destinationView: AnyView
  @State private var Error: AuxrAccountOnboardingError = AuxrAccountOnboardingError.none
  @State private var Password: String = ""
  @State private var isLoginSuccess = false
  
  var body: some View {
    ZStack{
      Color("Primary").edgesIgnoringSafeArea(.all)
      ZStack{
        Button(action: { Presentation.wrappedValue.dismiss() }){
          Image(systemName: "chevron.left")
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(Color("Tertiary"))
            .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .leading)
            .padding(.leading, 10)
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.95, alignment: .topLeading)
      .offset(y: -UIScreen.main.bounds.size.height/2*0.85)
      .zIndex(2)
      VStack(spacing: 10){
        Text("Please Enter Your Password To Continue")
          .font(.system(size: 15, weight: .semibold))
          .foregroundColor(Color("Text"))
          .frame(width: UIScreen.main.bounds.size.width, height: 35, alignment: .center)
        SecureField("Password", text: $Password)
          .font(.system(size: 16))
          .foregroundColor(Color("Text"))
          .frame(width: UIScreen.main.bounds.size.width*0.7, height: 35)
          .padding(.leading, 10)
          .disableAutocorrection(true)
          .onReceive(Just(Password)){  passwordInput in
            if(passwordInput.count > 20){ Password.removeLast() }
          }
          .onSubmit{
            Task{
              if let account = user.Account {
                let usr_act_onbrd_mgr = AuxrAccountOnboardingManager()
                Error = await usr_act_onbrd_mgr.LoginUser(User: user, Username: account.Username, Password: Password, AppleMusic: appleMusic)
                isLoginSuccess = Error == AuxrAccountOnboardingError.none ? true : false
              }
            }
          }
        VStack(alignment: .leading, spacing: 5){
          Divider()
            .frame(width: UIScreen.main.bounds.size.width*0.7, height: 1)
            .background(Color((Error != AuxrAccountOnboardingError.passwordInput) ? "Tertiary" : "Red"))
            .offset(y: -15)
          Text("Password")
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(Color("Text"))
            .offset(x: 2, y: -15)
        }
        .padding(.leading, 10)
        
        AuxrAccountOnboardingErrorView(Error: $Error)
        
        NavigationLink(destination: destinationView){
          Button("Continue"){
            Task{
              if let account = user.Account {
                let usr_act_onbrd_mgr = AuxrAccountOnboardingManager()
                Error = await usr_act_onbrd_mgr.LoginUser(User: user, Username: account.Username, Password: Password, AppleMusic: appleMusic)
                isLoginSuccess = Error == AuxrAccountOnboardingError.none ? true : false
              }
            }
          }
          .font(.system(size: 18, weight: .bold))
          .foregroundColor(Color("Text"))
          .frame(width: UIScreen.main.bounds.size.width*0.5, height: 45)
        }
        .navigationDestination(isPresented: $isLoginSuccess){ destinationView }
      }
      .offset(y: -UIScreen.main.bounds.size.height*0.27)
    }
    .ignoresSafeArea(.keyboard, edges: .all)
    .navigationBarHidden(true)
    .onAppear{ if isLoginSuccess{ Presentation.wrappedValue.dismiss() } }
  }
}
