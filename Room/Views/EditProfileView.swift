import SwiftUI
import Combine

struct EditProfileView: View {
  @AppStorage("isDarkMode") private var isDarkMode = false
  
  @Environment(\.presentationMode) var Presentation
  @EnvironmentObject var router: Router
  @EnvironmentObject var user: User
  @EnvironmentObject var account: AuxrAccount
  @EnvironmentObject var appleMusic: AppleMusic
  
  @Binding var ProfilePicture: UIImage?
  @State private var SetProfilePicture: Bool = false
  @State private var SelectProfilePicture: Bool = false
  @State private var DisplayName: String = ""
  @State private var Loading: Bool = false
  @State private var Success: Bool = false
  @State private var Completed: Bool = false
  @State private var Offline: Bool = false
  
  var body: some View {
    ZStack{
      Color("Primary").edgesIgnoringSafeArea(.all)
      HStack{
        Button(action: {
          Task{
            let networkStatus: NetworkStatus = CheckNetworkStatus()
            if(networkStatus == NetworkStatus.reachable){
              try await AccountManager.updateDisplayName(account: account, displayName: DisplayName)
              try await AccountManager.updateAppleMusicConnected(account: account, appleMusicConnected: account.AppleMusicConnected)
              if let profilePic = ProfilePicture {
                AccountManager.storeProfilePicture(account: account, image: profilePic)
              }
              sleep(1)
              Loading = true
              Success = true
            }
            if(networkStatus == NetworkStatus.notConnected){
              UIApplication.shared.dismissKeyboard()
              Offline = true
            }
            Presentation.wrappedValue.dismiss()
          }
        }){
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
      .disabled(SelectProfilePicture)
      ZStack{
        HStack(spacing: 4){
          Image(systemName: "person.crop.circle")
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Color("Text"))
          Text("Edit Profile")
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Color("Text"))
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .trailing)
      .offset(y: -UIScreen.main.bounds.size.height/2*0.8)
      .zIndex(2)
      if(user.Account != nil){
        HStack(alignment: .bottom, spacing: UIScreen.main.bounds.size.width*0.08){
          
          // MARK: Set User Account Profile Picture
          VStack(spacing: 10){
            VStack(spacing: 10){
              Button(action: {
                SelectProfilePicture = true
                SetProfilePicture = true
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
            Button(action: {
              ProfilePicture = nil
              Task{ try await AccountManager.deleteProfilePicture(account_id: account.ID) }
            }){
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
                if(account.AppleMusicConnected){
                  account.AppleMusicConnected = false
                  appleMusic.Authorized = .notDetermined
                }
                else{
                  if(appleMusic.Authorized == .notDetermined){ try await appleMusic.Authorize() }
                  if(appleMusic.Subscription == .active){ account.AppleMusicConnected = true }
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
              else if(appleMusic.Subscription == AppleMusicSubscriptionStatus.active && account.AppleMusicConnected){
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
          .offset(y: 0.5)
        }
        .frame(maxHeight: UIScreen.main.bounds.size.height*0.22, alignment: .top)
        .offset(y: -UIScreen.main.bounds.size.height*0.3)
        .zIndex(2)
        
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
              .frame(width: UIScreen.main.bounds.size.width*0.65, height: 1)
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
        .sheet(isPresented: $SelectProfilePicture ){
          ImagePicker(image: $ProfilePicture)
            .onDisappear{
              Task{
                if let profile_pic = ProfilePicture { AccountManager.storeProfilePicture(account: account, image: profile_pic) }
              }
            }
        }
        .onAppear{ appleMusic.CheckSubscription(completion: { _ in }) }
        .onTapGesture { UIApplication.shared.dismissKeyboard() }
        .ignoresSafeArea(.keyboard, edges: .all)
        .offset(y: -UIScreen.main.bounds.size.height*0.11)
        .zIndex(2)
        .onDisappear{
          if(!account.AppleMusicConnected){
            appleMusic.Subscription = .notChecked
            appleMusic.CheckedForSubscription = false
          }
        }
        
        VStack{
          HStack{
            ZStack(alignment: .bottom){
              VStack(spacing: 3){
                Text("Private Mode")
                  .font(.system(size: 15, weight: .bold))
                  .foregroundColor(Color("Text"))
                  .frame(width: UIScreen.main.bounds.size.width*0.65, height: 15, alignment: .leading)
                Text("Only friends can see your profile")
                  .font(.system(size: 12, weight: .bold))
                  .foregroundColor(Color("Tertiary"))
                  .frame(width: UIScreen.main.bounds.size.width*0.65, height: 10, alignment: .leading)
              }
            }
            .padding(.leading, 10)
            ZStack{
              if(!account.PrivateMode){
                Button(action: {
                  Task{
                    account.PrivateMode = true
                    try await AccountManager.updatePrivateMode(account: account)
                  }
                }){
                  Text("OFF")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("Tertiary"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
              }
              if(account.PrivateMode){
                Button(action: {
                  Task{
                    account.PrivateMode = false
                    try await AccountManager.updatePrivateMode(account: account)
                  }
                }){
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
          .frame(width: UIScreen.main.bounds.size.width*0.83, height: 50, alignment: .leading)
          .ignoresSafeArea(.keyboard, edges: .all)
          
          HStack{
            ZStack(alignment: .bottom){
              VStack(spacing: 3){
                Text("Hide Likes")
                  .font(.system(size: 15, weight: .bold))
                  .foregroundColor(Color("Text"))
                  .frame(width: UIScreen.main.bounds.size.width*0.65, height: 15, alignment: .leading)
                Text("Song likes are hidden from everyone")
                  .font(.system(size: 12, weight: .bold))
                  .foregroundColor(Color("Tertiary"))
                  .frame(width: UIScreen.main.bounds.size.width*0.65, height: 10, alignment: .leading)
              }
            }
            .padding(.leading, 10)
            ZStack{
              if(!account.HideLikes){
                Button(action: {
                  Task{
                    account.HideLikes = true
                    try await AccountManager.updateHideLikes(account: account)
                  }
                }){
                  Text("OFF")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("Tertiary"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
              }
              if(account.HideLikes){
                Button(action: {
                  Task{
                    account.HideLikes = false
                    try await AccountManager.updateHideLikes(account: account)
                  }
                }){
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
          .frame(width: UIScreen.main.bounds.size.width*0.83, height: 50, alignment: .leading)
          .ignoresSafeArea(.keyboard, edges: .all)
          
          HStack{
            ZStack(alignment: .bottom){
              VStack(spacing: 3){
                Text("Hide Sessions")
                  .font(.system(size: 15, weight: .bold))
                  .foregroundColor(Color("Text"))
                  .frame(width: UIScreen.main.bounds.size.width*0.65, height: 15, alignment: .leading)
                Text("Sessions are hidden from everyone")
                  .font(.system(size: 12, weight: .bold))
                  .foregroundColor(Color("Tertiary"))
                  .frame(width: UIScreen.main.bounds.size.width*0.65, height: 10, alignment: .leading)
              }
            }
            .padding(.leading, 10)
            ZStack{
              if(!account.HideChannels){
                Button(action: {
                  Task{
                    account.HideChannels = true
                    try await AccountManager.updateHideChannels(account: account)
                  }
                }){
                  Text("OFF")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("Tertiary"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
              }
              if(account.HideChannels){
                Button(action: {
                  Task{
                    account.HideChannels = false
                    try await AccountManager.updateHideChannels(account: account)
                  }
                }){
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
          .frame(width: UIScreen.main.bounds.size.width*0.83, height: 50, alignment: .leading)
          .ignoresSafeArea(.keyboard, edges: .all)
          
        }
        .offset(y: UIScreen.main.bounds.size.height*0.07)
        
      }
    }
    .ignoresSafeArea(.keyboard, edges: .all)
    .frame(maxHeight: UIScreen.main.bounds.size.height)
    .zIndex(0)
    .navigationBarHidden(true)
    .onAppear{
      Task{ ProfilePicture = try await AccountManager.getProfilePicture(account_id: account.ID) }
      if(account.AppleMusicConnected){
        if(appleMusic.Subscription != .active){
          appleMusic.CheckSubscription(completion: { _ in })
        }
      }
      DisplayName = account.DisplayName
    }
  }
}
