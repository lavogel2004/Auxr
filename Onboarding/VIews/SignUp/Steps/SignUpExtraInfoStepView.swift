import SwiftUI

struct SignUpExtraInfoStepView: View {
  var body: some View {
    ZStack{
      VStack{
        
      }
    }
    Text("extraStep")
      .frame(width: UIScreen.main.bounds.size.width*0.8, height: UIScreen.main.bounds.size.height*0.55)
      .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow").opacity(0.5), radius: 1))
      .zIndex(4)
  }
}
