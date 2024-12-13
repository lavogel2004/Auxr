import SwiftUI
import OSLog

enum AuxrAccountOnboardingError: String, CaseIterable, Identifiable {
  case usernameInput,
       usernameTaken,
       passwordInput,
       confirmPasswordInput,
       passwordMismatch,
       appleMusicAuthorization,
       invalidReferral,
       loginUsername,
       loginPassword,
       lockedOut,
       unknown,
       none
  var id: Self { self }
}

class AuxrAccountOnboardingManager {
  init(){}
  
  // MARK: Login Loader Handler
  @MainActor
  func LoginUser(User: User, Username: String, Password: String, AppleMusic: AppleMusic) async -> AuxrAccountOnboardingError {
    do
    {
      try await AccountManager.login(username: Username, password: Password, user: User)
    }
    catch let error
    {
      let errorStr = error.localizedDescription
      if(errorStr.contains("There is no user record corresponding to this identifier. The user may have been deleted.")){
        return AuxrAccountOnboardingError.loginUsername
      }
      if(errorStr.contains("The password is invalid or the user does not have a password.")){
        return AuxrAccountOnboardingError.loginPassword
      }
      if(errorStr.contains("Access to this account has been temporarily disabled due to many failed login attempts.")){
        return AuxrAccountOnboardingError.lockedOut
      }
      return AuxrAccountOnboardingError.unknown
    }
    return AuxrAccountOnboardingError.none
  }
  
  // MARK: Create Account Handler
  @MainActor
  func CreateAuxrAccount(User: User, Username: String, Password: String, ConfirmPassword: String, ReferralCode: String) async -> AuxrAccountOnboardingError {
    if(Username.isEmpty){ return AuxrAccountOnboardingError.usernameInput }
    if(Password.isEmpty || Password.count < 6){ return AuxrAccountOnboardingError.passwordInput }
    // TODO: Check password requirements -> AuxrAccountOnboardingError.passwordInput
    if(ConfirmPassword.isEmpty){ return AuxrAccountOnboardingError.confirmPasswordInput }
    if(Password != ConfirmPassword){ return AuxrAccountOnboardingError.passwordMismatch }
    do
    {
      let valid_code = try await ReferralManager.isCodeValid(referral_code: ReferralCode)
      if(!ReferralCode.isEmpty && !valid_code){ return AuxrAccountOnboardingError.invalidReferral }
      try await AccountManager.createAccount(username: Username, password: Password, user: User)
    }
    catch let error
    {
      let errorStr = error.localizedDescription
      if(errorStr.contains("The email address is already in use by another account.")){ return AuxrAccountOnboardingError.usernameTaken }
      return AuxrAccountOnboardingError.unknown
    }
    return AuxrAccountOnboardingError.none
  }
  
  @MainActor
  func updatePassword(User: User, Password: String, ConfirmPassword: String) async -> AuxrAccountOnboardingError {
    if(Password.isEmpty || Password.count < 6){ return AuxrAccountOnboardingError.passwordInput }
    if(ConfirmPassword.isEmpty){ return AuxrAccountOnboardingError.confirmPasswordInput }
    if(Password != ConfirmPassword){ return AuxrAccountOnboardingError.passwordMismatch }
    do
    {
      try await AccountManager.updatePassword(new_password: Password)
    }
    catch let error
    {
      let errorStr = error.localizedDescription
      return AuxrAccountOnboardingError.unknown
    }
    return AuxrAccountOnboardingError.none
  }
  
  // MARK: Sign Up Extra Info Profile Step [genre]
  @MainActor
  func SignUpExtraInfoUserProfileStep(User: User) async -> AuxrAccountOnboardingError {
    return AuxrAccountOnboardingError.none
  }
}
