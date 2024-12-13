import SwiftUI

struct OfflineOverlay: View {
  let networkStatus: NetworkStatus
  let TMR = Timer.publish(every: 0.3, on: .current, in: .common).autoconnect()
  
  @Binding var Show: Bool
  
  @State private var DisplayTime = 1.5
  
  var body: some View {
    ZStack(alignment: .center){
      Rectangle()
        .fill(Color("Secondary").opacity(0.75))
        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        .edgesIgnoringSafeArea(.all)
        .zIndex(5)
        .overlay(
          ZStack{
            if(Show){
              if(networkStatus == NetworkStatus.notConnected){
                HStack(spacing: 5){
                  Image(systemName: "wifi.slash")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("Red"))
                  Text("No Connection")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.34, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
                .zIndex(5)
              }
            }
          }
        )
    }
    .frame(width: UIScreen.main.bounds.size.width*0.8, height: UIScreen.main.bounds.size.height*0.08, alignment: .center)
    .zIndex(5)
    .onReceive(TMR){ _ in
      if(DisplayTime > 0){
        DisplayTime -= 0.5
      }
      else{ withAnimation(.easeOut(duration: 0.2)){ Show = false } }
    }
  }
}
