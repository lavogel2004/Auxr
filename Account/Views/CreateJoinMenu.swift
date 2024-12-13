import SwiftUI

struct CreateJoinMenu: View {
  @EnvironmentObject var room: Room
  @Binding var Show: Bool
  
  var body: some View {
    ZStack{
      VStack(alignment: .center, spacing: 5){
        Spacer().frame(height: 0)
        ZStack{
          NavigationLink(destination: CreateRoomView()){
            ZStack{
              HStack(alignment: .bottom, spacing: 10){
                ZStack{
                  Image("SmallLogoNoText")
                    .resizable()
                    .frame(width: 24, height: 24)
                }
                .frame(width: 23, height: 23, alignment: .bottom)
                .offset(x: -2)
                ZStack{
                  Text("Create Session")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("Text"))
                }
                .frame(height: 23, alignment: .bottom)
              }
            }
            .frame(width: UIScreen.main.bounds.size.width*0.38, alignment: .leading)
          }
          .frame(width: UIScreen.main.bounds.size.width*0.4, height: UIScreen.main.bounds.size.height*0.03, alignment: .leading)
        }
        .offset(x: UIScreen.main.bounds.size.width*0.025)
        Divider()
          .frame(width: UIScreen.main.bounds.size.width*0.4, height: 1)
          .background(Color("LightGray").opacity(0.6))
        ZStack{
          NavigationLink(destination: JoinRoomView()){
            ZStack{
              HStack(alignment: .bottom, spacing: 10){
                ZStack{
                  Image(systemName: "ipad.and.arrow.forward")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                }
                .offset(x: -5)
                .frame(width: 23, height: 23, alignment: .bottom)
                ZStack{
                  Text("Join Session")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("Text"))
                }
                .frame(height: 23, alignment: .bottom)
              }
              .padding(2)
            }
            .frame(width: UIScreen.main.bounds.size.width*0.38, alignment: .leading)
          }
          .frame(width: UIScreen.main.bounds.size.width*0.4, height: UIScreen.main.bounds.size.height*0.03, alignment: .leading)
        }
        .offset(x: UIScreen.main.bounds.size.width*0.025)
        Spacer().frame(height: 0)
      }
      .frame(width: UIScreen.main.bounds.size.width*0.4)
    }
    .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
    .padding(11)
    .onAppear{ Task{ try await room.Reset() } }
  }
}
