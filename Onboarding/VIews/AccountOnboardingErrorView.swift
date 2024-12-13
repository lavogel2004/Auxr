import SwiftUI

struct AuxrAccountOnboardingErrorView: View {
  @Binding var Error: AuxrAccountOnboardingError
  
  var body: some View {
    ZStack{
      ZStack{
        switch(Error){
        case AuxrAccountOnboardingError.usernameInput:
          ZStack{
            VStack(spacing: 4){
              HStack(alignment: .center, spacing: 4){
                Image(systemName: "exclamationmark.triangle.fill")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Red"))
                Text("Invalid Username")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Red"))
              }
              Text("Must be least 1 letter or number and contain no symbols")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color("Text"))
            }
          }
          
        case AuxrAccountOnboardingError.usernameTaken:
          ZStack{
            VStack(spacing: 4){
              HStack(alignment: .center, spacing: 4){
                Image(systemName: "exclamationmark.triangle.fill")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Red"))
                Text("Invalid Username")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Red"))
              }
              Text("Username is taken")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color("Text"))
            }
          }
          
        case AuxrAccountOnboardingError.passwordInput:
          ZStack{
            VStack(spacing: 4){
              HStack(alignment: .center, spacing: 4){
                Image(systemName: "exclamationmark.triangle.fill")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Red"))
                Text("Invalid Password")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Red"))
              }
              Text("Must be least 6 letters or numbers and contain no symbols")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color("Text"))
            }
          }
          
        case AuxrAccountOnboardingError.confirmPasswordInput:
          ZStack{
            VStack(spacing: 4){
              HStack(alignment: .center, spacing: 4){
                Image(systemName: "exclamationmark.triangle.fill")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Red"))
                Text("Invalid Password")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Red"))
              }
              Text("Please make sure to confirm your password")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color("Text"))
            }
          }
          
        case AuxrAccountOnboardingError.passwordMismatch:
          ZStack{
            VStack(spacing: 4){
              HStack(alignment: .center, spacing: 4){
                Image(systemName: "exclamationmark.triangle.fill")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Red"))
                Text("Invalid Password")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Red"))
              }
              Text("Please make sure password and confirm password match")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color("Text"))
            }
          }
          
        case AuxrAccountOnboardingError.appleMusicAuthorization:
          ZStack{
            VStack(spacing: 4){
              HStack(alignment: .center, spacing: 4){
                Image(systemName: "exclamationmark.triangle.fill")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Red"))
                Text("No Media & Apple Music")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Red"))
              }
              Text("Please enable in Settings > Auxr > Media & Apple Music")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color("Text"))
            }
          }
        case AuxrAccountOnboardingError.invalidReferral:
          ZStack{
            VStack(spacing: 4){
              HStack(alignment: .center, spacing: 4){
                Image(systemName: "exclamationmark.triangle.fill")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Red"))
                Text("Invalid referral code")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Red"))
              }
              Text("Please check that code is correct")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color("Text"))
            }
          }
        case AuxrAccountOnboardingError.loginUsername:
          ZStack{
            VStack(spacing: 4){
              HStack(alignment: .center, spacing: 4){
                Image(systemName: "exclamationmark.triangle.fill")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Red"))
                Text("Invalid Username")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Red"))
              }
              Text("AUXR user does not exist")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color("Text"))
            }
          }
        case AuxrAccountOnboardingError.loginPassword:
          ZStack{
            VStack(spacing: 4){
              HStack(alignment: .center, spacing: 4){
                Image(systemName: "exclamationmark.triangle.fill")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Red"))
                Text("Invalid Password")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Red"))
              }
              Text("Password input does not match AUXR user")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color("Text"))
            }
          }
        case AuxrAccountOnboardingError.lockedOut:
          ZStack{
            VStack(spacing: 4){
              HStack(alignment: .center, spacing: 4){
                Image(systemName: "exclamationmark.triangle.fill")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Red"))
                Text("Too many login attempts, try again later")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Red"))
              }
            }
          }
          
        case AuxrAccountOnboardingError.unknown:
          ZStack{
            VStack(spacing: 4){
              HStack(alignment: .center, spacing: 4){
                Image(systemName: "exclamationmark.triangle.fill")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Red"))
                Text("Unknown Error")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Red"))
              }
            }
          }
          
        case AuxrAccountOnboardingError.none: EmptyView().hidden()
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.85, alignment: .bottom)
    }
    .frame(alignment: .leading)
  }
}
