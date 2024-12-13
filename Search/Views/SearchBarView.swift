import SwiftUI

struct SearchBarView: View {
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  let srch: Search = Search()
  
  @Binding var Input: String
  @Binding var Filter: SearchFilter
  
  var body: some View {
    VStack{
      HStack{
        Image(systemName: "magnifyingglass")
          .foregroundColor(Color("Tertiary"))
          .font(.system(size: 13, weight: .semibold))
          .frame(width: UIScreen.main.bounds.size.width*0.1, alignment: .center)
        
        TextField("Search Songs, Albums, Artists", text: $Input)
          .font(.system(size: 17, weight: .medium))
          .foregroundColor(Color("Text"))
          .frame(width: UIScreen.main.bounds.size.width*0.65, alignment: .leading)
          .disableAutocorrection(true)
          .ignoresSafeArea(.keyboard, edges: .all)
        
        if(!Input.isEmpty){
          Button(action: {
            Input = ""
            srch.Reset(Room: room, AppleMusic: appleMusic)
          }){
            Image(systemName: "xmark")
              .foregroundColor(Color("Tertiary"))
              .font(.system(size: 13, weight: .semibold))
              .frame(width: UIScreen.main.bounds.size.width*0.1, alignment: .center)
          }
        }
        else{
          Circle()
            .fill(Color("Secondary").opacity(0))
            .frame(width:UIScreen.main.bounds.size.width*0.1, height: 10, alignment: .leading)
        }
      }
      .padding(10)
    }
    .frame(width: UIScreen.main.bounds.size.width*0.9, height: UIScreen.main.bounds.size.height*0.04)
    .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary").opacity(0.75)))
    .zIndex(3)
    .ignoresSafeArea(.keyboard, edges: .all)
  }
}
