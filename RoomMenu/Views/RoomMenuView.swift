import SwiftUI

struct MenuView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  
  let TMR = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()
  
  @Binding var Share: Bool
  @Binding var RecentSearch: Bool
  
  @State private var ShowMenu: Bool = false
  @State private var offset: Int = 10
  
  var body: some View {
    ZStack{
      HStack(spacing: 10){
        ZStack{
          HStack(spacing: 5){
            Button(action: { withAnimation(.easeInOut(duration: 0.4)){ ShowMenu.toggle() }}){
              HStack(spacing: 2){
                if(!ShowMenu){
                  Text("\(room.Name)")
                    .lineLimit(1)
                    .font(.system(size: 30, weight: .medium))
                    .foregroundColor(Color("Text"))
                }
                Image(systemName: "line.3.horizontal")
                  .font(.system(size: 25, weight: .bold))
                  .foregroundColor(Color("Text"))
                  .offset(y: 2.5)
              }
            }
            if(ShowMenu){
              withAnimation(.easeIn(duration: 0.4)){
                ZStack{
                  HStack(spacing: 7){
                    // MARK: Likes Navigation Button
                    NavigationLink(destination: LikesView()){
                      ZStack{
                        Image(systemName: "heart.fill")
                          .font(.system(size: 18, weight: .bold))
                          .foregroundColor(Color("Tertiary"))
                      }
                      .frame(width: 30, alignment: .center)
                      .padding(3)
                    }
                    .offset(y: 3)
                    // MARK: History Navigation Button
                    NavigationLink(destination: HistoryView()){
                      ZStack{
                        Image(systemName: "clock.arrow.circlepath")
                          .font(.system(size: 18, weight: .bold))
                          .foregroundColor(Color("Tertiary"))
                      }
                      .frame(width: 30, alignment: .center)
                      .padding(3)
                    }
                    .offset(y: 3)
                    // MARK: Listeners Navigation Button
                    NavigationLink(destination: ListenersView()){
                      ZStack{
                        Image(systemName: "person.3.fill")
                          .font(.system(size: 18, weight: .bold))
                          .foregroundColor(Color("Tertiary"))
                      }
                      .frame(width: 30, alignment: .center)
                      .padding(3)
                    }
                    .offset(y: 3)
                  }
                }
              }
              .onDisappear{ offset = 10 }
              .onReceive(TMR){ _ in
                withAnimation(.easeInOut(duration: 0.4)){  if(offset < 0){ offset += 10 } }
              }
              .offset(x: CGFloat(offset))
            }
          }
        }
        .frame(width: UIScreen.main.bounds.size.width*0.68, alignment: .leading)
        ZStack{
          HStack(spacing: 20){
            if(room.SharePermission || room.Creator(User: user)){
              ZStack{
                Button(action: {
                  UIApplication.shared.dismissKeyboard()
                  Share = true
                  RecentSearch = false
                }){
                  ZStack{
                    Image(systemName: "square.and.arrow.up")
                      .font(.system(size: 25, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                      .offset(y: -2.5)
                      .frame(width: 25, alignment: .center)
                  }
                }
              }
            }
            // MARK: Settings Navigation Button
            ZStack{
              NavigationLink(destination: SettingsView()){
                ZStack{
                  Image(systemName: "gearshape.fill")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                }
                .frame(width: 25, alignment: .center)
              }
            }
          }
        }
        .frame(width: UIScreen.main.bounds.size.width*0.1, alignment: .trailing)
        .offset(x: UIScreen.main.bounds.size.width*0.07)
      }
      .frame(width: UIScreen.main.bounds.size.width*0.88, alignment: .leading)
    }
    .padding(10)
  }
}
