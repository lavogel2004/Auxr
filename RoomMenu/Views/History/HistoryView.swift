import SwiftUI

struct HistoryView: View {
  @Environment(\.presentationMode) var Presentation
  @Environment(\.scenePhase) var scenePhase
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  @State private var ShowOfflineOverlay: Bool = false
  @State private var ShowInfoOverlay: Bool = false
  @State private var ShowQueuedOverlay: Bool = false
  @State private var ShowLikeOverlay: Bool = false
  @State private var ShowMaxSongsOverlay: Bool = false
  
  var body: some View {
    ZStack{
      Color("Primary").edgesIgnoringSafeArea(.all)
      
      if(ShowOfflineOverlay){ OfflineOverlay(networkStatus: NetworkStatus.notConnected, Show: $ShowOfflineOverlay) }
      if(ShowInfoOverlay){ RoomFeatureInfoOverlay(feature: FeatureViews.history, Show: $ShowInfoOverlay) }
      if(ShowQueuedOverlay){ GeneralOverlay(type: GeneralOverlayType.queued, Show: $ShowQueuedOverlay) }
      else if(ShowLikeOverlay){ GeneralOverlay(type: GeneralOverlayType.like, Show: $ShowLikeOverlay) }
      else if(ShowMaxSongsOverlay){ GeneralOverlay(type: GeneralOverlayType.maxSongs, Show: $ShowMaxSongsOverlay)}
      
      ZStack{
        ZStack{
          HStack(spacing: 3){
            ZStack{
              Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color("Text"))
            }
            .frame(width: 25, alignment: .trailing)
            Text("History")
              .font(.system(size: 18, weight: .semibold))
              .foregroundColor(Color("Text"))
          }
          .padding(3)
        }
        .frame(alignment: .leading)
        .padding(10)
      }
      .frame(width: UIScreen.main.bounds.size.width*0.95, alignment: .topTrailing)
      .offset(y: -UIScreen.main.bounds.size.height/2*0.75)
      
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
      
      if(room.Playlist.History.isEmpty){
        ZStack{
          VStack(spacing: 2){
            HStack(spacing: 4){
              Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Capsule").opacity(0.6))
              Text("No History")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Capsule").opacity(0.6))
            }
            Text("Previously played songs")
              .font(.system(size: 11, weight: .medium))
              .foregroundColor(Color("Capsule").opacity(0.6))
          }
        }
        .frame(height: UIScreen.main.bounds.size.height, alignment: .center)
      }
      
      // MARK: History Scroll View
      VStack(spacing: 11){
        if(!room.Playlist.History.isEmpty){
          VStack{
            ZStack{
              Spacer()
              ScrollView(showsIndicators: false){
                VStack(alignment: .center, spacing: 11){
                  ForEach(Array(Set(room.Playlist.History)).sorted()){ song in
                    if(room.MusicService == "AppleMusic"){
                      AppleMusicHistoryCell(Song: song, Queued: $ShowQueuedOverlay, Like: $ShowLikeOverlay, MaxSongs: $ShowMaxSongsOverlay, Offline: $ShowOfflineOverlay)
                    }
                  }
                  if(room.Playlist.History.count > 7){ Spacer().frame(width: 1, height: UIScreen.main.bounds.size.height*0.02) }
                }
                .frame(width: UIScreen.main.bounds.size.width)
              }
            }
          }
          .frame(height: UIScreen.main.bounds.size.height*0.8, alignment: .bottom)
        }
      }
      .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.68, alignment: .top)
      
    }
    .navigationBarHidden(true)
    // MARK: Handle History scenePhase Change
    .onChange(of: scenePhase){ phase in
      room.ScenePhaseHandler(phase: phase, User: user, AppleMusic: appleMusic)
    }
    .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .global)
      .onEnded{ position in
        let HorizontalDrag = position.translation.width
        let VerticalDrag = position.translation.height
        if(abs(HorizontalDrag) > abs(VerticalDrag)){
          if(HorizontalDrag > 0){ Presentation.wrappedValue.dismiss() }
        }
      })
  }
}
