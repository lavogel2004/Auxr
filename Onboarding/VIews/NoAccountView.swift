import SwiftUI
import OSLog

struct NoAccountView: View {
  @Environment(\.presentationMode) var Presentation
  @EnvironmentObject var router: Router
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  var body: some View {
    ZStack{
      Color("Primary").edgesIgnoringSafeArea(.all)
      ZStack{
        Button(action: { Presentation.wrappedValue.dismiss()}){
          Image(systemName: "chevron.left")
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(Color("Tertiary"))
            .frame(width: UIScreen.main.bounds.size.width*0.2, height: 20, alignment: .leading)
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .topLeading)
      .offset(y: -UIScreen.main.bounds.size.height/2*0.85)
      VStack{
        
        // MARK: Create Playlist Navigation Button
        NavigationLink(destination: CreateRoomView()){
          Text("Create Session")
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(Color("Label"))
            .frame(width: UIScreen.main.bounds.size.width*0.5, height: 45)
            .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")).shadow(color: Color("Shadow"), radius: 1))
            .padding(10)
        }
        
        // MARK: Join Playlist Navigation Button
        NavigationLink(destination: JoinRoomView()){
          Text("Join Session")
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(Color("Label"))
            .frame(width: UIScreen.main.bounds.size.width*0.5, height: 45)
            .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")).shadow(color: Color("Shadow"), radius: 1))
            .padding(10)
        }
      }
      .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.75, alignment: .center)
      ZStack{
        Image("LogoNoText")
          .resizable()
          .frame(width: UIScreen.main.bounds.size.width*0.5, height: UIScreen.main.bounds.size.width*0.5)
      }
      .offset(y: UIScreen.main.bounds.size.height*0.28)
      .opacity(0.3)
    }
    .navigationBarHidden(true)
  }
}
