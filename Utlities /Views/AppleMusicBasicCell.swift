import SwiftUI
import MusicKit

struct AppleMusicBasicSongCell: View {
  @EnvironmentObject var appleMusic: AppleMusic
  
  let Song: AuxrSong
  
  @State private var AM_Song: Song?
  
  var body: some View {
    VStack(alignment: .leading, spacing: nil){
      HStack{
        HStack(spacing: 7){
          if let AlbumImage:Artwork = AM_Song?.artwork{
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
            if let Title = AM_Song?.title{
              Text(Title).lineLimit(1)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color("Text"))
            }
            if let Artist = AM_Song?.artistName{
              Text(Artist).lineLimit(1)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color("Text"))
            }
            Text(FormatDurationToString(s: Double(AM_Song?.duration ?? 0))).lineLimit(1)
              .font(.system(size: 11, weight: .medium))
              .foregroundColor(Color("Text"))
              .multilineTextAlignment(.leading)
          }
          .frame(width: UIScreen.main.bounds.size.width*0.5, alignment: .leading)
        }
        .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .leading)
      }
      .frame(width: UIScreen.main.bounds.size.width*0.8, height: UIScreen.main.bounds.size.height*0.08, alignment: .leading)
      .background(RoundedRectangle(cornerRadius: 6).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
    }
    .padding(.top, 3)
    .onTapGesture{ Task{ AM_Song = try await appleMusic.ConvertSong(AuxrSong: Song) } }
    .onAppear{ Task{ AM_Song = try await appleMusic.ConvertSong(AuxrSong: Song) } }
  }
}
