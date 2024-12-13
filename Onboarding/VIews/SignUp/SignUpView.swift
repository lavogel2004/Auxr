import SwiftUI

enum SignUpSteps: String, CaseIterable, Identifiable {
  case required,
       personalization,
       extraInfo
  var id: Self { self }
}

struct SignUpView: View {
  @Environment(\.presentationMode) var Presentation
  @EnvironmentObject var router: Router
  @EnvironmentObject var user: User
  
  @Binding var StepView: SignUpSteps
  
  @State private var Loading: Bool = false
  @State private var Success: Bool = false
  @State private var Completed: Bool = false
  @State private var Error: AuxrAccountOnboardingError = AuxrAccountOnboardingError.none
  
  @State private var ShowOfflineOverlay: Bool = false
  @State private var ShowInfoOverlay: Bool = false
  
  var body: some View {
    ZStack{
      Color("Primary").edgesIgnoringSafeArea(.all)
      
      if(ShowOfflineOverlay){ OfflineOverlay(networkStatus: NetworkStatus.notConnected, Show: $ShowOfflineOverlay) }
      if(ShowInfoOverlay){ SignUpStepOverlay(Show: $ShowInfoOverlay) }
      
      if(StepView == SignUpSteps.required){
        ZStack{
          Button(action: {
            Presentation.wrappedValue.dismiss()
            StepView = SignUpSteps.required
          }){
            Image(systemName: "chevron.left")
              .font(.system(size: 20, weight: .medium))
              .foregroundColor(Color("Tertiary"))
              .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .leading)
          }
        }
        .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .topLeading)
        .offset(y: -UIScreen.main.bounds.size.height/2*0.85)
      }
      
      ZStack{
        VStack{
          ZStack{
            Image("LogoNoText")
              .resizable()
              .frame(width: UIScreen.main.bounds.size.height*0.07, height: UIScreen.main.bounds.size.height*0.07)
          }
          switch(StepView){
          case SignUpSteps.required:
            HStack(spacing: 3){
              Text("Create AUXR Account")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color("Text"))
              Button(action: { ShowInfoOverlay = true }){
                ZStack{
                  Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(Color("Tertiary"))
                    .font(.system(size: 12, weight: .semibold))
                }
              }
            }
          case SignUpSteps.personalization:
            HStack(spacing: 3){
              Text("Personalization (Optional)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color("Text"))
              Button(action: { ShowInfoOverlay = true }){
                ZStack{
                  Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(Color("Tertiary"))
                    .font(.system(size: 12, weight: .semibold))
                }
              }
            }
          case SignUpSteps.extraInfo:
            ZStack{
              Text("Extra Info (Optional)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color("Text"))
              Button(action: { ShowInfoOverlay = true }){
                ZStack{
                  Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(Color("Tertiary"))
                    .font(.system(size: 12, weight: .semibold))
                }
              }
            }
          }
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .center)
      .offset(y: -UIScreen.main.bounds.size.height/2*0.7)
      
      VStack{
        ZStack{
          switch(StepView){
          case SignUpSteps.required:
            SignUpRequiredStepView(Error: $Error, StepView: $StepView, Offline: $ShowOfflineOverlay)
          case SignUpSteps.personalization:
            if let _ = user.Account {
              SignUpPersonalizationStepView(Error: $Error, StepView: $StepView, Offline: $ShowOfflineOverlay)
            }
          case SignUpSteps.extraInfo: SignUpExtraInfoStepView()
          }
        }
      }
      .frame(maxHeight: UIScreen.main.bounds.size.height*0.76, alignment: .top)
    }
    .frame(maxHeight: UIScreen.main.bounds.size.height, alignment: .center)
    .ignoresSafeArea(.keyboard, edges: .all)
    .navigationBarHidden(true)
    .onTapGesture { UIApplication.shared.dismissKeyboard() }
  }
}
