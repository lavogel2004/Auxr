import SwiftUI

struct DeleteAccountView: View {
  @Environment(\.presentationMode) var Presentation
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var apple_music: AppleMusic
  @EnvironmentObject var router: Router
  @State private var Delete: Bool = false
  @State private var DeleteResponse: Bool = false
  
  var body: some View {
    ZStack{
      Color("Primary").edgesIgnoringSafeArea(.all)
      if(Delete){ AccountOverlay(type: AccountOverlayType.deleteAccount, Show: $Delete, Response: $DeleteResponse) }
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
        Text("WARNING")
          .font(.system(size: 25, weight: .heavy))
          .foregroundColor(Color("Red"))
        Text("The following action permanently deletes your Auxr account and all associated account data. This action cannot be undone.")
          .font(.system(size: 14, weight: .bold))
          .foregroundColor(Color("Text"))
        Button(action: { Delete = true }){
          VStack{
            Text("Delete Account")
              .font(.system(size: 16, weight: .bold))
              .foregroundColor(Color("Red"))
          }
          .padding(10)
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.8, height: UIScreen.main.bounds.size.height*0.75, alignment: .topLeading)
      if(DeleteResponse){
        Spacer().frame(height: 0).onAppear{
          Task{
            do
            {
              if let acct = user.Account{
                try await AccountManager.deleteAccount(account: acct)
                try await SystemReset(User: user, Room: room, AppleMusic: apple_music)
                router.popToRoot()
              }
            }
            catch let error
            {
              print(error)
            }
          }
        }
      }
    }
    .navigationBarHidden(true)
  }
}
