import SwiftUI

struct FriendsSearchBarView: View {
  @Binding var Input: String
  
  var body: some View {
    VStack{
      HStack{
        Image(systemName: "magnifyingglass")
          .foregroundColor(Color("Tertiary"))
          .font(.system(size: 13, weight: .semibold))
          .frame(width: UIScreen.main.bounds.size.width*0.1, alignment: .center)
        TextField("Search Friends", text: $Input)
          .font(.system(size: 17, weight: .medium))
          .foregroundColor(Color("Text"))
          .frame(width: UIScreen.main.bounds.size.width*0.65, alignment: .leading)
          .disableAutocorrection(true)
          .ignoresSafeArea(.keyboard, edges: .all)
        if(!Input.isEmpty){
          Button(action: { Input = "" }){
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

