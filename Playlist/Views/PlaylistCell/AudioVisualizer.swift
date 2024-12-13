import SwiftUI

struct AudioVisualizer: View {
  let TMR = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
  
  @State private var Animate = false
  @State private var Bar1Value: Double = 0.4
  @State private var Bar2Value: Double = 0.2
  @State private var Bar3Value: Double = 0.5
  @State private var Bar4Value: Double = 0.35
  
  var body: some View {
    HStack(spacing: 1){
      bar(low: Bar1Value)
        .animation(.linear(duration: 0.5).repeatForever().speed(1.5), value: Animate)
      bar(low: Bar2Value)
        .animation(.linear(duration: 0.5).repeatForever().speed(1.5), value: Animate)
      bar(low: Bar3Value)
        .animation(.linear(duration: 0.5).repeatForever().speed(1.5), value: Animate)
      bar(low: Bar4Value)
        .animation(.linear(duration: 0.5).repeatForever().speed(1.5), value: Animate)
    }
    .onAppear{ Animate = true }
    .onReceive(TMR){ _ in
      let BarValues: [Double] = [0.3, 0.1, 0.4, 0.25, 0.2, 0.15, 0.55]
      Bar1Value = BarValues.randomElement() ?? 0.4
      Bar2Value = BarValues.randomElement() ?? 0.2
      Bar3Value = BarValues.randomElement() ?? 0.5
      Bar4Value = BarValues.randomElement() ?? 0.35
    }
  }
  
  func bar(low: CGFloat = 0.0, high: CGFloat = 1.0) -> some View {
    RoundedRectangle(cornerRadius: 1.5)
      .fill(Color("Tertiary"))
      .frame(width: 3, height: (Animate ? high : low) * 10)
  }
}
