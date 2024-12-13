import SwiftUI
import MessageUI

struct ListenersView: View {
  @Environment(\.scenePhase) var scenePhase
  @Environment(\.presentationMode) var Presentation
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  @State private var SelectedUser: User = User()
  @State private var Share: Bool = false
  @State private var ShowFriendPopover: Bool = false
  @State private var OtherShareOptions: Bool = false
  @State private var ShowCopyOverlay: Bool = false
  @State private var ShowListenerMenu: Bool = false
  @State private var ShowRemoveOverlay: Bool = false
  @State private var ShowPlayPauseEnabledOverlay: Bool = false
  @State private var ShowSkipEnabledOverlay: Bool = false
  @State private var ShowRemoveEnabledOverlay: Bool = false
  
  var body: some View {
    ZStack{
      Color("Primary").edgesIgnoringSafeArea(.all)
      
      if(Share){ ShareOverlay(Passcode: room.Passcode, Show: $Share, Copied: $ShowCopyOverlay, ShowFriendPopover: $ShowFriendPopover, OtherOptions: $OtherShareOptions) }
      if(ShowCopyOverlay){ GeneralOverlay(type: GeneralOverlayType.copy, Show: $ShowCopyOverlay) }
      if(ShowPlayPauseEnabledOverlay){ GeneralOverlay(type: GeneralOverlayType.enablePlayPause, Show: $ShowPlayPauseEnabledOverlay) }
      else if(ShowSkipEnabledOverlay){ GeneralOverlay(type: GeneralOverlayType.enableSkip, Show: $ShowSkipEnabledOverlay) }
      else if(ShowRemoveEnabledOverlay){ GeneralOverlay(type: GeneralOverlayType.enableRemove, Show: $ShowRemoveEnabledOverlay) }
      else if(ShowRemoveOverlay){ GeneralOverlay(type: GeneralOverlayType.remove, Show: $ShowRemoveOverlay) }
      
      HStack(alignment: .top){
        Button(action: { Presentation.wrappedValue.dismiss() }){
          Image(systemName: "chevron.left")
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(Color("Tertiary"))
            .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .leading)
            .padding(.leading, 10)
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.95, alignment: .topLeading)
      .offset(y: -UIScreen.main.bounds.size.height/2*0.85)
      
      HStack(spacing: 5){
          HStack(spacing: 2){
            Image(systemName: "music.quarternote.3")
              .font(.system(size: 20, weight: .bold))
              .foregroundColor(Color("Text"))
              .multilineTextAlignment(.center)
            Text("Listeners")
              .font(.system(size: 20, weight: .bold))
              .foregroundColor(Color("Text"))
              .multilineTextAlignment(.center)
            Text("(\(String(room.Guests.count+1)))")
              .font(.system(size: 20, weight: .bold))
              .foregroundColor(Color("Text"))
              .multilineTextAlignment(.center)
          }
        if(room.SharePermission || room.Creator(User: user)){
          ZStack{
            Button(action: { Share = true }){
              Image(systemName: "square.and.arrow.up")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color("Tertiary"))
            }
          }
          .offset(y: -2)
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .trailing)
      .offset(y: -UIScreen.main.bounds.size.height/2*0.8)
      
      VStack{
        ScrollView(showsIndicators: false){
          VStack(spacing: 0){
            HStack{
              ZStack{
                HStack(spacing: 7){
                  if(room.Creator.InRoom){
                    Circle()
                      .fill(Color("Green"))
                      .frame(width: 11, height: 11)
                  }
                  else{
                    Circle()
                      .fill(Color("System"))
                      .frame(width: 11, height: 11)
                  }
                  Text(room.Creator.Nickname)
                    .lineLimit(1)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
              }
              .frame(width: UIScreen.main.bounds.width*0.5, height: 30, alignment: .leading)
              HStack{
                Text("Creator")
                  .font(.system(size: 15, weight: .bold))
                  .foregroundColor(Color("Text"))
              }
              .frame(width: UIScreen.main.bounds.size.width*0.3, height: 30, alignment: .trailing)
              .offset(x: UIScreen.main.bounds.size.width*0.03)
            }
            .frame(width: UIScreen.main.bounds.width*0.88, height: 50)
            HStack{
              ZStack{
                HStack(spacing: 7){
                  if(room.Host.InRoom){
                    Circle()
                      .fill(Color("Green"))
                      .frame(width: 11, height: 11)
                  }
                  else{
                    Circle()
                      .fill(Color("System"))
                      .frame(width: 11, height: 11)
                  }
                  Text(room.Host.Nickname)
                    .lineLimit(1)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("Text"))
                }
              }
              .frame(width: UIScreen.main.bounds.width*0.5, height: 30, alignment: .leading)
              HStack{
                Text("Host")
                  .font(.system(size: 15, weight: .bold))
                  .foregroundColor(Color("Text"))
              }
              .frame(width: UIScreen.main.bounds.size.width*0.3, height: 30, alignment: .trailing)
              .offset(x: UIScreen.main.bounds.size.width*0.028)
            }
            .frame(width: UIScreen.main.bounds.width*0.88, height: 50)
            
            ForEach(room.Guests.sorted()){ guest in
              HStack{
                HStack(spacing: 7){
                  if(guest.InRoom){
                    Circle()
                      .fill(Color("Green"))
                      .frame(width: 11, height: 11)
                  }
                  else{
                    Circle()
                      .fill(Color("System"))
                      .frame(width: 11, height: 11)
                  }
                  Text(guest.Nickname)
                    .lineLimit(1)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.width*0.5, alignment: .leading)
                ZStack{
                  if(room.Host(User: user) || room.Creator(User: user)){
                    Button(action: {
                      ShowListenerMenu.toggle()
                      SelectedUser = guest
                    }){
                      ZStack{
                        if(!ShowListenerMenu){
                          Image(systemName: "ellipsis")
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundColor(Color("Tertiary").opacity(0.8))
                        }
                        if(ShowListenerMenu && guest == SelectedUser){
                          Image(systemName: "ellipsis")
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundColor(Color("Tertiary").opacity(0.4))
                        }
                      }
                      .offset(x: -UIScreen.main.bounds.size.width*0.008)
                      .frame(width: UIScreen.main.bounds.size.width*0.3, alignment: .trailing)
                    }
                  }
                  else{ ZStack{}.frame(width: UIScreen.main.bounds.size.width*0.3, alignment: .trailing) } }
              }
              .frame(width: (ShowListenerMenu && guest == SelectedUser) ? UIScreen.main.bounds.size.width*0.88 : UIScreen.main.bounds.size.width*0.9 , height: 50)
              .background( (ShowListenerMenu && guest == SelectedUser) ? RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1) : nil)
              if(ShowListenerMenu){
                ZStack{
                  if(guest == SelectedUser){
                    ListenerMenu(Show: $ShowListenerMenu, SelectedUser: $SelectedUser, PlayPauseEnabled: $ShowPlayPauseEnabledOverlay, SkipEnabled: $ShowSkipEnabledOverlay, RemoveEnabled: $ShowRemoveEnabledOverlay, Removed: $ShowRemoveOverlay)
                  }
                }
                .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .trailing)
                .zIndex(2)
                .offset(x: -4, y: 8)
              }
            }
          }
        }
      }
      .offset(y: UIScreen.main.bounds.size.height*0.085)
      .frame(width: UIScreen.main.bounds.size.width)
      
    }
    .popover(isPresented: $ShowFriendPopover){
      if let account: AuxrAccount = user.Account{
        FriendInvitePopover(RoomID: room.ID, Show: $ShowFriendPopover, ShowOtherOptions: $OtherShareOptions, ShowShareOverlay: $Share).environmentObject(account)
          .onAppear{ Share = false }
      }
    }
    // ListenerView Scene Handler
    .onChange(of: scenePhase){ phase in
      room.ScenePhaseHandler(phase: phase, User: user, AppleMusic: appleMusic)
    }
    .navigationBarHidden(true)
    .onTapGesture { ShowListenerMenu = false }
    .gesture(DragGesture(minimumDistance: 25, coordinateSpace: .global)
      .onEnded{ position in
        let HorizontalDrag = position.translation.width
        let VerticalDrag = position.translation.height
        if(abs(HorizontalDrag) > abs(VerticalDrag)){
          if(HorizontalDrag > 0){ Presentation.wrappedValue.dismiss() }
        }
      })
  }
}
