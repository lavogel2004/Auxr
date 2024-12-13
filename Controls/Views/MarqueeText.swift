import SwiftUI

struct MarqueeText: View {
  let font: UIFont
  let leftFade: CGFloat
  let rightFade: CGFloat
  let startDelay: Double
  
  @Binding var text: String
  
  @State private var animate = false
  
  var body: some View {
    let stringWidth = text.widthOfString(usingFont: font)
    let stringHeight = text.heightOfString(usingFont: font)
    let animation = Animation
      .linear(duration: Double(stringWidth)/30)
      .delay(startDelay)
      .repeatForever(autoreverses: false)
    let nullAnimation = Animation
      .linear(duration: 0)
    
    ZStack{
      if(stringWidth > UIScreen.main.bounds.size.width*0.5){
        Group{
          ZStack{
            Text(self.text)
              .font(.system(size: 15, weight: .bold))
              .foregroundColor(Color("Text"))
              .offset(x: self.animate ? -stringWidth - stringHeight * 2 : 0)
              .animation(self.animate ? animation : nullAnimation, value: self.animate)
              .onAppear { self.animate = UIScreen.main.bounds.size.width*0.6 < stringWidth }
          }
          .fixedSize(horizontal: true, vertical: false)
          .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
          ZStack{
            Text(self.text)
              .font(.system(size: 15, weight: .bold))
              .foregroundColor(Color("Text"))
              .offset(x: self.animate ? 0 : stringWidth + stringHeight * 2)
              .animation(self.animate ? animation : nullAnimation, value: self.animate)
              .onAppear { self.animate = UIScreen.main.bounds.size.width*0.6 < stringWidth }
          }
          .fixedSize(horizontal: true, vertical: false)
          .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(width: UIScreen.main.bounds.size.width*0.62, alignment: .leading)
        .offset(y: 2)
        .onChange(of: self.text, perform: { text in
          withAnimation(.easeOut(duration: 0.2)){ self.animate = false }
          self.animate = UIScreen.main.bounds.size.width*0.6 < stringWidth
        })
        .offset(x: leftFade)
        .mask(
          HStack(spacing:0){
            Rectangle()
              .frame(width:2)
              .opacity(0)
            LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0), Color.black]), startPoint: .leading, endPoint: .trailing)
              .frame(width:leftFade)
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.black]), startPoint: .leading, endPoint: .trailing)
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.black.opacity(0)]), startPoint: .leading, endPoint: .trailing)
              .frame(width:rightFade)
            Rectangle()
              .frame(width:2)
              .opacity(0)
          })
        .frame(width: UIScreen.main.bounds.size.width*0.6 + leftFade)
        .offset(x: leftFade * -1, y: 2)
      }
      else{
        Text(self.text)
          .font(.system(size: 15, weight: .bold))
          .foregroundColor(Color("Text"))
          .onChange(of: self.text, perform: { text in
            self.animate = UIScreen.main.bounds.size.width*0.6 < stringWidth
          })
          .frame(minWidth: UIScreen.main.bounds.size.width*0.62, maxWidth: .infinity, alignment: .topLeading)
      }
    }
    .frame(height: stringHeight+2)
    .onDisappear { self.animate = false }
  }
}
