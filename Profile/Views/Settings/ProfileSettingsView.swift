import SwiftUI

struct ProfileSettingsView: View {
  @AppStorage("isDarkMode") private var isDarkMode = false
  
  @Environment(\.presentationMode) var Presentation
  @Environment(\.scenePhase) var scenePhase
  @EnvironmentObject var router: Router
  @EnvironmentObject var appleMusic: AppleMusic
  @EnvironmentObject var user: User
  @EnvironmentObject var account: AuxrAccount
  @EnvironmentObject var room: Room
  
  @State private var ShowMyInfoDropDown: Bool = true
  @State private var ShowAccountInfoDropDown: Bool = true
  @State private var ShowAppearanceDropDown: Bool = true
  @State private var ShowStatsDropDown: Bool = true
  @State private var ShowYourAuxDropDown: Bool = true
  
  @State private var Logout: Bool = false
  @State private var LogoutResponse: Bool = false
  
  var body: some View {
    ZStack{
      Color("Primary").edgesIgnoringSafeArea(.all)
      if(Logout){ AccountOverlay(type: AccountOverlayType.logout, Show: $Logout, Response: $LogoutResponse) }
      ZStack{
        Button(action: { Presentation.wrappedValue.dismiss() }){
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
      VStack(spacing: 10){
        ScrollView(showsIndicators: false){
          VStack{
            VStack{
              HStack{
                Button( action: { withAnimation(.easeInOut(duration: 0.4)){ ShowMyInfoDropDown.toggle() }}){
                  HStack(spacing: 7){
                    Image(systemName: "person.fill")
                      .font(.system(size: 20, weight: .bold))
                      .foregroundColor(Color("Text"))
                      .frame(width: 30)
                      .padding(.leading, 10)
                    Text("My Info")
                      .font(.system(size: 20, weight: .bold))
                      .foregroundColor(Color("Text"))
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .leading)
                  if(ShowMyInfoDropDown){
                    Image(systemName: "chevron.down").foregroundColor(Color("Tertiary"))
                      .frame(width:UIScreen.main.bounds.size.width*0.2, alignment: .trailing)
                      .font(.system(size: 15, weight: .bold))
                  }
                  else{
                    Image(systemName: "chevron.right").foregroundColor(Color("Text"))
                      .frame(width:UIScreen.main.bounds.size.width*0.2, alignment: .trailing)
                      .font(.system(size: 15, weight: .medium))
                  }
                }
              }
              .frame(width: UIScreen.main.bounds.size.width*0.93, height: 30, alignment: .leading)
              
              if(ShowMyInfoDropDown){
                VStack{
                  Text("Username")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                    .padding(.leading, 10)
                  Text(account.Username)
                    .lineLimit(1)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("Text"))
                    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                    .padding(.leading, 10)
                }
                .padding(.leading, 10)
                .padding(.bottom, 5)
                VStack{
                  Text("Display Name")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                    .padding(.leading, 10)
                  Text(account.DisplayName)
                    .lineLimit(1)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("Text"))
                    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                    .padding(.leading, 10)
                }
                .padding(.leading, 10)
                .padding(.bottom, 5)
                ZStack{
                  VStack{
                    Text("Apple Music")
                      .font(.system(size: 15, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                      .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                      .padding(.leading, 10)
                    if(account.AppleMusicConnected){
                      HStack{
                        ZStack{
                          Text("Active Subscription")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color("Text"))
                        }
                        .frame(alignment: .leading)
                        ZStack{
                          Text("CONNECTED")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color("Tertiary"))
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing, 5)
                      }
                      .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                      .padding(.leading, 10)
                    }
                    if(!account.AppleMusicConnected){
                      HStack{
                        ZStack{
                          Text("Not Connected")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color("Text"))
                        }
                        .frame(alignment: .leading)
                      }
                      .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                      .padding(.leading, 10)
                    }
                  }
                  .padding(.leading, 10)
                }
              }
              Divider()
                .frame(width: UIScreen.main.bounds.size.width*0.9, height: 1.5)
                .background(Color("LightGray").opacity(0.6))
            }
            VStack{
              HStack{
                Button(action: { withAnimation(.easeInOut(duration: 0.4)){ ShowStatsDropDown.toggle() }}){
                  HStack(spacing: 7){
                    Image(systemName: "hifispeaker.fill")
                      .font(.system(size: 20, weight: .bold))
                      .foregroundColor(Color("Text"))
                      .frame(width: 30)
                      .padding(.leading, 10)
                    Text("My Aux")
                      .font(.system(size: 20, weight: .bold))
                      .foregroundColor(Color("Text"))
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .leading)
                  if(ShowStatsDropDown){
                    Image(systemName: "chevron.down").foregroundColor(Color("Tertiary"))
                      .frame(width:UIScreen.main.bounds.size.width*0.2, alignment: .trailing)
                      .font(.system(size: 15, weight: .bold))
                  }
                  else{
                    Image(systemName: "chevron.right").foregroundColor(Color("Text"))
                      .frame(width:UIScreen.main.bounds.size.width*0.2, alignment: .trailing)
                      .font(.system(size: 15, weight: .medium))
                  }
                }
              }
              .frame(width: UIScreen.main.bounds.size.width*0.93, height: 30, alignment: .leading)
              if(ShowStatsDropDown){
                HStack{
                  VStack{
                    Text("Points")
                      .font(.system(size: 15, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                      .frame(width: UIScreen.main.bounds.size.width*0.45, alignment: .leading)
                      .padding(.leading, 10)
                    Text(String(account.Points))
                      .lineLimit(1)
                      .font(.system(size: 15, weight: .medium))
                      .foregroundColor(Color("Text"))
                      .frame(width: UIScreen.main.bounds.size.width*0.45, alignment: .leading)
                      .padding(.leading, 10)
                  }
                  .padding(.bottom, 5)
                  VStack{
                    Text("Songs Queued")
                      .font(.system(size: 15, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                      .frame(width: UIScreen.main.bounds.size.width*0.45, alignment: .leading)
                      .padding(.leading, 10)
                    Text(String(account.SongsQueued))
                      .lineLimit(1)
                      .font(.system(size: 15, weight: .medium))
                      .foregroundColor(Color("Text"))
                      .frame(width: UIScreen.main.bounds.size.width*0.45, alignment: .leading)
                      .padding(.leading, 10)
                  }
                  .padding(.bottom, 5)
                }
                .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                HStack{
                  VStack{
                    Text("Sessions Created")
                      .font(.system(size: 15, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                      .frame(width: UIScreen.main.bounds.size.width*0.45, alignment: .leading)
                      .padding(.leading, 10)
                    Text(String(account.ChannelsCreated))
                      .lineLimit(1)
                      .font(.system(size: 15, weight: .medium))
                      .foregroundColor(Color("Text"))
                      .frame(width: UIScreen.main.bounds.size.width*0.45, alignment: .leading)
                      .padding(.leading, 10)
                  }
                  .padding(.bottom, 5)
                  VStack{
                    Text("Sessions joined")
                      .font(.system(size: 15, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                      .frame(width: UIScreen.main.bounds.size.width*0.45, alignment: .leading)
                      .padding(.leading, 10)
                    Text(String(account.ChannelsJoined))
                      .lineLimit(1)
                      .font(.system(size: 15, weight: .medium))
                      .foregroundColor(Color("Text"))
                      .frame(width: UIScreen.main.bounds.size.width*0.45, alignment: .leading)
                      .padding(.leading, 10)
                  }
                  .padding(.bottom, 5)
                }
                .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
              }
              Divider()
                .frame(width: UIScreen.main.bounds.size.width*0.9, height: 1.5)
                .background(Color("LightGray").opacity(0.6))
            }
            VStack{
              HStack{
                Button( action: { withAnimation(.easeInOut(duration: 0.4)){ ShowAppearanceDropDown.toggle() }}){
                  HStack(spacing: 7){
                    Image(systemName: "eye.fill")
                      .font(.system(size: 20, weight: .bold))
                      .foregroundColor(Color("Text"))
                      .frame(width: 30)
                      .padding(.leading, 10)
                    Text("Appearance")
                      .font(.system(size: 20, weight: .bold))
                      .foregroundColor(Color("Text"))
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .leading)
                  if(ShowAppearanceDropDown){
                    Image(systemName: "chevron.down").foregroundColor(Color("Tertiary"))
                      .frame(width:UIScreen.main.bounds.size.width*0.2, alignment: .trailing)
                      .font(.system(size: 15, weight: .bold))
                  }
                  else{
                    Image(systemName: "chevron.right").foregroundColor(Color("Text"))
                      .frame(width:UIScreen.main.bounds.size.width*0.2, alignment: .trailing)
                      .font(.system(size: 15, weight: .medium))
                  }
                }
              }
              .frame(width: UIScreen.main.bounds.size.width*0.93, height: 30, alignment: .leading)
              if(ShowAppearanceDropDown){
                HStack(){
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
                .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                .padding(.bottom, 5)
                .padding(.top, 5)
              }
              Divider()
                .frame(width: UIScreen.main.bounds.size.width*0.9, height: 1.5)
                .background(Color("LightGray").opacity(0.6))
            }
            VStack(spacing: 10){
              HStack{
                Button( action: { withAnimation(.easeInOut(duration: 0.4)){ ShowAccountInfoDropDown.toggle() }}){
                  HStack(spacing: 7){
                    Image(systemName: "gearshape.fill")
                      .font(.system(size: 25, weight: .bold))
                      .foregroundColor(Color("Text"))
                      .frame(width: 30)
                      .padding(.leading, 10)
                    Text("Account Settings")
                      .font(.system(size: 20, weight: .bold))
                      .foregroundColor(Color("Text"))
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .leading)
                  if(ShowAccountInfoDropDown){
                    Image(systemName: "chevron.down").foregroundColor(Color("Tertiary"))
                      .frame(width:UIScreen.main.bounds.size.width*0.2, alignment: .trailing)
                      .font(.system(size: 15, weight: .bold))
                  }
                  else{
                    Image(systemName: "chevron.right").foregroundColor(Color("Text"))
                      .frame(width:UIScreen.main.bounds.size.width*0.2, alignment: .trailing)
                      .font(.system(size: 15, weight: .medium))
                  }
                }
              }
              .frame(width: UIScreen.main.bounds.size.width*0.93, height: 30, alignment: .leading)
              if(ShowAccountInfoDropDown){
                NavigationLink(destination: PasswordPrompt(destinationView: AnyView(ResetPasswordView()))){
                  ZStack{
                    Text("Reset Password")
                      .font(.system(size: 15, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                      .padding(.leading, 10)
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                }
                if(LogoutResponse){
                  Spacer().frame(height: 0).onAppear{
                    Task{
                      AccountManager.logout(user: user)
                      do
                      {
                        try await SystemReset(User: user, Room: room, AppleMusic: appleMusic)
                      }
                      catch _{}
                      router.popToRoot()
                    }
                  }
                }
                Button(action: { Logout = true }){
                  ZStack{
                    Text("Logout")
                      .font(.system(size: 15, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                      .padding(.leading, 10)
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                }
                NavigationLink(destination: PasswordPrompt(destinationView: AnyView(DeleteAccountView()))){
                  ZStack{
                    Text("Delete Account")
                      .font(.system(size: 15, weight: .bold))
                      .foregroundColor(Color("Red"))
                      .padding(.leading, 10)
                  }
                }
                .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
              }
            }
          }
        }
      }
      .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, alignment: .center)
      .offset(y: UIScreen.main.bounds.size.height*0.11)
    }
    .colorScheme(isDarkMode ? .dark : .light)
    .navigationBarHidden(true)
    .gesture(DragGesture(minimumDistance: 25, coordinateSpace: .global)
      .onEnded{ position in
        let HorizontalDrag = position.translation.width
        let VerticalDrag = position.translation.height
        if(abs(HorizontalDrag) > abs(VerticalDrag)){
          if(HorizontalDrag > 0){ Presentation.wrappedValue.dismiss() }
        }
      })
  }
}
