import SwiftUI
import MusicKit

struct SubSearchView: View {
  @Environment(\.scenePhase) var scenePhase
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  let srch: Search = Search()
  
  @Binding var Show: Bool
  @Binding var StartSearch: Bool
  @Binding var Input: String
  @Binding var Filter: SearchFilter
  @Binding var Searching: Bool
  @Binding var Completed: Bool
  @Binding var Queued: Bool
  @Binding var MaxSongs: Bool
  @Binding var Offline: Bool
  
  @State private var Loading: Bool = false
  @State private var ShowRecentlySearchedDropDown: Bool = false
  @State private var ShowPlaylistDropDown: Bool = false
  @State private var ShowAccountLikesDropDown: Bool = false
  @State private var ShowRecommendedDropDown: Bool = false
  @State private var GeneratingSongs: Bool = false
  
  var body: some View {
    ZStack{
      if(room.MusicService == "AppleMusic"){
        VStack{
          VStack{
            HStack{
              Button(action: {
                withAnimation(.easeOut(duration: (!ShowRecentlySearchedDropDown || !appleMusic.RecentSearches.isEmpty) ? 0.4 : 0.0)){ ShowRecentlySearchedDropDown.toggle() }
                ShowRecommendedDropDown = false
                ShowAccountLikesDropDown = false
                ShowPlaylistDropDown = false
                UIApplication.shared.dismissKeyboard()
              }){
                HStack(spacing: 7){
                  Image(systemName: "clock.fill")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("Text"))
                  Text("Recently Searched")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .leading)
                .padding(.leading, 3)
                if(!ShowRecentlySearchedDropDown){
                  ZStack{
                    Image(systemName: "chevron.right").foregroundColor(Color("Text"))
                      .font(.system(size: 13, weight: .bold))
                  }
                  .frame(width:UIScreen.main.bounds.size.width*0.18, alignment: .trailing)
                  .offset(x: -10)
                }
                else{
                  ZStack{
                    Image(systemName: "chevron.down").foregroundColor(Color("Tertiary"))
                      .font(.system(size: 13, weight: .bold))
                  }
                  .frame(width:UIScreen.main.bounds.size.width*0.18, alignment: .trailing)
                  .offset(x: -10)
                }
              }
            }
            .frame(width: UIScreen.main.bounds.size.width*0.9, height: 30, alignment: .leading)
            if(ShowRecentlySearchedDropDown){
              if(appleMusic.RecentSearches.isEmpty){
                ZStack{
                  Text("No Recently Searched")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("Text"))
                    .frame(width: UIScreen.main.bounds.size.width*0.8)
                    .padding(10)
                }
              }
              else{
                VStack(spacing: 5){
                  ZStack{
                    VStack(spacing: 5){
                      // MARK: Display Most Recent Searches
                      ForEach(appleMusic.RecentSearches.reversed(), id: \.self){ search in
                        HStack{
                          Button(action: {
                            let networkStatus: NetworkStatus = CheckNetworkStatus()
                            if(networkStatus == NetworkStatus.reachable){
                              StartSearch = true
                              UIApplication.shared.dismissKeyboard()
                              Completed = false
                              Searching = true
                              Input = search
                              srch.Reset(Room: room, AppleMusic: appleMusic)
                              Task{ try await srch.SearchMusic(Room: room, AppleMusic: appleMusic, Input: Input, Filter: Filter) }
                              Show = false
                            }
                            if(networkStatus == NetworkStatus.notConnected){ Offline = true }
                          }){
                            ZStack{
                              Text(search).lineLimit(1)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color("Text"))
                            }
                            .frame(width: UIScreen.main.bounds.size.width*0.75, alignment: .leading)
                            .padding(5)
                          }
                          Button(action: { withAnimation(.easeOut(duration: 0.2)){ appleMusic.RecentSearches = appleMusic.RecentSearches.filter{ $0 != search } }}){
                            ZStack{
                              Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color("Tertiary"))
                            }
                          }
                        }
                        .frame(width: UIScreen.main.bounds.size.width*0.82, alignment: .leading)
                      }
                    }
                  }
                  ZStack{
                    Button(action: { withAnimation(.easeOut(duration: 0.2)){ appleMusic.RecentSearches = [] }}){
                      Text("Clear")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color("Red"))
                    }
                  }
                }
                .frame(width: UIScreen.main.bounds.size.width*0.82, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).opacity(0.0))
              }
            }
            Divider()
              .frame(width: UIScreen.main.bounds.size.width*0.9, height: 1.5)
              .background(Color("LightGray").opacity(0.6))
          }
          VStack{
            HStack{
              Button(action: {
                withAnimation(.easeOut(duration: !ShowPlaylistDropDown ? 0.4 : 0.0)){ ShowPlaylistDropDown.toggle() }
                ShowRecommendedDropDown = false
                ShowAccountLikesDropDown = false
                ShowRecentlySearchedDropDown = false
                UIApplication.shared.dismissKeyboard()
              }){
                HStack(spacing: 7){
                  Image(systemName: "music.note.list")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("Text"))
                  Text("My Playlists")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .leading)
                .padding(.leading, 3)
                if(!ShowPlaylistDropDown){
                  ZStack{
                    Image(systemName: "chevron.right").foregroundColor(Color("Text"))
                      .font(.system(size: 13, weight: .bold))
                  }
                  .frame(width:UIScreen.main.bounds.size.width*0.18, alignment: .trailing)
                  .offset(x: -10)
                }
                else{
                  ZStack{
                    Image(systemName: "chevron.down").foregroundColor(Color("Tertiary"))
                      .font(.system(size: 13, weight: .bold))
                  }
                  .frame(width:UIScreen.main.bounds.size.width*0.18, alignment: .trailing)
                  .offset(x: -10)
                }
              }
            }
            .frame(width: UIScreen.main.bounds.size.width*0.9, height: 30, alignment: .leading)
            if(ShowPlaylistDropDown){
              if(appleMusic.Subscription == AppleMusicSubscriptionStatus.active){
                if(appleMusic.UserLibraryPlaylists.isEmpty){
                  ZStack{
                    Text("No Playlists Found")
                      .font(.system(size: 12, weight: .medium))
                      .foregroundColor(Color("Text"))
                      .frame(width: UIScreen.main.bounds.size.width*0.8)
                      .padding(10)
                  }
                }
                else{
                  ZStack{
                    // MARK: Display User Playlists
                    ScrollView(showsIndicators: false){
                      VStack(spacing: 11){
                        ForEach(appleMusic.UserLibraryPlaylists){ playlist in
                          NavigationLink(destination: AppleMusicUserPlaylistView(Playlist: playlist, Loading: $Loading)){
                            HStack(spacing: 7){
                              ZStack{
                                if let PlaylistArtwork = playlist.Art?.image(at: CGSize(width: UIScreen.main.bounds.size.height*0.06, height: UIScreen.main.bounds.size.height*0.06)){
                                  Image(uiImage: PlaylistArtwork)
                                    .resizable()
                                    .frame(width: UIScreen.main.bounds.size.height*0.06, height: UIScreen.main.bounds.size.height*0.06)
                                }
                                else{
                                  Image(systemName: "music.note")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color("Tertiary"))
                                    .frame(width: UIScreen.main.bounds.size.height*0.06, height: UIScreen.main.bounds.size.height*0.06)
                                    .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
                                }
                              }
                              .padding(5)
                              ZStack{
                                Text(playlist.Title).lineLimit(1)
                                  .font(.system(size: 15, weight: .medium))
                                  .foregroundColor(Color("Text"))
                              }
                              .frame(width: UIScreen.main.bounds.size.width*0.6, alignment: .leading)
                            }
                            .frame(width: UIScreen.main.bounds.size.width*0.82, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
                          }
                        }
                      }
                    }
                  }
                  .frame(maxHeight: UIScreen.main.bounds.size.height*0.33, alignment: .center)
                }
              }
              else{
                ZStack{
                  VStack{
                    if(appleMusic.Subscription == AppleMusicSubscriptionStatus.notChecked || appleMusic.Subscription == AppleMusicSubscriptionStatus.notActive)
                    {
                      HStack{
                        Text("Connect Apple Music to view your playlists")
                          .font(.system(size: 14, weight: .medium))
                          .foregroundColor(Color("Text"))
                          .frame(width: UIScreen.main.bounds.size.width*0.8, alignment: .center)
                      }
                      .frame(width:  UIScreen.main.bounds.size.width*0.9, height: 15, alignment: .center)
                      Button(action: {
                        Task{
                          appleMusic.CheckSubscription(completion: { _ in })
                          try await appleMusic.GetUserPlaylists()
                        }
                      }){
                        HStack{
                          ZStack{
                            Text("CONNECT")
                              .font(.system(size: 14, weight: .bold))
                              .foregroundColor(Color("Label"))
                          }
                          .padding(5)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")).shadow(color: Color("Shadow"), radius: 1))
                        }
                        .frame(width:  UIScreen.main.bounds.size.width*0.9, height: 40, alignment: .center)
                      }
                    }
                    else{
                      VStack(spacing: 5){
                        Text("Subscribe To Apple Music")
                          .font(.system(size: 14, weight: .medium))
                          .foregroundColor(Color("Text"))
                          .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .center)
                        Button(action: { Task{ appleMusic.CheckSubscription(completion: { _ in }) } }){
                          ZStack{
                            Text("PURCHASE")
                              .font(.system(size: 14, weight: .medium))
                              .foregroundColor(Color("Label"))
                          }
                          .padding(5)
                          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")))
                        }
                      }
                      .padding(5)
                    }
                  }
                }
              }
            }
            Divider()
              .frame(width: UIScreen.main.bounds.size.width*0.9, height: 1.5)
              .background(Color("LightGray").opacity(0.6))
          }
          if(!user.pai.isEmpty){
            VStack{
              HStack{
                Button(action: {
                  withAnimation(.easeOut(duration: !ShowAccountLikesDropDown ? 0.4 : 0.0)){ ShowAccountLikesDropDown.toggle() }
                  Completed = false
                  ShowRecommendedDropDown = false
                  ShowPlaylistDropDown = false
                  ShowRecentlySearchedDropDown = false
                  UIApplication.shared.dismissKeyboard()
                }){
                  HStack(spacing: 7){
                    Image(systemName: "heart.fill")
                      .font(.system(size: 15, weight: .bold))
                      .foregroundColor(Color("Text"))
                    Text("My Likes")
                      .font(.system(size: 15, weight: .bold))
                      .foregroundColor(Color("Text"))
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .leading)
                  .padding(.leading, 3)
                  if(!ShowAccountLikesDropDown){
                    ZStack{
                      Image(systemName: "chevron.right").foregroundColor(Color("Text"))
                        .font(.system(size: 13, weight: .bold))
                    }
                    .frame(width:UIScreen.main.bounds.size.width*0.18, alignment: .trailing)
                    .offset(x: -10)
                  }
                  else{
                    ZStack{
                      Image(systemName: "chevron.down").foregroundColor(Color("Tertiary"))
                        .font(.system(size: 13, weight: .bold))
                    }
                    .frame(width:UIScreen.main.bounds.size.width*0.18, alignment: .trailing)
                    .offset(x: -10)
                  }
                }
              }
              .frame(width: UIScreen.main.bounds.size.width*0.9, height: 30, alignment: .leading)
              
              if(ShowAccountLikesDropDown){
                if(appleMusic.AccountLikes.isEmpty){
                  ZStack{
                    Text("No Likes Found")
                      .font(.system(size: 12, weight: .medium))
                      .foregroundColor(Color("Text"))
                      .frame(width: UIScreen.main.bounds.size.width*0.8)
                      .padding(10)
                  }
                }
                else{
                  ZStack{
                    ScrollView(showsIndicators: false){
                      Spacer().frame(height: 1)
                      VStack(spacing: 11){
                        ForEach(appleMusic.AccountLikes){ song in
                          AppleMusicSongCell(Song: song, Queued: $Queued, MaxSongs: $MaxSongs, Offline: $Offline)
                        }
                      }
                    }
                    .frame(maxHeight: UIScreen.main.bounds.size.height*0.4)
                  }
                  .frame(maxHeight: UIScreen.main.bounds.size.height*0.4)
                }
              }
              Divider()
                .frame(width: UIScreen.main.bounds.size.width*0.9, height: 1.5)
                .background(Color("LightGray").opacity(0.6))
            }
          }
          HStack{
            Button(action: {
              withAnimation(.easeOut(duration: !ShowRecommendedDropDown ? 0.4 : 0.0)){ ShowRecommendedDropDown.toggle() }
              ShowAccountLikesDropDown = false
              ShowPlaylistDropDown = false
              ShowRecentlySearchedDropDown = false
              UIApplication.shared.dismissKeyboard()
            }){
              ZStack{
                Text("Recommended For You")
                  .font(.system(size: 15, weight: .bold))
                  .foregroundColor(Color("Text"))
              }
              .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .leading)
              .padding(.leading, 3)
              if(!ShowRecommendedDropDown){
                ZStack{
                  Image(systemName: "chevron.right").foregroundColor(Color("Text"))
                    .font(.system(size: 13, weight: .bold))
                }
                .frame(width:UIScreen.main.bounds.size.width*0.18, alignment: .trailing)
                .offset(x: -10)
              }
              else{
                ZStack{
                  Image(systemName: "chevron.down").foregroundColor(Color("Tertiary"))
                    .font(.system(size: 13, weight: .bold))
                }
                .frame(width:UIScreen.main.bounds.size.width*0.18, alignment: .trailing)
                .offset(x: -10)
              }
            }
          }
          .frame(width: UIScreen.main.bounds.size.width*0.9, height: 30, alignment: .leading)
          if(ShowRecommendedDropDown){
            if(!Completed){
              SearchLoaderView(Searching: $appleMusic.UserRecommended.GeneratingRandom, Completed: $Completed, length: 0.35)
                .frame(height: 10)
              ZStack{
                Text("Finding the best songs for you...")
                  .font(.system(size: 13, weight: .medium))
                  .foregroundColor(Color("Text"))
              }
              .frame(alignment: .center)
            }
            if(!appleMusic.UserRecommended.GeneratingRandom){
              ZStack{
                ScrollView(showsIndicators: false){
                  Spacer().frame(height: 1)
                  VStack(spacing: 11){
                    ForEach(appleMusic.UserRecommended.Songs.prefix(3)){ song in
                      AppleMusicSongCell(Song: song, Queued: $Queued, MaxSongs: $MaxSongs, Offline: $Offline)
                    }
                    ZStack{
                      Button(action: {
                        Completed = false
                        appleMusic.UserRecommended.GeneratingRandom = true
                        guard (appleMusic.UserRecommended.GeneratingRandom) else{ return }
                        Task{ try await appleMusic.GenerateRandomSongs(User: user, Room: room, howMany: 3) }
                        if(appleMusic.UserRecommended.Songs.count >= 3){ appleMusic.UserRecommended.Songs.removeFirst(3) }
                      }){
                        Text("Refresh")
                          .font(.system(size: 13, weight: .medium))
                          .foregroundColor(Color("Tertiary"))
                      }
                    }
                  }
                }
              }
              .frame(height: UIScreen.main.bounds.size.height*0.4)
            }
          }
        }
      }
      ZStack{
        Button(action: { Show = false }){
          Text("Tap To Dismiss")
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(Color("Capsule").opacity(0.6))
        }
      }
      .offset(y: UIScreen.main.bounds.size.height*0.33)
    }
    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.5, alignment: .top)
    .zIndex(2)
    .ignoresSafeArea(.keyboard, edges: .all)
  }
}
