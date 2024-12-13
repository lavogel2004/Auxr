import SwiftUI
import MessageUI

struct ShareOverlay: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  
  let Passcode: String
  @Binding var Show: Bool
  @Binding var Copied: Bool
  @Binding var ShowFriendPopover: Bool
  @Binding var OtherOptions: Bool
  
  var body: some View {
    ZStack{
      if(Show){
        Rectangle()
          .fill(Color("Secondary").opacity(0.75))
          .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
          .edgesIgnoringSafeArea(.all)
          .overlay(
            ZStack{
              if(user.pai.isEmpty || OtherOptions){
                VStack(spacing: 20){
                  ZStack{
                    Text("\(Passcode)")
                      .font(.system(size: 35, weight: .heavy))
                      .foregroundColor(Color("Text"))
                  }
                  .frame(height: 35, alignment: .center)
                  VStack(spacing: 7){
                    ShareLink(item: "https://apps.apple.com/us/app/auxr-share-the-aux/id1667666452", message: Text(String(user.Nickname + " invited you to their AUXR Playlist!\nJoin with Passcode: " + Passcode))){
                      ZStack{
                        HStack{
                          Image(systemName: "arrowshape.turn.up.right.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color("Tertiary"))
                            .frame(width: 20, height: 20, alignment: .center)
                          Text("Send To..")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color("Text"))
                            .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .leading)
                        }
                      }
                      .padding(15)
                      .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow").opacity(0.5), radius: 1))
                      .frame(width: UIScreen.main.bounds.size.width*0.45, alignment: .center)
                    }
                    Button(action: {
                      CopyToClipboard(Text: Passcode)
                      withAnimation(.easeIn(duration: 0.2)){
                        Show = false
                        Copied = true
                      }
                    }){
                      ZStack{
                        HStack{
                          Image(systemName: "square.fill.on.square.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color("Tertiary"))
                            .frame(width: 20, height: 20, alignment: .center)
                          Text("Copy")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color("Text"))
                            .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .leading)
                        }
                      }
                      .padding(15)
                      .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow").opacity(0.5), radius: 1))
                      .frame(width: UIScreen.main.bounds.size.width*0.45, alignment: .center)
                    }
                    if(!user.pai.isEmpty){
                      Button(action: {
                        withAnimation(.easeIn(duration: 0.2)){
                          ShowFriendPopover = true
                        }
                      }){
                        ZStack{
                          HStack{
                            ZStack{
                              Image(systemName: "person.3.fill")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color("Tertiary"))
                                .frame(width: 20, height: 20, alignment: .center)
                            }
                            .offset(y: -2)
                            Text("Friends")
                              .font(.system(size: 14, weight: .bold))
                              .foregroundColor(Color("Text"))
                              .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .leading)
                          }
                        }
                        .padding(15)
                        .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow").opacity(0.5), radius: 1))
                        .frame(width: UIScreen.main.bounds.size.width*0.45, alignment: .center)
                      }
                    }
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.45, alignment: .center)
                  ZStack{
                    Button(action: { Show = false }){
                      ZStack{
                        Text("CLOSE")
                          .font(.system(size: 13, weight: .bold))
                          .foregroundColor(Color("Red"))
                      }
                    }
                    .frame(width: UIScreen.main.bounds.size.width*0.45, alignment: .center)
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.45, alignment: .bottom)
                }
                .frame(width: UIScreen.main.bounds.size.width*0.45, alignment: .center)
                .padding(20)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")).shadow(color: Color("Shadow").opacity(0.5), radius: 1))
                .zIndex(4)
              }
              else{
                Spacer().frame(height: 0)
                  .onAppear{ ShowFriendPopover = true }
              }
            }
          )
      }
    }
    .frame(width: UIScreen.main.bounds.size.width*0.8, height: UIScreen.main.bounds.size.height*0.8, alignment: .center)
    .zIndex(4)
  }
}
