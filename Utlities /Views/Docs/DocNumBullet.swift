import SwiftUI

struct DocNumBullet: View {
  let num: String
  let text: String
  var body: some View {
    ZStack{
      Text(text)
        .font(.system(size: 11, weight: .medium))
        .foregroundColor(Color("Text"))
        .frame(width: UIScreen.main.bounds.size.width*0.8, alignment: .topLeading)
        .multilineTextAlignment(.leading)
    }
  }
}
