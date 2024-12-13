import SwiftUI
import MusicKit

struct SimilarSongsView: View {
  @Environment(\.presentationMode) var Presentation
  @Environment(\.scenePhase) var scenePhase
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  @Binding var Song: AuxrSong
  @Binding var Show: Bool
  @Binding var ShowCurrentSong: Bool
  
  @State private var ShowQueuedOverlay: Bool = false
  @State private var ShowMaxSongsOverlay: Bool = false
  @State private var ShowOfflineOverlay: Bool = false
  @State private var Completed: Bool = false
  
  var body: some View {
    ZStack{
      if(ShowOfflineOverlay){ OfflineOverlay(networkStatus: NetworkStatus.notConnected, Show: $ShowOfflineOverlay) }
      if(ShowQueuedOverlay){ GeneralOverlay(type: GeneralOverlayType.queued, Show: $ShowQueuedOverlay) }
      else if(ShowMaxSongsOverlay){ GeneralOverlay(type: GeneralOverlayType.maxSongs, Show: $ShowMaxSongsOverlay) }
      
      Color("Primary").edgesIgnoringSafeArea(.all)
      HStack(alignment: .top){
        Button(action: {
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
      
      ZStack{
        HStack(spacing: 3){
          ZStack{
            Image(systemName: "waveform")
              .font(.system(size: 18, weight: .bold))
              .foregroundColor(Color("Text"))
          }
          .frame(width: 25, alignment: .trailing)
          Text("Similar Songs")
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(Color("Text"))
        }
        .padding(3)
      }
      .frame(width: UIScreen.main.bounds.size.width*0.95, alignment: .topTrailing)
      .offset(y: -UIScreen.main.bounds.size.height/2*0.75)
      
      ZStack{
        if(appleMusic.UserRecommended.GeneratingSimilar && !Completed){
          SearchLoaderView(Searching: $appleMusic.UserRecommended.GeneratingSimilar, Completed: $Completed, length: 0.5)
        }
      }
      .frame(height: UIScreen.main.bounds.size.height*0.9, alignment: .bottom)
      
      
      if(!appleMusic.UserRecommended.GeneratingSimilar){
        VStack{
          ZStack{
            Spacer()
            ScrollView(showsIndicators: false){
              Spacer().frame(height: 1)
              VStack(alignment: .center, spacing: 11){
                ForEach(appleMusic.UserRecommended.SimilarSongs.prefix(10)){ song in
                  AppleMusicSongCell(Song: song, Queued: $ShowQueuedOverlay, MaxSongs: $ShowMaxSongsOverlay, Offline: $ShowOfflineOverlay)
                }
                if(appleMusic.UserRecommended.SimilarSongs.count > 7){ Spacer().frame(width: 1, height: UIScreen.main.bounds.size.height*0.02) }
              }
              .frame(width: UIScreen.main.bounds.size.width)
            }
          }
          .frame(height: UIScreen.main.bounds.size.height*0.8, alignment: .bottom)
        }
        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.68, alignment: .top)
      }
    }
    .navigationBarHidden(true)
    .onAppear{
      Task{
        ShowCurrentSong = false
        if(Show){ Show = false }
      }
    }
    // MARK: Handle Search scenePhase Changes
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
