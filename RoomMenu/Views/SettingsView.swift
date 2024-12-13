import SwiftUI
import MessageUI

struct SettingsViewHeight: PreferenceKey {
  static var defaultValue: CGFloat { 0 }
  static func reduce(value: inout Value, nextValue: () -> Value){ value = value + nextValue() }
}

struct SettingsView: View {
  @AppStorage("isDarkMode") private var isDarkMode = false
  
  @Environment(\.presentationMode) var Presentation
  @Environment(\.scenePhase) var scenePhase
  @EnvironmentObject var router: Router
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  @State private var ShowMyInfoDropDown: Bool = true
  @State private var ShowPlaylistDropDown: Bool = true
  @State private var ShowAppearanceDropDown: Bool = true
  @State private var ShowSharedControlsDropDown: Bool = true
  @State private var ShowListenerDropDown: Bool = true
  @State private var ShowOfflineOverlay: Bool = false
  @State private var Share: Bool = false
  @State private var ShowFriendPopover: Bool = false
  @State private var OtherShareOptions: Bool = false
  @State private var ShowCopyOverlay: Bool = false
  @State private var ShowUpdateOverlay: Bool = false
  @State private var ShowRemoveOverlay: Bool = false
  @State private var ShowPlayPauseEnabledOverlay: Bool = false
  @State private var ShowSkipEnabledOverlay: Bool = false
  @State private var ShowRemoveEnabledOverlay: Bool = false
  @State private var ShowVoteEnabledOverlay: Bool = false
  @State private var ShowMaxSongsOverlay: Bool = false
  @State private var ShowAppleMusicSubscriptionConnectOverlay: Bool =  false
  @State private var navigated: Bool = false
  @State private var completed: Bool = false
  
  var body: some View {
    ZStack{
      Color("Primary").edgesIgnoringSafeArea(.all)
      
      if(ShowOfflineOverlay){ OfflineOverlay(networkStatus: NetworkStatus.notConnected, Show: $ShowOfflineOverlay) }
      if(Share){ ShareOverlay(Passcode: room.Passcode, Show: $Share, Copied: $ShowCopyOverlay, ShowFriendPopover: $ShowFriendPopover, OtherOptions: $OtherShareOptions) }
      ZStack{
        if(ShowCopyOverlay){ GeneralOverlay(type: GeneralOverlayType.copy, Show: $ShowCopyOverlay) }
        else if(ShowUpdateOverlay){ GeneralOverlay(type: GeneralOverlayType.update, Show: $ShowUpdateOverlay) }
        else if(ShowRemoveOverlay){ GeneralOverlay(type: GeneralOverlayType.remove, Show: $ShowRemoveOverlay) }
        else if(ShowPlayPauseEnabledOverlay){ GeneralOverlay(type: GeneralOverlayType.enablePlayPause, Show: $ShowPlayPauseEnabledOverlay) }
        else if(ShowSkipEnabledOverlay){ GeneralOverlay(type: GeneralOverlayType.enableSkip, Show: $ShowSkipEnabledOverlay) }
        else if(ShowRemoveEnabledOverlay){ GeneralOverlay(type: GeneralOverlayType.enableRemove, Show: $ShowRemoveEnabledOverlay) }
        else if(ShowVoteEnabledOverlay){ GeneralOverlay(type: GeneralOverlayType.enableVote, Show: $ShowVoteEnabledOverlay) }
        else if(ShowMaxSongsOverlay){ GeneralOverlay(type: GeneralOverlayType.maxSongs, Show: $ShowMaxSongsOverlay) }
        else if(ShowAppleMusicSubscriptionConnectOverlay){ GeneralOverlay(type: GeneralOverlayType.connectUserAppleMusic, Show: $ShowAppleMusicSubscriptionConnectOverlay) }
        
        VStack(spacing: 10){
          ZStack{
            Button(action: { Presentation.wrappedValue.dismiss() }){
              Image(systemName: "chevron.left")
                .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .leading)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color("Tertiary"))
            }
          }
          .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .topLeading)
          .padding(.bottom, 10)
          
          ScrollView(showsIndicators: false){
            VStack{
              
              // MARK: User Info [Nickname, Status, Apple Music Account Subscription]
              VStack{
                HStack{
                  Button(action: { withAnimation(.easeInOut(duration: 0.4)){ ShowMyInfoDropDown.toggle() } }){
                    HStack(spacing: 7){
                      Image(systemName: "person.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color("Text"))
                        .frame(width: 30)
                        .padding(.leading, 10)
                      Text("My Info")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color("Text"))
                    }
                    .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .leading)
                    if(ShowMyInfoDropDown){
                      Image(systemName: "chevron.down").foregroundColor(Color("Tertiary"))
                        .frame(width:UIScreen.main.bounds.size.width*0.2, alignment: .trailing)
                        .font(.system(size: 15, weight: .bold))
                    }
                    else{
                      Image(systemName: "chevron.right").foregroundColor(Color("Text"))
                        .frame(width:UIScreen.main.bounds.size.width*0.2, alignment: .trailing)
                        .font(.system(size: 15, weight: .medium))
                    }
                  }
                }
                .frame(width: UIScreen.main.bounds.size.width*0.93, height: 30, alignment: .leading)
                if(ShowMyInfoDropDown){
                  VStack{
                    Text("Display Name")
                      .font(.system(size: 15, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                      .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                      .padding(.leading, 10)
                    Text(user.Nickname)
                      .lineLimit(1)
                      .font(.system(size: 15, weight: .medium))
                      .foregroundColor(Color("Text"))
                      .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                      .padding(.leading, 10)
                  }
                  .padding(.bottom, 5)
                  ZStack{
                    VStack{
                      Text("Status")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color("Tertiary"))
                        .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                      HStack{
                        ZStack{
                          if(room.Host(User: user)){
                            Text("Host")
                              .font(.system(size: 15, weight: .medium))
                              .foregroundColor(Color("Text"))
                              .frame(alignment: .leading)
                          }
                          if(room.Guest(User: user)){
                            Text("Guest")
                              .font(.system(size: 15, weight: .medium))
                              .foregroundColor(Color("Text"))
                          }
                        }
                      }
                      .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                    }
                    .padding(.leading, 10)
                  }
                  .padding(.bottom, 5)
                  ZStack{
                    VStack{
                      Text("Apple Music")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color("Tertiary"))
                        .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                      if(appleMusic.Subscription == AppleMusicSubscriptionStatus.active &&
                         appleMusic.CheckedForSubscription){
                        HStack{
                          ZStack{
                            Text("Active Subscription")
                              .font(.system(size: 15, weight: .medium))
                              .foregroundColor(Color("Text"))
                          }
                          .frame(alignment: .leading)
                          ZStack{
                            Text("CONNECTED")
                              .font(.system(size: 12, weight: .bold))
                              .foregroundColor(Color("Tertiary"))
                          }
                          .frame(maxWidth: .infinity, alignment: .trailing)
                          .padding(.trailing, 5)
                        }
                        .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                      }
                      if(appleMusic.Subscription == AppleMusicSubscriptionStatus.notChecked &&
                         !appleMusic.CheckedForSubscription){
                        HStack{
                          ZStack{
                            Text("Not Connected")
                              .font(.system(size: 15, weight: .medium))
                              .foregroundColor(Color("Text"))
                          }
                          .frame(alignment: .leading)
                          ZStack{
                            Button(action: {
                              withAnimation(.easeInOut(duration: 0.2)){ ShowAppleMusicSubscriptionConnectOverlay = true }
                              Task{
                                appleMusic.CheckSubscription(completion: { _ in })
                                try await appleMusic.GetUserPlaylists()
                              }
                            }){
                              Text("CONNECT")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color("Tertiary"))
                            }
                          }
                          .frame(maxWidth: .infinity, alignment: .trailing)
                          .padding(.trailing, 5)
                        }
                        .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                      }
                      if(appleMusic.Subscription == AppleMusicSubscriptionStatus.notActive &&
                         appleMusic.CheckedForSubscription){
                        HStack{
                          ZStack{
                            Text("No Subscription")
                              .font(.system(size: 15, weight: .medium))
                              .foregroundColor(Color("Text"))
                          }.frame(alignment: .leading)
                          ZStack{
                            Button(action: {
                              Task{ appleMusic.CheckSubscription(completion: { _ in }) }
                            }){
                              Text("PURCHASE")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color("Tertiary"))
                            }
                          }
                          .frame(maxWidth: .infinity, alignment: .trailing)
                          .padding(.trailing, 5)
                        }
                        .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                      }
                    }
                    .padding(.leading, 10)
                  }
                }
                Divider()
                  .frame(width: UIScreen.main.bounds.size.width*0.9, height: 1.5)
                  .background(Color("LightGray").opacity(0.6))
              }
              
              // MARK: Playlist Info [Name, Passcode, Host, Music Service]
              VStack{
                HStack{
                  Button( action: { withAnimation(.easeInOut(duration: 0.4)){ ShowPlaylistDropDown.toggle() }}){
                    HStack(spacing: 7){
                      Image(systemName: "rectangle.grid.1x2.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color("Text"))
                        .frame(width: 30)
                        .padding(.leading, 10)
                      Text("Playlist Info")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color("Text"))
                    }
                    .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .leading)
                    if(ShowPlaylistDropDown){
                      Image(systemName: "chevron.down").foregroundColor(Color("Tertiary"))
                        .frame(width:UIScreen.main.bounds.size.width*0.2, alignment: .trailing)
                        .font(.system(size: 15, weight: .bold))
                    }
                    else{
                      Image(systemName: "chevron.right").foregroundColor(Color("Text"))
                        .frame(width:UIScreen.main.bounds.size.width*0.2, alignment: .trailing)
                        .font(.system(size: 15, weight: .medium))
                    }
                  }
                  
                }
                .frame(width: UIScreen.main.bounds.size.width*0.93, height: 30, alignment: .leading)
                if(ShowPlaylistDropDown){
                  VStack{
                    Text("Name")
                      .font(.system(size: 15, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                      .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                      .padding(.leading, 10)
                    Text(room.Name)
                      .lineLimit(1)
                      .font(.system(size: 15, weight: .medium))
                      .foregroundColor(Color("Text"))
                      .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                      .padding(.leading, 10)
                  }
                  .padding(.bottom, 5)
                  if(room.SharePermission || room.Creator(User: user)){
                    ZStack{
                      VStack{
                        Text("Passcode")
                          .font(.system(size: 15, weight: .bold))
                          .foregroundColor(Color("Tertiary"))
                          .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                        HStack{
                          ZStack{
                            Text(room.Passcode)
                              .font(.system(size: 15, weight: .medium))
                              .foregroundColor(Color("Text"))
                          }
                          .frame(alignment: .leading)
                          ZStack{
                            HStack{
                              Button(action: { Share = true }){
                                Text("INVITE")
                                  .font(.system(size: 12, weight: .bold))
                                  .foregroundColor(Color("Tertiary"))
                              }
                              if(room.Creator(User: user)){
                                Text("|")
                                  .font(.system(size: 12, weight: .bold))
                                  .foregroundColor(Color("Tertiary"))
                                Button(action: {
                                  let networkStatus: NetworkStatus = CheckNetworkStatus()
                                  if(networkStatus == NetworkStatus.reachable){
                                    withAnimation(.easeIn(duration: 0.2)){ ShowUpdateOverlay = true }
                                    Task{
                                      var valid_passcode = false
                                      repeat
                                      {
                                        room.Passcode = room.GeneratePasscode()
                                        valid_passcode = await FirebaseManager.isValidPasscode(Passcode: room.Passcode)
                                      }
                                      while(!valid_passcode)
                                            try await FirebaseManager.UpdatePasscode(Room: room)
                                    }
                                  }
                                  if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
                                }){
                                  Text("RESET")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color("Tertiary"))
                                }
                              }
                            }
                            .padding(.trailing, 5)
                          }
                          .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                      }
                      .padding(.leading, 10)
                    }
                    .padding(.bottom, 5)
                  }
                  VStack{
                    Text("Music Service")
                      .frame(width: UIScreen.main.bounds.width*0.9, alignment: .leading)
                      .font(.system(size: 15, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                      .padding(.leading, 10)
                    if(room.MusicService == "AppleMusic"){
                      Text("Apple Music")
                        .frame(width: UIScreen.main.bounds.width*0.9, alignment: .leading)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color("Text"))
                        .padding(.leading, 10)
                    }
                    else{
                      Text(room.MusicService)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color("Text"))
                    }
                  }
                }
                Divider()
                  .frame(width: UIScreen.main.bounds.size.width*0.9, height: 1.5)
                  .background(Color("LightGray").opacity(0.6))
              }
              
              // MARK: Appearance [Dark Theme]
              VStack{
                HStack{
                  Button(action: { withAnimation(.easeInOut(duration: 0.4)){ ShowAppearanceDropDown.toggle() }}){
                    HStack(spacing: 7){
                      Image(systemName: "eye.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color("Text"))
                        .frame(width: 30)
                        .padding(.leading, 10)
                      Text("Appearance")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color("Text"))
                    }
                    .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .leading)
                    if(ShowAppearanceDropDown){
                      Image(systemName: "chevron.down").foregroundColor(Color("Tertiary"))
                        .frame(width:UIScreen.main.bounds.size.width*0.2, alignment: .trailing)
                        .font(.system(size: 15, weight: .bold))
                    }
                    else{
                      Image(systemName: "chevron.right").foregroundColor(Color("Text"))
                        .frame(width:UIScreen.main.bounds.size.width*0.2, alignment: .trailing)
                        .font(.system(size: 15, weight: .medium))
                    }
                  }
                }
                .frame(width: UIScreen.main.bounds.size.width*0.93, height: 30, alignment: .leading)
                if(ShowAppearanceDropDown){
                  HStack{
                    ZStack(alignment: .bottom){
                      Text("Dark Mode")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color("Tertiary"))
                    }
                    .padding(.leading, 5)
                    ZStack{
                      if(!isDarkMode){
                        Button(action: { isDarkMode = true }){
                          Text("OFF")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color("Tertiary"))
                        }
                        .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
                        .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
                      }
                      if(isDarkMode){
                        Button(action: { isDarkMode = false }){
                          Text("ON")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color("Label"))
                        }
                        .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
                        .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")).shadow(color: Color("Tertiary"), radius: 1))
                      }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                  .padding(.bottom, 5)
                  .padding(.top, 5)
                }
                if(room.Creator(User: user) || room.Host(User: user)){
                  Divider()
                    .frame(width: UIScreen.main.bounds.size.width*0.9, height: 1.5)
                    .background(Color("LightGray").opacity(0.6))
                }
              }
              
              // MARK: Playlist Permissions [Play/Pause, Skip, Remove, Vote]
              if(room.Creator(User: user) || room.Host(User: user)){
                VStack{
                  HStack{
                    Button(action: { withAnimation(.easeInOut(duration: 0.4)){ ShowSharedControlsDropDown.toggle() }}){
                      HStack(spacing: 7){
                        Image(systemName: "slider.horizontal.3")
                          .font(.system(size: 20, weight: .bold))
                          .foregroundColor(Color("Text"))
                          .frame(width: 30)
                          .padding(.leading, 10)
                        Text("Shared Controls")
                          .font(.system(size: 20, weight: .bold))
                          .foregroundColor(Color("Text"))
                      }
                      .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .leading)
                      if(ShowSharedControlsDropDown){
                        Image(systemName: "chevron.down").foregroundColor(Color("Tertiary"))
                          .font(.system(size: 15, weight: .bold))
                          .frame(width:UIScreen.main.bounds.size.width*0.2, alignment: .trailing)
                          .font(.system(size: 15, weight: .bold))
                      }
                      else{
                        Image(systemName: "chevron.right").foregroundColor(Color("Text"))
                          .frame(width:UIScreen.main.bounds.size.width*0.2, alignment: .trailing)
                          .font(.system(size: 15, weight: .medium))
                      }
                    }
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.93,  height: 30, alignment: .leading)
                  if(ShowSharedControlsDropDown){
                    VStack(spacing: 10){
                      HStack{
                        ZStack(alignment: .bottom){
                          Text("Play/Pause")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color("Tertiary"))
                            .frame(width: UIScreen.main.bounds.size.width*0.5, height: 25, alignment: .leading)
                        }
                        .padding(.leading, 5)
                        ZStack{
                          if(!room.PlayPausePermission){
                            Button(action: {
                              let networkStatus: NetworkStatus = CheckNetworkStatus()
                              if(networkStatus == NetworkStatus.reachable){
                                room.PlayPausePermission = true
                                ShowPlayPauseEnabledOverlay = true
                                Task{  try await FirebaseManager.UpdatePlayPausePermission(Room: room) }
                              }
                              if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
                            }){
                              Text("OFF")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color("Tertiary"))
                            }
                            .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
                            .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
                          }
                          if(room.PlayPausePermission){
                            Button(action: {
                              let networkStatus: NetworkStatus = CheckNetworkStatus()
                              if(networkStatus == NetworkStatus.reachable){
                                room.PlayPausePermission = false
                                Task{ try await FirebaseManager.UpdatePlayPausePermission(Room: room) }
                              }
                              if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
                            }){
                              Text("ON")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color("Label"))
                            }
                            .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
                            .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")).shadow(color: Color("Tertiary"), radius: 1))
                          }
                        }.frame(maxWidth: .infinity, alignment: .trailing)
                      }
                      .frame(width: UIScreen.main.bounds.width*0.9, alignment: .leading)
                      HStack{
                        ZStack(alignment: .bottom){
                          Text("Skip")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color("Tertiary"))
                            .frame(width: UIScreen.main.bounds.size.width*0.5, height: 25, alignment: .leading)
                        }
                        .padding(.leading, 5)
                        ZStack{
                          if(!room.SkipPermission){
                            Button(action: {
                              let networkStatus: NetworkStatus = CheckNetworkStatus()
                              if(networkStatus == NetworkStatus.reachable){
                                room.SkipPermission = true
                                ShowSkipEnabledOverlay = true
                                Task{ try await FirebaseManager.UpdateSkipPermission(Room: room) }
                              }
                              if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
                            }){
                              Text("OFF")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color("Tertiary"))
                            }
                            .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
                            .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
                          }
                          if(room.SkipPermission){
                            Button(action: {
                              let networkStatus: NetworkStatus = CheckNetworkStatus()
                              if(networkStatus == NetworkStatus.reachable){
                                room.SkipPermission = false
                                Task{ try await FirebaseManager.UpdateSkipPermission(Room: room) }
                              }
                              if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
                            }){
                              Text("ON")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color("Label"))
                            }
                            .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
                            .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")).shadow(color: Color("Tertiary"), radius: 1))
                          }
                        }.frame(maxWidth: .infinity, alignment: .trailing)
                      }
                      .frame(width: UIScreen.main.bounds.width*0.9, alignment: .leading)
                      HStack{
                        ZStack(alignment: .bottom){
                          Text("Remove")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color("Tertiary"))
                            .frame(width: UIScreen.main.bounds.size.width*0.5, height: 25, alignment: .leading)
                        }
                        .padding(.leading, 5)
                        ZStack{
                          if(!room.RemovePermission){
                            Button(action: {
                              let networkStatus: NetworkStatus = CheckNetworkStatus()
                              if(networkStatus == NetworkStatus.reachable){
                                room.RemovePermission = true
                                ShowRemoveEnabledOverlay = true
                                Task{try await FirebaseManager.UpdateRemovePermission(Room: room) }
                              }
                              if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
                            }){
                              Text("OFF")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color("Tertiary"))
                            }
                            .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
                            .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
                          }
                          if(room.RemovePermission){
                            Button(action: {
                              let networkStatus: NetworkStatus = CheckNetworkStatus()
                              if(networkStatus == NetworkStatus.reachable){
                                room.RemovePermission = false
                                Task{ try await FirebaseManager.UpdateRemovePermission(Room: room) }
                              }
                              if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
                            }){
                              Text("ON")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color("Label"))
                            }
                            .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
                            .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")).shadow(color: Color("Tertiary"), radius: 1))
                          }
                        }.frame(maxWidth: .infinity, alignment: .trailing)
                      }
                      .frame(width: UIScreen.main.bounds.width*0.9, alignment: .leading)
                      HStack{
                        ZStack(alignment: .bottom){
                          Text("Vote")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color("Tertiary"))
                            .frame(width: UIScreen.main.bounds.size.width*0.5, height: 25, alignment: .leading)
                        }
                        .padding(.leading, 5)
                        ZStack{
                          if(!room.VoteModePermission){
                            Button(action: {
                              let networkStatus: NetworkStatus = CheckNetworkStatus()
                              if(networkStatus == NetworkStatus.reachable){
                                if(room.Playlist.Queue.count >= 100){ ShowMaxSongsOverlay = true }
                                else{
                                  room.VoteModePermission = true
                                  ShowVoteEnabledOverlay = true
                                  Task{  try await FirebaseManager.UpdateVoteModePermission(Room: room) }
                                }
                              }
                              if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
                            }){
                              Text("OFF")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color("Tertiary"))
                            }
                            .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
                            .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
                          }
                          if(room.VoteModePermission){
                            Button(action: {
                              let networkStatus: NetworkStatus = CheckNetworkStatus()
                              if(networkStatus == NetworkStatus.reachable){
                                room.VoteModePermission = false
                                Task{ try await FirebaseManager.UpdateVoteModePermission(Room: room) }
                              }
                              if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
                            }){
                              Text("ON")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color("Label"))
                            }
                            .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
                            .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")).shadow(color: Color("Tertiary"), radius: 1))
                          }
                        }.frame(maxWidth: .infinity, alignment: .trailing)
                      }
                      .frame(width: UIScreen.main.bounds.width*0.9, alignment: .leading)
                    }
                  }
                }
              }
              
              // MARK: Close/Leave Playlist Button [Users w/ Account]
              ZStack{
                if(!user.pai.isEmpty){
                  Button(action: {
                    Task{
                      user.InRoom = false
                      try await FirebaseManager.UpdateUserInRoom(User: user, Room: room)
                      if let userAccount: AuxrAccount = user.Account{
                        let stored = try await user.StoreChannelLikesVotes(User: user, Account: userAccount, Room: room)
                        if(stored){
                          if(room.Host(User: user)){
                            if(room.PlaySong){
                              room.PlaySong = false
                              try await FirebaseManager.UpdateRoomPlaySong(Room: room)
                            }
                          }
                          try await room.ChannelDisconnect(User: user, AppleMusic: appleMusic)
                          navigated = true
                        }
                      }
                      else{ try await room.Disconnect(User: user, AppleMusic: appleMusic, Router: router) } }
                  }){
                    Text("Disconnect")
                      .font(.system(size: 18, weight: .bold))
                      .foregroundColor(Color("Red"))
                      .frame(width: UIScreen.main.bounds.size.width*0.5, height: 25)
                      .padding(.top, 20)
                  }
                }
                
                // MARK: Close/Leave Playlist Button [Users w/o Account]
                if(user.pai.isEmpty){
                  Button(action: {
                    Task{ try await room.Disconnect(User: user, AppleMusic: appleMusic, Router: router) }
                  }){
                    Text(room.Creator(User: user) ? "Close Playlist" : "Leave Playlist")
                      .font(.system(size: 18, weight: .bold))
                      .foregroundColor(Color("Red"))
                      .frame(width: UIScreen.main.bounds.size.width*0.5, height: 25)
                      .padding(.top, 20)
                  }
                }
                
                if(navigated){
                  NavigationLink(value: router.account){ EmptyView() }
                    .onAppear{
                      appleMusic.UserRecommended.GeneratingRandom = false
                      appleMusic.UserRecommended.GeneratingSimilar = false
                      router.currPath = router.account.path
                      room.InFirstTime = true
                      completed = true
                    }
                    .navigationDestination(isPresented: $completed){
                      if let userAccount: AuxrAccount = user.Account{
                        AccountView().environmentObject(userAccount)
                      }
                    }
                }
              }
            }
          }
        }
      }
      
    }
    .popover(isPresented: $ShowFriendPopover){
      if let account: AuxrAccount = user.Account{
        FriendInvitePopover(RoomID: room.ID, Show: $ShowFriendPopover, ShowOtherOptions: $OtherShareOptions, ShowShareOverlay: $Share).environmentObject(account)
          .onAppear{ Share = false }
      }
    }
    .colorScheme(isDarkMode ? .dark : .light)
    .navigationBarHidden(true)
    // MARK: Handle Settings scenePhase Change
    .onChange(of: scenePhase){ phase in
      room.ScenePhaseHandler(phase: phase, User: user, AppleMusic: appleMusic)
    }
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
