import SwiftUI
import Combine

struct SignUpPersonalizationStepView: View {
  @AppStorage("isDarkMode") private var isDarkMode = false
  
  @EnvironmentObject var router: Router
  @EnvironmentObject var user: User
  @EnvironmentObject var appleMusic: AppleMusic
  
  @Binding var Error: AuxrAccountOnboardingError
  @Binding var StepView: SignUpSteps
  @Binding var Offline: Bool
  
  
  @State private var ProfilePicture: UIImage? = nil
  @State private var SelectProfilePicture: Bool = false
  @State private var AppleMusicConnected: Bool = false
  @State private var DisplayName: String = ""
  @State private var Loading: Bool = false
  @State private var Success: Bool = false
  @State private var Completed: Bool = false
  
  var body: some View {
    if(user.Account != nil){
      VStack(spacing: UIScreen.main.bounds.size.width*0.1){
        Spacer().frame(height: 0)
        HStack(alignment: .bottom, spacing: UIScreen.main.bounds.size.width*0.08){
          
          // MARK: Set User Account Profile Picture
          VStack(spacing: 10){
            VStack(spacing: 10){
              Button(action: {
                SelectProfilePicture = true
              }){
                if let profilePicture = ProfilePicture{
                  Image(uiImage: profilePicture)
                    .resizable()
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.size.width*0.22, height: UIScreen.main.bounds.size.width*0.22)
                    .foregroundColor(Color("Label"))
                    .padding(10)
                }
                else{
                  Image(systemName: "person.fill")
                    .resizable()
                    .clipShape(Circle())
                    .foregroundColor(Color("Capsule").opacity(0.6))
                    .frame(width: UIScreen.main.bounds.size.width*0.22, height: UIScreen.main.bounds.size.width*0.22)
                    .padding(10)
                    .background(Circle().fill(Color("Capsule").opacity(0.3)))
                }
              }
              ZStack{
                Text("Profile Picture")
                  .font(.system(size: 11, weight: .bold))
                  .foregroundColor(Color("Text"))
                  .frame(height: 10)
              }
            }
            .frame(height: UIScreen.main.bounds.size.height*0.22, alignment: .bottom)
            Button(action: { ProfilePicture = nil }){
              ZStack{
                Image(systemName: "xmark")
                  .foregroundColor(Color("Capsule").opacity(0.6))
                  .font(.system(size: 12, weight: .bold))
              }
            }
          }
          .offset(y: 22.5)
          
          // MARK: Apple Music Icon Button
          Button(action: {
            let networkStatus: NetworkStatus = CheckNetworkStatus()
            if(networkStatus == NetworkStatus.reachable){
              Task{
                if(AppleMusicConnected){
                  AppleMusicConnected = false
                  if let account = user.Account{
                    account.AppleMusicConnected = false
                    appleMusic.Authorized = .notDetermined
                    appleMusic.CheckedForSubscription = false
                    appleMusic.Subscription = .notChecked
                  }
                }
                else{
                  if(appleMusic.Authorized == .notDetermined){ try await appleMusic.Authorize() }
                  if(appleMusic.Subscription == .active){ AppleMusicConnected = true }
                }
              }
            }
            if(networkStatus == NetworkStatus.notConnected){ Offline = true }
          }){
            VStack(spacing: 10){
              Image("AppleMusicIcon1")
                .resizable()
                .frame(width: 60, height: 60)
                .padding(10)
              
              if(appleMusic.Authorized == .restricted || appleMusic.Authorized == .denied){
                ZStack{
                  Circle()
                    .fill(Color("System"))
                    .frame(width: 10, height: 10)
                }
                .frame(width: UIScreen.main.bounds.size.width*0.25)
              }
              else if(appleMusic.Subscription == AppleMusicSubscriptionStatus.notActive){
                ZStack{
                  Text("No Subscription")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.25, height: 10)
              }
              else if(appleMusic.Subscription == AppleMusicSubscriptionStatus.active && AppleMusicConnected){
                ZStack{
                  Circle()
                    .fill(Color("Tertiary"))
                    .frame(width: 10, height: 10)
                }
                .frame(width: UIScreen.main.bounds.size.width*0.25, height: 10)
                
              }
              else{
                ZStack{
                  Text("Tap To Connect")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.25, height: 10)
              }
            }
          }
          .frame(height: UIScreen.main.bounds.size.height*0.22, alignment: .bottom)
          .offset(y: 0.5)
        }
        
        // MARK: Set User Account Display Name
        VStack(alignment: .leading){
          TextField("Display Name", text: $DisplayName)
            .font(.system(size: 16))
            .foregroundColor(Color("Text"))
            .frame(width: UIScreen.main.bounds.size.width*0.7, height: 35)
            .padding(.leading, 10)
            .disableAutocorrection(true)
            .onReceive(Just(DisplayName)){  userAccountDisplayNameInput in
              if(userAccountDisplayNameInput.count > 20){ DisplayName.removeLast() }
            }
          VStack(alignment: .leading, spacing: 5){
            Divider()
              .frame(width: UIScreen.main.bounds.size.width*0.7, height: 1)
              .background(Color("Tertiary"))
              .offset(y: -15)
            Text("Display Name")
              .font(.system(size: 11, weight: .bold))
              .foregroundColor(Color("Text"))
              .offset(x: 2, y: -15)
          }
          .padding(.leading, 10)
        }
        .padding(10)
      }
      .frame(maxHeight: UIScreen.main.bounds.size.height, alignment: .top)
      .sheet(isPresented: $SelectProfilePicture ){
        ImagePicker(image: $ProfilePicture)
      }
      .onAppear{ appleMusic.CheckSubscription(completion: { _ in }) }
      .onTapGesture { UIApplication.shared.dismissKeyboard() }
      .ignoresSafeArea(.keyboard, edges: .all)
      
      HStack{
        ZStack(alignment: .bottom){
          Text("Dark Mode")
            .font(.system(size: 15, weight: .bold))
            .foregroundColor(Color("Tertiary"))
        }
        .padding(.leading, 10)
        ZStack{
          if(!isDarkMode){
            Button(action: { isDarkMode = true }){
              Text("OFF")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color("Tertiary"))
            }
            .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
            .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
          }
          if(isDarkMode){
            Button(action: { isDarkMode = false }){
              Text("ON")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color("Label"))
            }
            .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
            .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")).shadow(color: Color("Tertiary"), radius: 1))
          }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
      }
      .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .center)
      .offset(y: UIScreen.main.bounds.size.height*0.15)
      .ignoresSafeArea(.keyboard, edges: .all)
      
      ZStack{
        // MARK: Skip Personalization Step
        Button(action: { Loading = true }){
          Text("SKIP")
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(Color("Capsule").opacity(0.6))
        }
      }
      .offset(y: UIScreen.main.bounds.size.height*0.275)
      .ignoresSafeArea(.keyboard, edges: .all)
      
      ZStack{
        // MARK: Add Personalization Button
        Button(action: {
          Task{
            let networkStatus: NetworkStatus = CheckNetworkStatus()
            if(networkStatus == NetworkStatus.reachable){
              if let userAccount = user.Account{
                try await AccountManager.updateDisplayName(account: userAccount, displayName: DisplayName)
                try await AccountManager.updateAppleMusicConnected(account: userAccount, appleMusicConnected: AppleMusicConnected)
                if let profile_pic = ProfilePicture { AccountManager.storeProfilePicture(account: userAccount, image: profile_pic) }
              }
              Loading = true
              sleep(1)
            }
            if(networkStatus == NetworkStatus.notConnected){
              UIApplication.shared.dismissKeyboard()
              Offline = true
            }
          }
        })
        {
          ZStack{
            Text("Next")
              .font(.system(size: 16, weight: .bold))
              .foregroundColor(Color("Text"))
          }
          .padding(15)
        }
        if(Loading){
          Spacer().frame(height: 0)
            .onAppear{
              Task{
                Success = try await AccountManager.login(user: user)
                Loading = false
              }
            }
        }
        
        if(!Loading && Success){
          NavigationLink(value: router.selectedNavView){ EmptyView() }
            .onAppear{
              router.selectedNavView = AccountViews.profile
              Completed = true
            }
            .navigationDestination(isPresented: $Completed){
              if let acct = user.Account{ AccountView().environmentObject(acct) }
            }
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.8, alignment: .center)
      .offset(y: UIScreen.main.bounds.size.height*0.35)
      .ignoresSafeArea(.keyboard, edges: .all)
    }
    
  }
}
