import SwiftUI
import MusicKit

struct AppleMusicLikeCell: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  let Song: AuxrSong
  
  @Binding var Remove: Bool
  @State private var AM_Song: Song?
  @State private var ShowAlert: Bool = false
  @State private var Queued: Bool = false
  
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
          }
          .frame(width: UIScreen.main.bounds.size.width*0.5, alignment: .leading)
        }
        .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .leading)
        Button(action: {
          withAnimation(.easeIn(duration: 0.2)){
            Remove = true
            user.Likes = user.Likes.filter{ $0 != Song}
          }
          Task{
            if let account: AuxrAccount = user.Account{
              try await AccountManager.deleteAccountLikes(account: account, like: Song)
              if let am_song = try await appleMusic.ConvertSong(AuxrSong: Song){
                appleMusic.AccountLikes = appleMusic.AccountLikes.filter{ $0.id.rawValue != am_song.id.rawValue }
              }
            }
          }
        }){
          Image(systemName: "xmark")
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(Color("Tertiary").opacity(0.8))
        }
        .frame(width: 13, height: 13)
        .offset(x: UIScreen.main.bounds.size.width*0.03, y: -UIScreen.main.bounds.size.height*0.023)
      }
      .frame(width: UIScreen.main.bounds.size.width*0.8, height: UIScreen.main.bounds.size.height*0.08, alignment: .leading)
      .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
    }
    .padding(.top, 3)
    .onTapGesture{ Task{ AM_Song = try await appleMusic.ConvertSong(AuxrSong: Song) } }
    .onAppear{ Task{ AM_Song = try await appleMusic.ConvertSong(AuxrSong: Song) } }
  }
}
