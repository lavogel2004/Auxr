import SwiftUI
import MessageUI

struct ChannelListenersView: View {
  @Environment(\.presentationMode) var Presentation
  @EnvironmentObject var router: Router
  @EnvironmentObject var user: User
  @EnvironmentObject var account: AuxrAccount
  @EnvironmentObject var appleMusic: AppleMusic
  
  let RoomID: String
  
  @State private var channel: Room? = nil
  @State private var SelectedUser: User = User()
  @State private var ShareOverlay: Bool = false
  @State private var ShowListenerMenu: Bool = false
  @State private var ShowOfflineOverlay: Bool = false
  @State private var ShowSwapHostOverlay: Bool = false
  @State private var SwapHostResponse: Bool = false
  @State private var SwapHostError: Bool = false
  @State private var AddedUser: Bool = false
  @State private var AlreadyAdded: Bool = false
  @State private var ShowRemoveOverlay: Bool = false
  @State private var Loading: Bool = true
  @State private var navigated: Bool = false
  @State private var reload: Bool = false
  
  var body: some View {
    ZStack{
      Color("Primary").edgesIgnoringSafeArea(.all)
      if(ShowOfflineOverlay){ OfflineOverlay(networkStatus: NetworkStatus.notConnected, Show: $ShowOfflineOverlay) }
      if(ShowSwapHostOverlay){ AccountOverlay(type: AccountOverlayType.swapHost, Show: $ShowSwapHostOverlay, Response: $SwapHostResponse) }
      if(SwapHostResponse && !SwapHostError){ GeneralOverlay(type: GeneralOverlayType.swapHost, Show: $SwapHostResponse).onAppear{ ShowListenerMenu = false } }
      else if(SwapHostError){
        GeneralOverlay(type: GeneralOverlayType.swapHostError, Show: $SwapHostError).onAppear{
          ShowListenerMenu = false
          SwapHostResponse = false
        }
      }
      if(AddedUser){ GeneralOverlay(type: GeneralOverlayType.addedFriend , Show: $AddedUser) }
      else if(AlreadyAdded){ GeneralOverlay(type: GeneralOverlayType.alreadySent, Show: $AlreadyAdded) }
      if(ShowRemoveOverlay){ GeneralOverlay(type: GeneralOverlayType.remove, Show: $ShowRemoveOverlay) }
      
      if(channel != nil){
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
            Text("(\(String((channel?.Guests.count ?? 0) + 1)))")
              .font(.system(size: 20, weight: .bold))
              .foregroundColor(Color("Text"))
              .multilineTextAlignment(.center)
          }
        }
        .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .trailing)
        .offset(x: -UIScreen.main.bounds.size.width*0.03, y: -UIScreen.main.bounds.size.height/2*0.8)
        
        VStack{
          // MARK: channel Listeners Scroll View
          ScrollView(showsIndicators: false){
            VStack(spacing: 0){
              // MARK: Room Creator
              HStack{
                if(channel?.Creator.pai == account.ID){
                  Button(action: {
                    Presentation.wrappedValue.dismiss()
                    router.selectedNavView = AccountViews.profile
                  }){
                    ZStack{
                      HStack(spacing: 7){
                        if(!(channel?.Creator.pai.isEmpty ?? false)){
                          Circle()
                            .fill(Color("Tertiary"))
                            .frame(width: 11, height: 11)
                        }
                        else{
                          Circle()
                            .fill(Color("System"))
                            .frame(width: 11, height: 11)
                        }
                        Text(channel?.Creator.Nickname ?? "@AUXRUser")
                          .lineLimit(1)
                          .font(.system(size: 15, weight: .semibold))
                          .foregroundColor(Color("Text"))
                      }
                    }
                    .frame(width: UIScreen.main.bounds.width*0.4, height: 30, alignment: .leading)
                    .offset(x: UIScreen.main.bounds.size.width*0.03)
                  }
                }
                else{
                  NavigationLink(destination: SelectedProfileView(friendID: channel?.Creator.pai ?? "").environmentObject(account)){
                    ZStack{
                      HStack(spacing: 7){
                        if(!(channel?.Creator.pai.isEmpty ?? false)){
                          Circle()
                            .fill(Color("Tertiary"))
                            .frame(width: 11, height: 11)
                        }
                        else{
                          Circle()
                            .fill(Color("System"))
                            .frame(width: 11, height: 11)
                        }
                        Text(channel?.Creator.Nickname ?? "@AUXRUser")
                          .lineLimit(1)
                          .font(.system(size: 15, weight: .semibold))
                          .foregroundColor(Color("Text"))
                      }
                    }
                    .frame(width: UIScreen.main.bounds.width*0.4, height: 30, alignment: .leading)
                    .offset(x: UIScreen.main.bounds.size.width*0.03)
                    
                  }
                  .disabled((channel?.Creator.pai.isEmpty ?? false))
                }
                if(account.Friends.contains(where: { $0.ID == channel?.Creator.pai ?? "" }) && !ShowListenerMenu){
                  ZStack{
                    Text("Friends")
                      .font(.system(size: 10, weight: .bold))
                      .foregroundColor(Color("Label"))
                  }
                  .frame(width: String("Friends").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)))
                  .padding(5)
                  .background(Capsule().fill(Color("Tertiary").opacity(0.6)))
                  .offset(x: UIScreen.main.bounds.size.width*0.1)
                }
                else{
                  Spacer()
                    .frame(width: String("Friends").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)))
                    .padding(5)
                    .offset(x: UIScreen.main.bounds.size.width*0.1)
                }
                ZStack{
                  Text("Creator")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.3, height: 30, alignment: .trailing)
                .offset(x: -UIScreen.main.bounds.size.width*0.03)
              }
              .frame(width: UIScreen.main.bounds.width*0.88, height: 50)
              
              // MARK: Room Host
              HStack{
                if(channel?.Host.pai == account.ID){
                  Button(action: {
                    Presentation.wrappedValue.dismiss()
                    router.selectedNavView = AccountViews.profile
                  }){
                    ZStack{
                      HStack(spacing: 7){
                        if(!(channel?.Host.pai.isEmpty ?? false)){
                          Circle()
                            .fill(Color("Tertiary"))
                            .frame(width: 11, height: 11)
                        }
                        else{
                          Circle()
                            .fill(Color("System"))
                            .frame(width: 11, height: 11)
                        }
                        Text(channel?.Host.Nickname ?? "@AUXRUser")
                          .lineLimit(1)
                          .font(.system(size: 15, weight: .semibold))
                          .foregroundColor(Color("Text"))
                      }
                    }
                    .frame(width: UIScreen.main.bounds.width*0.4, height: 30, alignment: .leading)
                    .offset(x: UIScreen.main.bounds.size.width*0.03)
                    Spacer()
                      .frame(width: String("Friends").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)))
                      .padding(5)
                      .offset(x: UIScreen.main.bounds.size.width*0.1)
                  }
                }
                else{
                  NavigationLink(destination: SelectedProfileView(friendID: channel?.Host.pai ?? "").environmentObject(account)){
                    ZStack{
                      HStack(spacing: 7){
                        if(!(channel?.Host.pai.isEmpty ?? false)){
                          Circle()
                            .fill(Color("Tertiary"))
                            .frame(width: 11, height: 11)
                        }
                        else{
                          Circle()
                            .fill(Color("System"))
                            .frame(width: 11, height: 11)
                        }
                        Text(channel?.Host.Nickname ?? "@AUXRUser")
                          .lineLimit(1)
                          .font(.system(size: 15, weight: .semibold))
                          .foregroundColor(Color("Text"))
                      }
                    }
                    .frame(width: UIScreen.main.bounds.width*0.4, height: 30, alignment: .leading)
                    .offset(x: UIScreen.main.bounds.size.width*0.03)
                  }
                  .disabled((channel?.Host.pai.isEmpty ?? false))
                }
                if(channel?.Host.pai ?? "" != account.ID){
                  if(account.Friends.contains(where: { $0.ID == channel?.Host.pai ?? "" }) && !ShowListenerMenu){
                    ZStack{
                      Text("Friends")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color("Label"))
                    }
                    .frame(width: String("Friends").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)))
                    .padding(5)
                    .background(Capsule().fill(Color("Tertiary").opacity(0.6)))
                    .offset(x: UIScreen.main.bounds.size.width*0.1)
                  }
                  else{
                    Spacer()
                      .frame(width: String("Friends").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)))
                      .padding(5)
                      .offset(x: UIScreen.main.bounds.size.width*0.1)
                  }
                }
                ZStack{
                  Text("Host")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.3, height: 30, alignment: .trailing)
                .offset(x: -UIScreen.main.bounds.size.width*0.0365)
              }
              .frame(width: UIScreen.main.bounds.width*0.88, height: 50)
              
              // MARK: Room Guests
              if let RoomGuests = channel?.Guests.sorted(){
                ForEach(RoomGuests){ guest in
                  HStack{
                    if(guest.pai == account.ID){
                      Button(action: {
                        Presentation.wrappedValue.dismiss()
                        router.selectedNavView = AccountViews.profile
                      }){
                        ZStack{
                          HStack(spacing: 7){
                            if(!guest.pai.isEmpty){
                              Circle()
                                .fill(Color("Tertiary"))
                                .frame(width: 11, height: 11)
                            }
                            else{
                              Circle()
                                .fill(Color("System"))
                                .frame(width: 11, height: 11)
                            }
                            Text(guest.Nickname)
                              .lineLimit(1)
                              .font(.system(size: 15, weight: .semibold))
                              .foregroundColor(Color("Text"))
                          }
                        }
                        .frame(width: UIScreen.main.bounds.width*0.4, height: 30, alignment: .leading)
                        .offset(x: UIScreen.main.bounds.size.width*0.03)
                      }
                    }
                    else{
                      NavigationLink(destination: SelectedProfileView(friendID: guest.pai).environmentObject(account)){
                        HStack(spacing: 7){
                          if(!(guest.pai.isEmpty)){
                            Circle()
                              .fill(Color("Tertiary"))
                              .frame(width: 11, height: 11)
                          }
                          else{
                            Circle()
                              .fill(Color("System"))
                              .frame(width: 11, height: 11)
                          }
                          Text(guest.Nickname)
                            .lineLimit(1)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color("Text"))
                        }
                        .frame(width: UIScreen.main.bounds.width*0.4, alignment: .leading)
                        .offset(x: UIScreen.main.bounds.size.width*0.03)
                      }
                      .disabled((guest.pai.isEmpty))
                    }
                    if(account.Friends.contains(where: { $0.ID == guest.pai }) && !ShowListenerMenu){
                      ZStack{
                        Text("Friends")
                          .font(.system(size: 10, weight: .bold))
                          .foregroundColor(Color("Label"))
                      }
                      .frame(width: String("Friends").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)))
                      .padding(5)
                      .background(Capsule().fill(Color("Tertiary").opacity(0.6)))
                      .offset(x: UIScreen.main.bounds.size.width*0.1)
                    }
                    else{
                      Spacer()
                        .frame(width: String("Friends").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)))
                        .padding(5)
                        .offset(x: UIScreen.main.bounds.size.width*0.1)
                    }
                    ZStack{
                      Button(action: {
                        SelectedUser = guest
                        withAnimation(.easeIn(duration: 0.2)){ ShowListenerMenu = true }
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
                      }
                      .offset(x: -UIScreen.main.bounds.size.width*0.038)
                      .frame(width: UIScreen.main.bounds.size.width*0.3, alignment: .trailing)
                    }
                  }
                  .frame(width: (ShowListenerMenu && guest == SelectedUser) ? UIScreen.main.bounds.size.width*0.88 : UIScreen.main.bounds.size.width*0.9 , height: 50)
                  .background((ShowListenerMenu && guest == SelectedUser) ? RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1) : nil)
                  if(ShowListenerMenu && guest == SelectedUser){
                    ZStack{
                      ChannelListenerMenu(RoomID: RoomID, SelectedUser: guest, Show: $ShowListenerMenu, SwapHost: $ShowSwapHostOverlay, SwapHostResponse: $SwapHostResponse, SwapHostError: $SwapHostError, AddedUser: $AddedUser, AlreadyAdded: $AlreadyAdded, Removed: $ShowRemoveOverlay, Offline: $ShowOfflineOverlay).environmentObject(account)
                    }
                    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .trailing)
                    .zIndex(2)
                    .offset(x: -4, y: 8)
                  }
                }
              }
            }
          }
        }
        .offset(y: UIScreen.main.bounds.size.height*0.085)
        .frame(width: UIScreen.main.bounds.size.width)
        if(reload){ Spacer().frame(height: 0) .onAppear{ reload = false } }
      }
    }
    .navigationBarHidden(true)
    .task{
      Task{
        channel = try await FirebaseManager.FetchRoomByID(ID: RoomID)
        // MARK: Firebase Listener [Room Updates]
        if let chnl = channel{
          FirebaseManager.GetRoomUpdates(room: chnl, completion: { UpdatedRoom, Status in
            Task{
              if(Status == "success"){
                try await chnl.ReplaceAll(Room: UpdatedRoom)
                reload = true
              }
              else{ try await chnl.Disconnect(User: user, AppleMusic: appleMusic, Router: router) }
            }
          })
        }
      }
    }
    .onDisappear{ if let chnl = channel{ FirebaseManager.RemoveObservers(Room: chnl) } }
    .onTapGesture{ if(!ShowSwapHostOverlay){ ShowListenerMenu = false } }
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
