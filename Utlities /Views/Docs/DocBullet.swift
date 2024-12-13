import SwiftUI

struct DocBullet: View {
  let text: String
  let height: CGFloat
  var body: some View {
    HStack(spacing: 3){
      ZStack{
        Circle()
          .fill(Color("Text"))
          .frame(width: 3, height: 3)
      }
      .frame(width: 10, height: UIScreen.main.bounds.size.height*height, alignment: .top)
      .offset(y: 3.5)
      Text(text)
        .multilineTextAlignment(.leading)
        .font(.system(size: 10, weight: .medium))
        .foregroundColor(Color("Text"))
        .frame(width: UIScreen.main.bounds.size.width*0.72, alignment: .topLeading)
    }
  }
}
