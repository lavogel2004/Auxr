import SwiftUI
import Combine

struct SignUpRequiredStepView: View {
  @EnvironmentObject var user: User
  
  @Binding var Error: AuxrAccountOnboardingError
  @Binding var StepView: SignUpSteps
  @Binding var Offline: Bool
  
  @State private var Username: String = ""
  @State private var Password: String = ""
  @State private var ConfirmPassword: String = ""
  @State private var ReferralCode: String = ""
  @State private var Loading: Bool = false
  @State private var Success: Bool = false
  
  var body: some View {
    ZStack{
      VStack(spacing: 15){
        Spacer().frame(height: 0)
        VStack(alignment: .leading){
          TextField("Username", text: $Username)
            .font(.system(size: 16))
            .foregroundColor(Color("Text"))
            .frame(width: UIScreen.main.bounds.size.width*0.7, height: 35)
            .padding(.leading, 10)
            .disableAutocorrection(true)
            .onReceive(Just(Username)){ usernameInput in
              if(usernameInput.count > 20){ Username.removeLast() }
            }
          VStack(alignment: .leading, spacing: 5){
            Divider()
              .frame(width: UIScreen.main.bounds.size.width*0.7, height: 1)
              .background(Color((Error != AuxrAccountOnboardingError.usernameInput && Error != AuxrAccountOnboardingError.usernameTaken) ? "Tertiary" : "Red"))
              .offset(y: -15)
            Text("Username")
              .font(.system(size: 11, weight: .bold))
              .foregroundColor(Color("Text"))
              .offset(x: 2, y: -15)
          }
          .padding(.leading, 10)
        }
        
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
        
        VStack(alignment: .leading){
          TextField("Referral Code", text: $ReferralCode)
            .font(.system(size: 16))
            .foregroundColor(Color("Text"))
            .frame(width: UIScreen.main.bounds.size.width*0.7, height: 35)
            .padding(.leading, 10)
            .disableAutocorrection(true)
            .onReceive(Just(ReferralCode)){  referralCodeInput in
              if(referralCodeInput.count > 20){ ReferralCode.removeLast() }
            }
          VStack(alignment: .leading, spacing: 5){
            Divider()
              .frame(width: UIScreen.main.bounds.size.width*0.7, height: 1)
              .background(Color((Error != AuxrAccountOnboardingError.invalidReferral) ? "Tertiary" : "Red"))
              .offset(y: -15)
            Text("Referral Code")
              .font(.system(size: 11, weight: .bold))
              .foregroundColor(Color("Text"))
              .offset(x: 2, y: -15)
          }
          .padding(.leading, 10)
        }
      }
      .offset(y: UIScreen.main.bounds.size.height*0.08)
      .zIndex(4)
      
      ZStack{
        // MARK: Create Auxr Account Button
        if(!Loading && !Success){
          Button(action: {
            let networkStatus: NetworkStatus = CheckNetworkStatus()
            if(networkStatus == NetworkStatus.reachable){
              Username = FormatTextFieldInput(Input: Username)
              Password = FormatTextFieldInput(Input: Password)
              ConfirmPassword = FormatTextFieldInput(Input: ConfirmPassword)
              Loading = true
            }
            if(networkStatus == NetworkStatus.notConnected){
              UIApplication.shared.dismissKeyboard()
              Offline = true
            }
          })
          {
            VStack{
              Text("Sign Up")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color("Text"))
            }
          }
        }
        
        // MARK: Create Playlist Loader
        if(Loading){ SignUpLoaderView(Username: $Username, Password: $Password, ConfirmPassword: $ConfirmPassword, ReferralCode: $ReferralCode, Loading: $Loading, Success: $Success, Error: $Error) }
          
      }
      .offset(y: UIScreen.main.bounds.size.height*0.33)
      
      // MARK: Sign Up Errors
      AuxrAccountOnboardingErrorView(Error: $Error)
        .padding(10)
        .offset(y: UIScreen.main.bounds.size.height*0.43)
      
      if(Success){
        Spacer().frame(height: 0)
          .onAppear{ StepView = SignUpSteps.personalization }
      }
      
    }
    .frame(maxHeight: UIScreen.main.bounds.size.height, alignment: .top)
    .ignoresSafeArea(.keyboard, edges: .all)
    .onTapGesture { UIApplication.shared.dismissKeyboard() }
  }
}
