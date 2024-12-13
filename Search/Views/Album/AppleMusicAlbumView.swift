import SwiftUI
import MusicKit

struct AppleMusicAlbumView: View {
  @Environment(\.presentationMode) var Presentation
  @EnvironmentObject var appleMusic: AppleMusic
  
  let Album: Album
  
  @Binding var Loading: Bool
  
  @State private var Completed: Bool = false
  @State private var ShowOfflineOverlay: Bool = false
  @State private var ShowQueuedOverlay: Bool = false
  @State private var ShowMaxSongsOverlay: Bool = false
  
  var body: some View {
    ZStack{
      Color("Secondary").edgesIgnoringSafeArea(.all)
      
      if(ShowOfflineOverlay){ OfflineOverlay(networkStatus: NetworkStatus.notConnected, Show: $ShowOfflineOverlay) }
      if(ShowQueuedOverlay){ GeneralOverlay(type: GeneralOverlayType.queued, Show: $ShowQueuedOverlay) }
      else if(ShowMaxSongsOverlay){ GeneralOverlay(type: GeneralOverlayType.maxSongs, Show: $ShowMaxSongsOverlay) }
      
      ZStack{
        Button(action: { Presentation.wrappedValue.dismiss()}){
          Image(systemName: "chevron.left")
            .frame(width: UIScreen.main.bounds.size.width*0.2, height: 20, alignment: .leading)
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(Color("Tertiary"))
            .padding(.leading, 10)
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.95, alignment: .topLeading)
      .offset(y: -UIScreen.main.bounds.size.height/2*0.85)
      
      VStack(spacing: 10){
        if(Loading){
          ZStack{
            SearchLoaderView(Searching: $Loading, Completed: $Completed, length: 0.35)
              .onAppear{
                Task{
                  let networkStatus: NetworkStatus = CheckNetworkStatus()
                  if(networkStatus == NetworkStatus.reachable){ try await appleMusic.GetAlbumTracks(Album: Album, Background: false) }
                  if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
                }
              }
          }
          .frame(height: UIScreen.main.bounds.size.height*0.9, alignment: .bottom)
        }
        
        if(Completed){
          HStack{
            if let AlbumImage:Artwork = Album.artwork{
              ArtworkImage(AlbumImage, width: UIScreen.main.bounds.size.height*0.13)
            }
            else{
              Image(systemName: "music.note")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color("Tertiary"))
                .frame(width: UIScreen.main.bounds.size.height*0.13, height: UIScreen.main.bounds.size.height*0.13)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
                .background(Color("Primary"))
            }
            VStack(alignment: .leading){
              ZStack{
                Text("Album")
                  .font(.system(size: 10, weight: .bold))
                  .foregroundColor(Color("Label"))
                  .padding(5)
              }
              .background(Capsule().fill(Color("Capsule")).opacity(0.3))
              
              ZStack{
                Text(Album.title)
                  .font(.system(size: 15, weight: .bold))
                  .foregroundColor(Color("Text"))
                  .multilineTextAlignment(.leading)
              }
              
              ZStack{
                Text(Album.artistName)
                  .font(.system(size: 12, weight: .medium))
                  .foregroundColor(Color("Text"))
              }
            }
            .frame(height: UIScreen.main.bounds.size.width*0.13)
            .padding(.leading, 10)
          }
          .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .center)
          
          if(!appleMusic.AlbumTracks.isEmpty){
            ZStack{
              ZStack{
                ScrollView(showsIndicators: false){
                  ForEach(Array(appleMusic.AlbumTracks)){ track in
                    if case .song = track{
                      AppleMusicAlbumTrackCell(Track: track, Queued: $ShowQueuedOverlay, MaxSongs: $ShowMaxSongsOverlay, Offline: $ShowOfflineOverlay)
                      if(track != appleMusic.AlbumTracks.last || appleMusic.AlbumTracks.count == 1){
                        Divider()
                          .frame(width: UIScreen.main.bounds.size.width*0.86, height: 1)
                          .background(Color("LightGray").opacity(0.6))
                      }
                    }
                  }
                }
              }
              .padding(10)
            }
            .frame(width: UIScreen.main.bounds.size.width*0.9, height: UIScreen.main.bounds.size.height*0.65)
            .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")).shadow(color: Color("Primary"), radius: 1))
            
            HStack(spacing: 2){
              Text(String(appleMusic.AlbumTracks.count))
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color("System"))
              Text("Tracks")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color("System"))
            }
            
          }
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.9, height: UIScreen.main.bounds.size.height*0.85, alignment: .bottom)
      
    }
    .navigationBarHidden(true)
    .onAppear{ Loading = true }
    .gesture(DragGesture(minimumDistance: 15, coordinateSpace: .global)
      .onEnded { position in
        let HorizontalDrag = position.translation.width
        let VerticalDrag = position.translation.height
        if(abs(HorizontalDrag) > abs(VerticalDrag)){
          if(HorizontalDrag > 0){ Presentation.wrappedValue.dismiss() }
        }
      })
  }
}
