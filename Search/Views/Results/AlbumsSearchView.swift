import SwiftUI
import MusicKit

struct AlbumsSearchView: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  let srch: Search = Search()
  
  @Binding var Filter: SearchFilter
  @Binding var Input: String
  
  @State private var Searching = false
  
  var body: some View {
    // MARK: Album Results Scroll View
    ZStack{
      if(room.MusicService == "AppleMusic"){
        if(!appleMusic.AlbumSearchResult.isEmpty){
          ZStack{
            Spacer()
            ScrollView(showsIndicators: false){
              VStack(spacing: 11){
                ForEach(appleMusic.AlbumSearchResult){ Album in
                  NavigationLink(destination: AppleMusicAlbumView(Album: Album, Loading: $Searching)){
                    if(Album == appleMusic.AlbumSearchResult.first){
                      AppleMusicAlbumCell(Album: Album)
                        .padding(.top, 15)
                    }
                    else{ AppleMusicAlbumCell(Album: Album) }
                  }
                  if(Album == appleMusic.AlbumSearchResult.last){ Spacer().frame(width: 1, height: UIScreen.main.bounds.size.height*0.08) }
                }
              }
            }
          }
          .padding(10)
          .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.75, alignment: .bottom)
        }
      }
    }
    .onAppear{ Task{ if(Input.isEmpty){ srch.Reset(Room: room, AppleMusic: appleMusic) } } }
  }
}
