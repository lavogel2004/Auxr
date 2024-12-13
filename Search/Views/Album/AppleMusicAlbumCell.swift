import SwiftUI
import MusicKit

struct AppleMusicAlbumCell: View {  
  let Album: Album
  
  var body: some View {
    HStack{
      HStack(spacing: 7){
        if let AlbumImage:Artwork = Album.artwork{
          ArtworkImage(AlbumImage, width: UIScreen.main.bounds.size.height*0.07)
            .padding(.leading, 5)
        }
        else{
          Image(systemName: "music.note")
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(Color("Tertiary"))
            .frame(width: UIScreen.main.bounds.size.height*0.07, height: UIScreen.main.bounds.size.height*0.07)
            .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
            .padding(.leading, 5)
        }
        VStack(alignment: .leading, spacing: 2){
          ZStack{
            Text("Album")
              .font(.system(size: 8, weight: .bold))
              .foregroundColor(Color("Label"))
              .padding(3)
          }
          .frame(width: String("Album").widthOfString(usingFont: UIFont.systemFont(ofSize: 11)))
          .background(Capsule().fill(Color("Capsule")).opacity(0.3))
          Text(Album.title).lineLimit(1)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(Color("Text"))
          
          Text(Album.artistName).lineLimit(1)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(Color("Text"))
        }
        .frame(width: UIScreen.main.bounds.size.width*0.5, alignment: .leading)
      }
      .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .leading)
    }
    .frame(width: UIScreen.main.bounds.size.width*0.82, height: UIScreen.main.bounds.size.height*0.08, alignment: .leading)
    .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
  }
}
