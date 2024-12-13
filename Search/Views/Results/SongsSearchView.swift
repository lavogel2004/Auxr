import SwiftUI

struct SongsSearchView: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  let srch: Search = Search()
  
  @Binding var Filter: SearchFilter
  @Binding var Input: String
  @Binding var Queued: Bool
  @Binding var MaxSongs: Bool
  @Binding var Offline: Bool
  
  var body: some View {
    // MARK: Song Results Scroll View
    ZStack{
      if(room.MusicService == "AppleMusic"){
        if(!appleMusic.SongSearchResult.isEmpty){
          ZStack{
            ZStack{
              Spacer()
              ScrollView(showsIndicators: false){
                VStack(spacing: 11){
                  ForEach(appleMusic.SongSearchResult){ song in
                    if(song == appleMusic.SongSearchResult.first){
                      AppleMusicSongCell(Song: song, Queued: $Queued, MaxSongs: $MaxSongs, Offline: $Offline)
                        .padding(.top, 15)
                    }
                    else{ AppleMusicSongCell(Song: song, Queued: $Queued, MaxSongs: $MaxSongs, Offline: $Offline) }
                    if(song == appleMusic.SongSearchResult.last){ Spacer().frame(width: 1, height: UIScreen.main.bounds.size.height*0.08) }
                  }
                }
              }
            }
            .padding(10)
          }
          .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.75, alignment: .bottom)
        }
      }
    }
    .onAppear{ Task{ if(Input.isEmpty){ srch.Reset(Room: room, AppleMusic: appleMusic) } } }
  }
}
