import SwiftUI
import Combine

struct ResetPasswordView: View {
  @Environment(\.presentationMode) var Presentation
  @EnvironmentObject var user: User
  @State private var Error: AuxrAccountOnboardingError = AuxrAccountOnboardingError.none
  @State private var Password: String = ""
  @State private var ConfirmPassword: String = ""
  @State private var Success: Bool = false
  
  var body: some View {
    ZStack(alignment: .top){
      Color("Primary").edgesIgnoringSafeArea(.all)
      VStack(spacing: 10){
        ZStack{
          Button(action: { Presentation.wrappedValue.dismiss() }){
            Image(systemName: "chevron.left")
              .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .leading)
              .font(.system(size: 20, weight: .medium))
              .foregroundColor(Color("Tertiary"))
          }
        }
        .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .topLeading)
        .padding(.bottom, 20)
        Text("Enter new password")
          .font(.system(size: 14, weight: .semibold))
          .foregroundColor(Color("Text"))
          .padding(.bottom, 50)
        VStack(alignment: .leading){
          SecureField("Password", text: $Password)
            .font(.system(size: 16))
            .foregroundColor(Color("Text"))
            .frame(width: UIScreen.main.bounds.size.width*0.7, height: 35)
            .padding(.leading, 10)
            .disableAutocorrection(true)
            .onReceive(Just(Password)){  passwordInput in
              if(passwordInput.count > 20){ Password.removeLast() }
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
        }
        .padding(10)
        VStack(alignment: .leading){
          SecureField("Confirm Password", text: $ConfirmPassword)
            .font(.system(size: 16))
            .foregroundColor(Color("Text"))
            .frame(width: UIScreen.main.bounds.size.width*0.7, height: 35)
            .padding(.leading, 10)
            .disableAutocorrection(true)
            .onReceive(Just(ConfirmPassword)){  confirmPasswordInput in
              if(confirmPasswordInput.count > 20){ ConfirmPassword.removeLast() }
            }
          VStack(alignment: .leading, spacing: 5){
            Divider()
              .frame(width: UIScreen.main.bounds.size.width*0.7, height: 1)
              .background(Color((Error != AuxrAccountOnboardingError.confirmPasswordInput) ? "Tertiary" : "Red"))
              .offset(y: -15)
            Text("Confirm Password")
              .font(.system(size: 11, weight: .bold))
              .foregroundColor(Color("Text"))
              .offset(x: 2, y: -15)
          }
          .padding(.leading, 10)
        }
        .padding(10)
        
        AuxrAccountOnboardingErrorView(Error: $Error)
          .padding(10)
        Button(action: {
          let networkStatus: NetworkStatus = CheckNetworkStatus()
          if(networkStatus == NetworkStatus.reachable){
            Password = FormatTextFieldInput(Input: Password)
            ConfirmPassword = FormatTextFieldInput(Input: ConfirmPassword)
            Task{
              let usr_act_onbrd_mgr = AuxrAccountOnboardingManager()
              Error = await usr_act_onbrd_mgr.updatePassword(User: user, Password: Password, ConfirmPassword: ConfirmPassword)
              Success = Error == AuxrAccountOnboardingError.none ? true : false
              if Success { Presentation.wrappedValue.dismiss() }
            }
          }
        })
        {
          VStack{
            Text("Update password")
              .font(.system(size: 16, weight: .bold))
              .foregroundColor(Color("Text"))
          }
          .padding(10)
        }
      }
      .navigationBarHidden(true)
    }
  }
}
