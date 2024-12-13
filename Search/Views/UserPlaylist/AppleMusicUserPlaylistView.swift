import SwiftUI
import MusicKit

struct AppleMusicUserPlaylistView: View {
  @Environment(\.presentationMode) var Presentation
  @EnvironmentObject var appleMusic: AppleMusic
  
  let Playlist: UserPlaylist
  
  @Binding var Loading: Bool
  
  @State private var Completed: Bool = false
  @State private var ShowOfflineOverlay: Bool = false
  @State private var ShowQueuedOverlay: Bool = false
  @State private var ShowMaxSongsOverlay: Bool = false
  @State private var Reload: Bool = false
  
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
            SearchLoaderView(Searching: $Loading, Completed: $Completed, length: 0.4)
              .onAppear{
                Task{
                  let networkStatus: NetworkStatus = CheckNetworkStatus()
                  if(networkStatus == NetworkStatus.notConnected){ ShowOfflineOverlay = true }
                }
              }
          }
          .frame(height: UIScreen.main.bounds.size.height*0.9, alignment: .bottom)
        }
        
        if(Completed){
          HStack{
            if let PlaylistArtwork = Playlist.Art?.image(at: CGSize(width: UIScreen.main.bounds.size.height*0.13, height: UIScreen.main.bounds.size.height*0.13)){
              Image(uiImage: PlaylistArtwork)
                .resizable()
                .frame(width: UIScreen.main.bounds.size.height*0.13, height: UIScreen.main.bounds.size.height*0.13)
                .padding(.leading, 5)
            }
            else{
              Image(systemName: "music.note")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color("Tertiary"))
                .frame(width: UIScreen.main.bounds.size.height*0.13, height: UIScreen.main.bounds.size.height*0.13)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
            }
            VStack(alignment: .leading){
              ZStack{
                Text("Playlist")
                  .font(.system(size: 10, weight: .bold))
                  .foregroundColor(Color("Label"))
                  .padding(5)
              }
              .background(Capsule().fill(Color("Capsule")).opacity(0.3))
              ZStack{
                Text(Playlist.Title)
                  .font(.system(size: 15, weight: .bold))
                  .foregroundColor(Color("Text"))
                  .multilineTextAlignment(.leading)
              }
            }
            .frame(height: UIScreen.main.bounds.size.width*0.13, alignment: .leading)
            .padding(.leading, 10)
          }
          .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .center)
          
          if(!Playlist.AM_Songs.isEmpty){
            ZStack{
              ZStack{
                ScrollView(showsIndicators: false){
                  ForEach(Playlist.AM_Songs, id: \.self){ id in
                    AppleMusicUserPlaylistCell(AM_ID: id, Queued: $ShowQueuedOverlay, MaxSongs: $ShowMaxSongsOverlay, Reload: $Reload, Offline: $ShowOfflineOverlay)
                    if(id != Playlist.AM_Songs.last || Playlist.AM_Songs.count == 1){
                      Divider()
                        .frame(width: UIScreen.main.bounds.size.width*0.86, height: 1)
                        .background(Color("LightGray").opacity(0.6))
                    }
                  }
                }
              }
              .padding(10)
            }
            .frame(width: UIScreen.main.bounds.size.width*0.9, height: UIScreen.main.bounds.size.height*0.65)
            .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")).shadow(color: Color("Primary"), radius: 1))
            
            HStack(spacing: 2){
              Text(String(Playlist.AM_Songs.count))
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
    .onTapGesture{ Reload = true }
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
