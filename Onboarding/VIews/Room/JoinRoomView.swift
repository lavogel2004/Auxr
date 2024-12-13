import SwiftUI
import Combine

struct JoinRoomView: View {
  @Environment(\.presentationMode) var Presentation
  @EnvironmentObject var router: Router
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  @State private var Loading: Bool = false
  @State private var Success: Bool = false
  @State private var Completed: Bool = false
  @State private var Error: RoomOnboardingError = RoomOnboardingError.none
  @State private var ShowOfflineOverlay: Bool = false
  
  var body: some View {
    ZStack{
      Color("Primary").edgesIgnoringSafeArea(.all)
      
      if(ShowOfflineOverlay){ OfflineOverlay(networkStatus: NetworkStatus.notConnected, Show: $ShowOfflineOverlay) }
      
      ZStack{
        if(!Loading){
          Button(action: {
            Presentation.wrappedValue.dismiss()
            Task{ try await SystemReset(User: user, Room: room, AppleMusic: appleMusic) }
          }){
            Image(systemName: "chevron.left")
              .font(.system(size: 18, weight: .medium))
              .foregroundColor(Color("Tertiary"))
              .frame(width: UIScreen.main.bounds.size.width*0.2, height: 20, alignment: .leading)
          }
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .topLeading)
      .offset(y: -UIScreen.main.bounds.size.height/2*0.85)
      
      // MARK: [Guest] User Nickname Input
      VStack{
        // MARK: Playlist Password Input
        VStack(alignment: .leading){
          TextField("Playlist Passcode", text: $room.Passcode)
            .font(.system(size: 18))
            .foregroundColor(Color("Text"))
            .frame(width: UIScreen.main.bounds.size.width*0.7, height: 50)
            .padding(.leading, 10)
            .disableAutocorrection(true)
            .onReceive(Just(room.Passcode)){ RoomPasscodeInput in
              if(RoomPasscodeInput.count > 4){ room.Passcode.removeLast() }
            }
            .onSubmit{
              let networkStatus: NetworkStatus = CheckNetworkStatus()
              if(networkStatus == NetworkStatus.reachable){
                UIApplication.shared.dismissKeyboard()
                user.Nickname = FormatTextFieldInputKeepWhitespace(Input: user.Nickname)
                room.Passcode = FormatTextFieldInput(Input: room.Passcode).uppercased()
                Loading = true
              }
              if(networkStatus == NetworkStatus.notConnected){
                UIApplication.shared.dismissKeyboard()
                ShowOfflineOverlay = true
              }
            }
            .disabled(Loading)
          Divider()
            .frame(width: UIScreen.main.bounds.size.width*0.7, height: 1)
            .background(Color("Tertiary"))
            .padding(.leading, 10)
            .offset(y: -15)
        }
        .padding(10)

        VStack(alignment: .leading){
          TextField("Display Name", text: $user.Nickname)
            .font(.system(size: 18))
            .foregroundColor(Color("Text"))
            .frame(width: UIScreen.main.bounds.size.width*0.7, height: 50)
            .padding(.leading, 10)
            .disableAutocorrection(true)
            .onReceive(Just(user.Nickname)){ UserNicknameInput in
              if(UserNicknameInput.count > 20){ user.Nickname.removeLast() }
            }
            .onSubmit{
              let networkStatus: NetworkStatus = CheckNetworkStatus()
              if(networkStatus == NetworkStatus.reachable){
                UIApplication.shared.dismissKeyboard()
                user.Nickname = FormatTextFieldInputKeepWhitespace(Input: user.Nickname)
                room.Passcode = FormatTextFieldInput(Input: room.Passcode).uppercased()
                Loading = true
              }
              if(networkStatus == NetworkStatus.notConnected){
                UIApplication.shared.dismissKeyboard()
                ShowOfflineOverlay = true
              }
            }
            .disabled(Loading)
          Divider()
            .frame(width: UIScreen.main.bounds.size.width*0.7, height: 1)
            .background(Color("Tertiary"))
            .padding(.leading, 10)
            .offset(y: -15)
        }
        .padding(10)
        
        // MARK: Join Playlist Button
        ZStack{
          if(!Loading && !Success){
            Button("Join", action: {
              Task{
                let networkStatus: NetworkStatus = CheckNetworkStatus()
                if(networkStatus == NetworkStatus.reachable){
                  UIApplication.shared.dismissKeyboard()
                  user.Nickname = FormatTextFieldInputKeepWhitespace(Input: user.Nickname)
                  room.Passcode = FormatTextFieldInput(Input: room.Passcode).uppercased()
                  Task{ if(!appleMusic.CheckedForSubscription){ appleMusic.CheckSubscription(completion: { _ in }) } }
                  Loading = true
                }
                if(networkStatus == NetworkStatus.notConnected){
                  UIApplication.shared.dismissKeyboard()
                  ShowOfflineOverlay = true
                }
              }
            })
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(Color("Tertiary"))
            .frame(width: UIScreen.main.bounds.size.width*0.5, height: 45)
            .padding(10)
          }
          
          // MARK: Join Playlist Loader
          if(Loading){ RoomOnboardingLoaderView(Loading: $Loading, Success: $Success, Error: $Error) }
          
          if(!Loading && Success){
            NavigationLink(value: router.room){ EmptyView() }
              .onAppear{
                router.currPath = router.room.path
                Completed = true
              }
              .navigationDestination(isPresented: $Completed){ RoomView() }
          }
          
        }
      }
      .frame(maxHeight: UIScreen.main.bounds.size.height*0.75, alignment: .top)
      
      if(Error == RoomOnboardingError.none){
        ZStack{
          Image("LogoNoText")
            .resizable()
            .frame(width: UIScreen.main.bounds.size.width*0.5, height: UIScreen.main.bounds.size.width*0.5)
        }
        .offset(y: UIScreen.main.bounds.size.height*0.1)
        .opacity(0.3)
      }
      
      // MARK: Onboarding Errors
      RoomOnboardingErrorView(Error: $Error)
        .padding(10)
        .offset(y: -UIScreen.main.bounds.size.height*0.2)
      
    }
    .ignoresSafeArea(.keyboard, edges: .all)
    .navigationBarHidden(true)
    .onAppear{
      if(user.Account != nil){
        if let AppleMusicConnected: Bool = user.Account?.AppleMusicConnected {
          if(AppleMusicConnected){
            if(appleMusic.Authorized == .notDetermined){ Task{ try await appleMusic.Authorize() } }
            appleMusic.CheckSubscription(completion: { _ in })
          }
        }
        if let accountNickname = user.Account?.DisplayName { user.Nickname = accountNickname }
      }
    }
  }
}
