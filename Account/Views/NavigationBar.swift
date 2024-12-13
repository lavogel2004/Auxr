import SwiftUI

struct NavigationBar: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var account: AuxrAccount
  @EnvironmentObject var appleMusic: AppleMusic
  
  @Binding var CreateJoinMenu: Bool
  
  var body: some View {
    ZStack{
      HStack{
        Button(action: {
          router.selectedNavView = AccountViews.channels
          appleMusic.player.stop()
          appleMusic.player.queue.entries = []
          appleMusic.Queue = []
        }){
          VStack(spacing: 3){
            ZStack{
              Image("LogoNoText")
                .resizable()
                .frame(width: 30, height: 30)
            }
            .frame(width: 20, height: 20)
            Text("Sessions")
              .font(.system(size: 10, weight: .bold))
              .foregroundColor(Color("Tertiary"))
            if(router.selectedNavView == AccountViews.channels){
              RoundedRectangle(cornerRadius: 3)
                .fill(Color("Tertiary").opacity(0.3))
                .frame(width: String("Sessions").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)), height: 3)
            }
            else{
              RoundedRectangle(cornerRadius: 3)
                .fill(Color.clear)
                .frame(width: String("Sessions").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)), height: 3)
            }
          }
          .frame(width: UIScreen.main.bounds.size.width*0.13, height: UIScreen.main.bounds.size.width*0.13)
        }
        .padding(5)
        .offset(y: -10)
        
        Button(action: {
          router.selectedNavView = AccountViews.friends
          appleMusic.player.stop()
          appleMusic.player.queue.entries = []
          appleMusic.Queue = []
        }){
          VStack(spacing: 3){
            Image(systemName: "person.3.fill")
              .font(.system(size: 20, weight: .bold))
              .foregroundColor(Color("Tertiary"))
              .frame(width: 20, height: 20)
            Text("Friends")
              .font(.system(size: 10, weight: .bold))
              .foregroundColor(Color("Tertiary"))
            if(router.selectedNavView == AccountViews.friends){
              RoundedRectangle(cornerRadius: 3)
                .fill(Color("Tertiary").opacity(0.3))
                .frame(width: String("Friends").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)), height: 3)
            }
            else{
              RoundedRectangle(cornerRadius: 3)
                .fill(Color.clear)
                .frame(width: String("Friends").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)), height: 3)
            }
          }
          .frame(width: UIScreen.main.bounds.size.width*0.13, height: UIScreen.main.bounds.size.width*0.13)
        }
        .padding(5)
        .offset(y: -10)
        Button(action: {
          CreateJoinMenu.toggle()
        }){
          VStack(spacing: 3){
            ZStack{
              Image(systemName: "plus")
                .font(.system(size: UIScreen.main.bounds.size.width*0.06, weight: .bold))
                .foregroundColor(Color("Secondary"))
                .frame(width: UIScreen.main.bounds.size.width*0.062, height: UIScreen.main.bounds.size.width*0.062)
            }
            .padding(UIScreen.main.bounds.size.width*0.023)
            .background(Circle().fill(Color("Tertiary")))
            RoundedRectangle(cornerRadius: 3)
              .fill(Color.clear)
              .frame(width: String("Create/Join").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)), height: 3)
          }
          .frame(width: UIScreen.main.bounds.size.width*0.13, height: UIScreen.main.bounds.size.width*0.13)
        }
        .padding(5)
        .offset(y: -UIScreen.main.bounds.size.height*0.02)
        Button(action: {
          router.selectedNavView = AccountViews.inbox
          Task{ try await room.Reset() }
          appleMusic.player.stop()
          appleMusic.player.queue.entries = []
          appleMusic.Queue = []
        }){
          ZStack{
            VStack(spacing: 3){
              Image(systemName: "bubble.left.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color("Tertiary"))
                .frame(width: 20, height: 20)
              Text("Inbox")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color("Tertiary"))
              if(router.selectedNavView == AccountViews.inbox){
                RoundedRectangle(cornerRadius: 3)
                  .fill(Color("Tertiary").opacity(0.3))
                  .frame(width: String("Inbox").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)), height: 3)
              }
              else{
                RoundedRectangle(cornerRadius: 3)
                  .fill(Color.clear)
                  .frame(width: String("Inbox").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)), height: 3)
              }
            }
            .frame(width: UIScreen.main.bounds.size.width*0.13, height: UIScreen.main.bounds.size.width*0.13)
            .offset(y: -0.5)
            if(!account.Inbox.isEmpty){
              ZStack{
                if(account.Inbox.count >= 99){
                  Capsule()
                    .fill(Color("Secondary"))
                    .frame(width: 29, height: 20)
                  Capsule()
                    .fill(Color("Red"))
                    .frame(width: 25, height: 16)
                  Text("99+")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color("Label"))
                }
                else{
                  Circle()
                    .fill(Color("Secondary"))
                    .frame(width: 20, height: 20)
                  Circle()
                    .fill(Color("Red"))
                    .frame(width: 16, height: 16)
                  Text("\(account.Inbox.count)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color("Label"))
                }
              }.offset(x: 10 , y: -19)
            }
          }
        }
        .padding(5)
        .offset(y: -10)
        Button(action: {
          router.selectedNavView = AccountViews.profile
          appleMusic.player.stop()
          appleMusic.player.queue.entries = []
          appleMusic.Queue = []
        }){
          VStack(spacing: 3){
            Image(systemName: "person.fill")
              .font(.system(size: 20, weight: .bold))
              .foregroundColor(Color("Tertiary"))
              .frame(width: 20, height: 20)
            Text("Profile")
              .font(.system(size: 10, weight: .bold))
              .foregroundColor(Color("Tertiary"))
            if(router.selectedNavView == AccountViews.profile){
              RoundedRectangle(cornerRadius: 3)
                .fill(Color("Tertiary").opacity(0.3))
                .frame(width: String("Profile").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)), height: 3)
            }
            else{
              RoundedRectangle(cornerRadius: 3)
                .fill(Color.clear)
                .frame(width: String("Profile").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)), height: 3)
            }
          }
          .frame(width: UIScreen.main.bounds.size.width*0.13, height: UIScreen.main.bounds.size.width*0.13)
        }
        .padding(5)
        .offset(y: -10)
      }
      .frame(width: UIScreen.main.bounds.size.width*0.8, height: UIScreen.main.bounds.size.height*0.13, alignment: .center)
    }
    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.13, alignment: .center)
    .background(Rectangle().fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
  }
}
