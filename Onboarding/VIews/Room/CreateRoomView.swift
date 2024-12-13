import SwiftUI
import Combine

struct CreateRoomView: View {
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
              .font(.system(size: 20, weight: .medium))
              .foregroundColor(Color("Tertiary"))
              .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .leading)
          }
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .topLeading)
      .offset(y: -UIScreen.main.bounds.size.height/2*0.85)
      
      VStack{
        VStack{
          if(appleMusic.Authorized == .authorized &&
             appleMusic.Subscription == AppleMusicSubscriptionStatus.active &&
             room.MusicService == "AppleMusic"){
            Text("Apple Music Connected")
              .font(.system(size: 18, weight: .medium))
              .foregroundColor(Color("Text"))
          }
          else{
            Text("Press Icon To Connect Apple Music")
              .font(.system(size: 18, weight: .medium))
              .foregroundColor(Color("Text"))
          }
          
          // MARK: Apple Music Icon Button
          Button(action: {
            let networkStatus: NetworkStatus = CheckNetworkStatus()
            if(networkStatus == NetworkStatus.reachable){
              Task{
                if(appleMusic.Authorized == .authorized){
                  appleMusic.Authorized = .notDetermined
                  room.MusicService = ""
                }
                else{
                  try await appleMusic.Authorize()
                  appleMusic.CheckSubscription(completion: { _ in })
                  if(appleMusic.Subscription == AppleMusicSubscriptionStatus.notActive){ Error = .appleMusicSubscription }
                  if(appleMusic.Authorized == .notDetermined){ Error = .connectAppleMusicAccount }
                  if(appleMusic.Authorized == .denied || appleMusic.Authorized == .restricted){ Error = .appleMusicAuthorization }
                  room.MusicService = "AppleMusic"
                }
              }
            }
            if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
          }){
            VStack{
              Image("AppleMusicIcon1")
                .resizable()
                .frame(width: 60, height: 60)
                .padding(10)
              if(room.MusicService == "AppleMusic" &&
                 appleMusic.Authorized == .authorized &&
                 appleMusic.Subscription == AppleMusicSubscriptionStatus.active){
                Image(systemName: "circle.fill")
                  .font(.system(size: 10, weight: .light))
                  .foregroundColor(Color("Tertiary"))
                  .frame(width:10, height: 10)
              }
              else{
                if(appleMusic.Subscription == AppleMusicSubscriptionStatus.notActive){
                  Circle()
                    .fill(Color("System"))
                    .frame(width: 10, height: 10)
                }
                else{
                  Circle()
                    .fill(Color("Primary"))
                    .frame(width: 10, height: 10)
                }
              }
            }
          }
          .disabled(Loading)
        }
        
        // MARK: Playlist Name Input
        VStack{
          VStack(alignment: .leading){
            TextField("Playlist Name", text: $room.Name)
              .font(.system(size: 18))
              .foregroundColor(Color("Text"))
              .frame(width: UIScreen.main.bounds.size.width*0.7, height: 50)
              .padding(.leading, 10)
              .disableAutocorrection(true)
              .onReceive(Just(room.Name)){ roomNameInput in
                if(roomNameInput.count > 20){ room.Name.removeLast() }
              }
              .onSubmit{
                let networkStatus: NetworkStatus = CheckNetworkStatus()
                if(networkStatus == NetworkStatus.reachable){
                  UIApplication.shared.dismissKeyboard()
                  user.Nickname = FormatTextFieldInputKeepWhitespace(Input: user.Nickname)
                  room.Name = FormatTextFieldInputKeepWhitespace(Input: room.Name)
                  Loading = true
                }
                if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
              }
              .disabled(Loading)
            Divider()
              .frame(width: UIScreen.main.bounds.size.width*0.7, height: 1)
              .background(Color("Tertiary"))
              .padding(.leading, 10)
              .offset(y: -15)
          }
          .padding(10)
          
          // MARK: [Host] user Nickname Input
          VStack(alignment: .leading){
            TextField("Display Name", text: $user.Nickname)
              .font(.system(size: 18))
              .foregroundColor(Color("Text"))
              .frame(width: UIScreen.main.bounds.size.width*0.7, height: 50)
              .padding(.leading, 10)
              .disableAutocorrection(true)
              .onReceive(Just(user.Nickname)){ userNicknameInput in
                if(userNicknameInput.count > 20){ user.Nickname.removeLast() }
              }
              .onSubmit{
                let networkStatus: NetworkStatus = CheckNetworkStatus()
                if(networkStatus == NetworkStatus.reachable){
                  UIApplication.shared.dismissKeyboard()
                  user.Nickname = FormatTextFieldInputKeepWhitespace(Input: user.Nickname)
                  room.Name = FormatTextFieldInputKeepWhitespace(Input: room.Name)
                  Loading = true
                }
                if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
              }
              .disabled(Loading)
            Divider()
              .frame(width: UIScreen.main.bounds.size.width*0.7, height: 1)
              .background(Color("Tertiary"))
              .padding(.leading, 10)
              .offset(y: -15)
          }
        }
        .padding(10)
        
        // MARK: Create Playlist Button
        ZStack{
          if(!Loading && !Success){
            Button("Create", action: {
              Task{
                let networkStatus: NetworkStatus = CheckNetworkStatus()
                if(networkStatus == NetworkStatus.reachable){
                  user.Nickname = FormatTextFieldInputKeepWhitespace(Input: user.Nickname)
                  room.Name = FormatTextFieldInputKeepWhitespace(Input: room.Name)
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
          
          // MARK: Create Playlist Loader
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
        .offset(y: UIScreen.main.bounds.size.height*0.28)
        .opacity(0.3)
      }
      
      // MARK: Onboarding Errors
      RoomOnboardingErrorView(Error: $Error)
        .padding(10)
      
    }
    .onAppear{
      room.Creator = user
      room.Host = user
      if(user.Account != nil){
        if let AppleMusicConnected: Bool = user.Account?.AppleMusicConnected{
          if(AppleMusicConnected){
            if(appleMusic.Authorized == .notDetermined){ Task{ try await appleMusic.Authorize() } }
            appleMusic.CheckSubscription(completion: { _ in })
            room.MusicService = "AppleMusic"
          }
        }
        if let accountNickname = user.Account?.DisplayName { user.Nickname = accountNickname }
      }
    }
    .ignoresSafeArea(.keyboard, edges: .all)
    .navigationBarHidden(true)
  }
}
