import SwiftUI

struct LoginView: View {
  @Environment(\.presentationMode) var Presentation
  @EnvironmentObject var router: Router
  @EnvironmentObject var user: User
  
  @State private var Loading: Bool = false
  @State private var Success: Bool = false
  @State private var Completed: Bool = false
  @State private var Error: AuxrAccountOnboardingError = AuxrAccountOnboardingError.none
  
  @State private var ShowOfflineOverlay: Bool = false
  @State private var Username: String = ""
  @State private var Password: String = ""
  
  var body: some View {
    ZStack{
      Color("Primary").edgesIgnoringSafeArea(.all)
      
      if(ShowOfflineOverlay){ OfflineOverlay(networkStatus: NetworkStatus.notConnected, Show: $ShowOfflineOverlay) }
      
      ZStack{
        Button(action: { Presentation.wrappedValue.dismiss() }){
          Image(systemName: "chevron.left")
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(Color("Tertiary"))
            .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .leading)
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .topLeading)
      .offset(y: -UIScreen.main.bounds.size.height/2*0.85)

      VStack{
        VStack(alignment: .leading){
          TextField("Username", text: $Username)
            .font(.system(size: 16))
            .foregroundColor(Color("Text"))
            .frame(width: UIScreen.main.bounds.size.width*0.7, height: 35)
            .padding(.leading, 10)
            .disableAutocorrection(true)
            .onSubmit{
              let networkStatus: NetworkStatus = CheckNetworkStatus()
              if(networkStatus == NetworkStatus.reachable){
                UIApplication.shared.dismissKeyboard()
                Loading = true
              }
              if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
            }
            .disabled(Loading)
          VStack(alignment: .leading, spacing: 5){
            Divider()
              .frame(width: UIScreen.main.bounds.size.width*0.7, height: 1)
              .background(Color((Error != AuxrAccountOnboardingError.loginUsername) ? "Tertiary" : "Red"))
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
            .textContentType(.password)
            .disableAutocorrection(true)
            .onSubmit{
              let networkStatus: NetworkStatus = CheckNetworkStatus()
              if(networkStatus == NetworkStatus.reachable){
                UIApplication.shared.dismissKeyboard()
                Loading = true
              }
              if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
            }
            .disabled(Loading)
          
          VStack(alignment: .leading, spacing: 5){
            Divider()
              .frame(width: UIScreen.main.bounds.size.width*0.7, height: 1)
              .background(Color((Error != AuxrAccountOnboardingError.loginPassword) ? "Tertiary" : "Red"))
              .offset(y: -15)
            Text("Password")
              .font(.system(size: 11, weight: .bold))
              .foregroundColor(Color("Text"))
              .offset(x: 2, y: -15)
          }
          .padding(.leading, 10)
        }
        ZStack{
          if(!Loading && !Success){
            Button("Login", action: {
              let networkStatus: NetworkStatus = CheckNetworkStatus()
              if(networkStatus == NetworkStatus.reachable){
                UIApplication.shared.dismissKeyboard()
                Loading = true
              }
              if(networkStatus == NetworkStatus.notConnected){
                UIApplication.shared.dismissKeyboard()
                ShowOfflineOverlay = true
              }
            })
            .font(.system(size: 18, weight: .bold))
            .foregroundColor(Color("Tertiary"))
            .frame(width: UIScreen.main.bounds.size.width*0.5, height: 45)
            .padding(10)
          }
          
          // MARK: Login Loader
          if(Loading){ LoginLoaderView(Username: $Username, Password: $Password, Loading: $Loading, Success: $Success, Error: $Error) }
          
          if(!Loading && Success){
            NavigationLink(value: router.account){ EmptyView() }
              .onAppear{
                router.currPath = router.account.path
                Completed = true
              }
              .navigationDestination(isPresented: $Completed){ if let acct: AuxrAccount = user.Account{ AccountView().environmentObject(acct) } }
          }
        }
      }
      .frame(maxHeight: UIScreen.main.bounds.size.height*0.75, alignment: .top)
      
      if(Error == AuxrAccountOnboardingError.none){
        ZStack{
          Image("LogoNoText")
            .resizable()
            .frame(width: UIScreen.main.bounds.size.width*0.5, height: UIScreen.main.bounds.size.width*0.5)
        }
        .offset(y: UIScreen.main.bounds.size.height*0.1)
        .opacity(0.3)
      }
      
      // MARK: Login Errors
      AuxrAccountOnboardingErrorView(Error: $Error)
        .padding(10)
        .offset(y: UIScreen.main.bounds.size.height*0.05)
    }
    .frame(maxHeight: UIScreen.main.bounds.size.height, alignment: .top)
    .ignoresSafeArea(.keyboard, edges: .all)
    .navigationBarHidden(true)
  }
}
