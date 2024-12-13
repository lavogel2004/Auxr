import SwiftUI

struct SearchLoaderView: View {
  @EnvironmentObject var appleMusic: AppleMusic
  let TMR = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
  
  @Binding var Searching: Bool
  @Binding var Completed: Bool
  let length: CGFloat
  
  @State private var Animate: Bool = false
  @State private var FetchTime: Int = 2
  
  var body: some View {
    ZStack{
      if(Searching && !Completed){
        RoundedRectangle(cornerRadius: 1)
          .stroke(Color("Capsule").opacity(0.3), lineWidth: 1)
          .frame(width: 25, height: 1)
          .offset(x: Animate ? UIScreen.main.bounds.size.width*length: -UIScreen.main.bounds.size.width*length, y: 0)
          .animation(.linear(duration: 0.2).repeatForever(autoreverses: true), value: Animate)
          .onAppear{ Animate  = true }
      }
    }
    .onReceive(TMR){ _ in
      if(!appleMusic.UserRecommended.GeneratingRandom && !appleMusic.UserRecommended.GeneratingSimilar){
        if(FetchTime > 0){ FetchTime -= 1 }
        else{
          Completed = true
          Searching  = false
        }
      }
    }
  }
}
