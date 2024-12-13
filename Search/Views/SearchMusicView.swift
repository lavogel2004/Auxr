import SwiftUI

struct SearchMusicView: View {
  @AppStorage("isDarkMode") private var isDarkMode = false
  
  @Environment(\.presentationMode) var Presentation
  @Environment(\.scenePhase) var scenePhase
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  let srch: Search = Search()
  
  @Binding var StartSearch: Bool
  @Binding var SearchInput: String
  @Binding var Filter: SearchFilter
  @Binding var Searching: Bool
  @Binding var Completed: Bool
  @Binding var ShowCurrentSong: Bool
  
  @State private var ShowSubSearch: Bool = false
  @State private var ShowOfflineOverlay: Bool = false
  @State private var ShowQueuedOverlay: Bool = false
  @State private var ShowMaxSongsOverlay: Bool = false
  @State private var noop: Bool = false
  
  var body: some View {
    ZStack{
      Color("Primary").edgesIgnoringSafeArea(.all)
      
      if(ShowQueuedOverlay){ GeneralOverlay(type: GeneralOverlayType.queued, Show: $ShowQueuedOverlay) }
      if(ShowOfflineOverlay){ OfflineOverlay(networkStatus: NetworkStatus.notConnected, Show: $ShowOfflineOverlay) }
      else if(ShowMaxSongsOverlay){ GeneralOverlay(type: GeneralOverlayType.maxSongs, Show: $ShowMaxSongsOverlay) }
      
      HStack(alignment: .top){
        Button(action: {
          srch.Reset(Room: room, AppleMusic: appleMusic)
          SearchInput = ""
          Presentation.wrappedValue.dismiss()
        }){
          Image(systemName: "chevron.left")
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(Color("Tertiary"))
            .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .leading)
            .padding(.leading, 10)
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.95, alignment: .topLeading)
      .offset(y: -UIScreen.main.bounds.size.height/2*0.85)
      
      Spacer()
      VStack{
        // MARK: Search Bar
        SearchBarView(Input: $SearchInput, Filter: $Filter)
          .onSubmit{
            ShowSubSearch = false
            let networkStatus: NetworkStatus = CheckNetworkStatus()
            if(networkStatus == NetworkStatus.reachable){
              Task{
                Searching = true
                Completed = false
                srch.Reset(Room: room, AppleMusic: appleMusic)
                try await srch.SearchMusic(Room: room, AppleMusic: appleMusic, Input: SearchInput, Filter: Filter)
                if(!SearchInput.isEmpty){
                  if(room.MusicService == "AppleMusic"){
                    if(!appleMusic.RecentSearches.contains(SearchInput)){
                      appleMusic.RecentSearches.append(SearchInput)
                      if(appleMusic.RecentSearches.count > 6){ appleMusic.RecentSearches.removeFirst() }
                    }
                  }
                }
              }
            }
            if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
          }
          .onTapGesture{
            withAnimation(.easeInOut(duration: 0.2)){ srch.Reset(Room: room, AppleMusic: appleMusic) }
            ShowSubSearch = true
          }
          .disabled(Searching)
        
        // MARK: Search Filter Picker
        HStack(spacing: 5){
          Button(action: {
            withAnimation(.easeInOut(duration: 0.2)){
              UIApplication.shared.dismissKeyboard()
              Filter = SearchFilter.songs
            }
          }){
            if(Filter == SearchFilter.songs){
              ZStack{
                ZStack{
                  Text("Songs")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("Label"))
                }
                .padding(3)
              }
              .frame(width: UIScreen.main.bounds.size.width*0.241, height: UIScreen.main.bounds.size.height*0.031)
              .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")))
            }
            else{
              ZStack{
                ZStack{
                  Text("Songs")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("Text"))
                }
                .padding(3)
              }
              .frame(width: UIScreen.main.bounds.size.width*0.24, height: UIScreen.main.bounds.size.height*0.03)
              .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
            }
          }
          Button(action: {
            withAnimation(.easeInOut(duration: 0.2)){
              UIApplication.shared.dismissKeyboard()
              Filter = SearchFilter.albums
            }
          }){
            if(Filter == SearchFilter.albums){
              ZStack{
                ZStack{
                  Text("Albums")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("Label"))
                }
                .padding(3)
              }
              .frame(width: UIScreen.main.bounds.size.width*0.241, height: UIScreen.main.bounds.size.height*0.031)
              .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")))
            }
            else{
              ZStack{
                ZStack{
                  Text("Albums")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("Text"))
                }
                .padding(3)
              }
              .frame(width: UIScreen.main.bounds.size.width*0.24, height: UIScreen.main.bounds.size.height*0.03)
              .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
            }
            
          }
        }
        .frame(width: UIScreen.main.bounds.size.width*0.5, height: UIScreen.main.bounds.size.height*0.04)
        .padding(10)
        .disabled(Searching)
        
        if(Searching){ SearchLoaderView(Searching: $Searching, Completed: $Completed, length: 0.35) }
        
        // MARK: Search Results
        if(Completed && !ShowSubSearch){
          switch(Filter){
          case SearchFilter.songs:
            SongsSearchView(Filter: $Filter, Input: $SearchInput, Queued: $ShowQueuedOverlay, MaxSongs: $ShowMaxSongsOverlay, Offline: $ShowOfflineOverlay)
              .onAppear{
                let networkStatus: NetworkStatus = CheckNetworkStatus()
                if(networkStatus == NetworkStatus.reachable){
                  Task{ try await srch.SearchMusic(Room: room, AppleMusic: appleMusic, Input: SearchInput, Filter: Filter) }
                }
                if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
              }
          case SearchFilter.albums:
            AlbumsSearchView(Filter: $Filter, Input: $SearchInput)
              .onAppear{
                let networkStatus: NetworkStatus = CheckNetworkStatus()
                if(networkStatus == NetworkStatus.reachable){
                  Task{ try await srch.SearchMusic(Room: room, AppleMusic: appleMusic, Input: SearchInput, Filter: Filter) }
                }
                if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
              }
          case SearchFilter.artists:
            EmptyView()
          }
        }
      }
      .frame(maxHeight: UIScreen.main.bounds.size.height*0.73, alignment: .top)
      
      // MARK: User Recent Search
      if(room.MusicService == "AppleMusic"){
        if(ShowSubSearch && !Searching){
          ZStack{
            SubSearchView(Show: $ShowSubSearch, StartSearch: $StartSearch, Input: $SearchInput, Filter: $Filter, Searching: $Searching, Completed: $Completed, Queued: $ShowQueuedOverlay, MaxSongs: $ShowMaxSongsOverlay, Offline: $ShowOfflineOverlay)
          }
        }
      }
    }
    .ignoresSafeArea(.keyboard, edges: .all)
    .navigationBarHidden(true)
    .colorScheme(isDarkMode ? .dark : .light)
    .onAppear{ ShowCurrentSong = false }
    // MARK: Handle Search scenePhase Changes
    .onChange(of: scenePhase){ phase in
      room.ScenePhaseHandler(phase: phase, User: user, AppleMusic: appleMusic)
    }
    .onTapGesture{
      UIApplication.shared.dismissKeyboard()
      if(!SearchInput.isEmpty && ShowSubSearch){
        ShowSubSearch = false
        Searching = true
        Completed = false
        Task{ try await srch.SearchMusic(Room: room, AppleMusic: appleMusic, Input: SearchInput, Filter: Filter) }
      }
    }
    .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .global)
      .onEnded { position in
        let HorizontalDrag = position.translation.width
        let VerticalDrag = position.translation.height
        if(abs(HorizontalDrag) > abs(VerticalDrag)){
          if(HorizontalDrag > 0){
            srch.Reset(Room: room, AppleMusic: appleMusic)
            SearchInput = ""
            Presentation.wrappedValue.dismiss()
          }
        }
      })
  }
}
