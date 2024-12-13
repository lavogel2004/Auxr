import SwiftUI
import FirebaseAuth

struct rootView: View {
  @AppStorage("isDarkMode") private var isDarkMode = false
  
  @EnvironmentObject var router: Router
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  @State private var LoggedIn: Bool = false
  @State private var Loading: Bool = true
  @State private var ShowAuxrAboutOverlay: Bool = false
  @State private var SignUpStep: SignUpSteps = SignUpSteps.required
  @State private var TermsOfService: Bool = false
  @State private var PrivacyPolicy: Bool = false
  
  var body: some View {
    ZStack{
      if(ShowAuxrAboutOverlay){ AuxrAboutOverlay(Show: $ShowAuxrAboutOverlay) }
      NavigationStack(path: $router.routes){
        VStack{
          if(!Loading && !LoggedIn){
            Button(action:{ ShowAuxrAboutOverlay = true }){
              ZStack{
                Image(systemName: "questionmark.circle.fill")
                  .frame(width: 25, height: 25)
                  .font(.system(size: 25, weight: .semibold))
                  .foregroundColor(Color("Tertiary"))
              }
              .frame(width: 25, alignment: .trailing)
              .padding(2)
            }
            .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .topLeading)
            .padding(.top, 15)
            .offset(y: -UIScreen.main.bounds.size.height*0.08)
            
            Image("LogoText")
              .resizable()
              .frame(width: UIScreen.main.bounds.size.width*0.75, height: UIScreen.main.bounds.size.width*0.75)
            
            // MARK: Create Playlist Navigation Button
            NavigationLink(value: router.login){
              Button(action: {
                router.routes.append(router.login)
                router.currPath = router.login.path
              }){
                Text("Login")
                  .font(.system(size: 20, weight: .medium))
                  .foregroundColor(Color("Label"))
                  .frame(width: UIScreen.main.bounds.size.width*0.5, height: 45)
                  .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")).shadow(color: Color("Shadow"), radius: 1))
                  .padding(10)
              }
            }
            
            // MARK: Join Playlist Navigation Button
            NavigationLink(value: router.signUp){
              Button(action: {
                router.routes.append(router.signUp)
                router.currPath = router.signUp.path
              }){
                Text("Sign Up")
                  .font(.system(size: 20, weight: .medium))
                  .foregroundColor(Color("Label"))
                  .frame(width: UIScreen.main.bounds.size.width*0.5, height: 45)
                  .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")).shadow(color: Color("Shadow"), radius: 1))
                  .padding(10)
              }
            }
            
            // MARK: Join Playlist Navigation Button
            NavigationLink(value: router.noAccount){
              Button(action: {
                router.routes.append(router.noAccount)
                router.currPath = router.noAccount.path
              }){
                Text("Use With No Account")
                  .font(.system(size: 13, weight: .medium))
                  .foregroundColor(Color("Text"))
                  .frame(width: UIScreen.main.bounds.size.width*0.5)
                  .padding(3)
              }
            }
          }
          if(!Loading && !LoggedIn){
            VStack(spacing: 5){
              HStack(spacing: 3){
                Button(action: { TermsOfService = true }){
                  ZStack{
                    Text("Terms of Use")
                      .font(.system(size: 13, weight: .regular))
                      .foregroundColor(Color("Text"))
                      .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .trailing)
                      .padding(3)
                  }
                }
                Text(" | ")
                  .font(.system(size: 13, weight: .regular))
                  .foregroundColor(Color("Text"))
                Button(action: { PrivacyPolicy = true }){
                  ZStack{
                    Text("Privacy Policy")
                      .font(.system(size: 13, weight: .regular))
                      .foregroundColor(Color("Text"))
                      .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
                      .padding(3)
                  }
                }
              }
              Text("AUXR v2.0.0")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color("Capsule").opacity(0.6))
                .frame(width: UIScreen.main.bounds.size.width*0.5)
                .padding(3)
            }
            .offset(y: UIScreen.main.bounds.size.height*0.03)
          }
          
          
          // MARK: Log In
          NavigationLink(value: router.account){ EmptyView() }
            .onAppear{
              Task{
                LoggedIn = try await AccountManager.login(user: user)
                if(LoggedIn){
                  self.router.routes.append(self.router.account)
                  self.router.currPath = self.router.account.path
                }
                Loading = false
              }
            }
        }
        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, alignment: .center)
        .background(Color("Primary"))
        .navigationDestination(for: Route.self){ route in
          switch(route.path){
          case router.login.path: LoginView()
          case router.signUp.path: SignUpView(StepView: $SignUpStep)
          case router.noAccount.path: NoAccountView()
          case router.account.path:
            if let account: AuxrAccount = user.Account{
              AccountView().environmentObject(account)
            }
          default: EmptyView()
          }
        }
      }
    }
    .navigationBarHidden(true)
    .colorScheme(isDarkMode ? .dark : .light)
    .popover(isPresented: $TermsOfService){ TermsOfServiceView() }
    .popover(isPresented: $PrivacyPolicy){ PrivacyPolicyView() }
  }
}
