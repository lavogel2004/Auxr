import SwiftUI

struct PlusSign: Shape {
  func path(in rect: CGRect) -> Path {
    var Path: Path = Path()
    
    let Width = rect.width
    let Height = rect.height
    
    let CenterX = rect.midX
    let CenterY = rect.midY
    
    let HorizontalLineLength = Width * 0.6
    let VerticalLineLength = Height * 0.6
    
    let StartX = CenterX - HorizontalLineLength / 2
    let EndX = CenterX + HorizontalLineLength / 2
    let StartY = CenterY - VerticalLineLength / 2
    let EndY = CenterY + VerticalLineLength / 2
    
    Path.move(to: CGPoint(x: StartX, y: CenterY))
    Path.addLine(to: CGPoint(x: EndX, y: CenterY))
    Path.move(to: CGPoint(x: CenterX, y: StartY))
    Path.addLine(to: CGPoint(x: CenterX, y: EndY))
    
    return Path
  }
}

struct QueuedLoaderView: View {
  let TMR = Timer.publish(every: 0.02, on: .current, in: .common).autoconnect()
 
  @Binding var Loading: Bool
  @Binding var Completed: Bool
  
  @State private var  Progress: Float = 0.0
  @State private var Animate: Bool = false
  
  var body: some View {
    if(!Completed){
      ZStack{
        PlusSign()
          .trim(from: 0.0, to: CGFloat(min(Progress, 1)))
          .stroke(style: StrokeStyle(lineWidth: 2.5, lineCap: .butt, lineJoin: .miter))
          .foregroundColor(Color("Tertiary"))
          .rotationEffect(Angle(degrees: 270.0))
          .animation(.linear, value: Animate)
          .onReceive(TMR){ _ in
            if(Loading){
              Animate = true
              Progress += 0.2
            }
            if(Progress >= 1){
              Completed = true
              Loading = false
              Animate = false
            }
          }
      }
    }
  }
}
