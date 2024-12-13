import SwiftUI
import MusicKit

struct ProfileChannelCell: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var account: AuxrAccount
  @EnvironmentObject var appleMusic: AppleMusic
  
  let Channel: AuxrChannel
  
  @State private var AlreadyIn: Bool = false
  @State private var room: Room? = nil
  @State private var AM_Song: Song?
  
  var body: some View {
    ZStack{
      VStack(spacing: 2){
        HStack{
          VStack{
            HStack(spacing: UIScreen.main.bounds.size.width*0.14){
              HStack{
                if let AlbumImage:Artwork = AM_Song?.artwork{
                  ArtworkImage(AlbumImage, width: UIScreen.main.bounds.size.height*0.045)
                    .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
                }
                else{
                  Image(systemName: "music.note")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: UIScreen.main.bounds.size.height*0.045, height: UIScreen.main.bounds.size.height*0.045)
                    .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
                }
                VStack(alignment: .leading, spacing: 2){
                  Text(room?.Name ?? "...").lineLimit(1)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color("Text"))
                    .foregroundColor(!(room?.Creator.Nickname.isEmpty ?? false) ? Color("Text") : Color("Capsule").opacity(0.6))
                  Text(room?.Creator.Nickname ?? "...").lineLimit(1)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.52, alignment: .leading)
                ZStack{
                  if(AlreadyIn){
                    ZStack{
                      Text("Joined")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color("Label"))
                    }
                    .frame(width: String("Joined").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)))
                    .padding(5)
                    .background(Capsule().fill(Color("Tertiary")).opacity(0.6))
                    .offset(x: -UIScreen.main.bounds.size.width*0.13)
                  }
                  else{
                    ZStack{
                      Text("Joined")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color.clear)
                    }
                    .frame(width: String("Joined").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)))
                    .padding(5)
                    .background(Color.clear)
                    .offset(x: -UIScreen.main.bounds.size.width*0.13)
                  }
                  HStack(spacing: 3){
                    Image(systemName: "person.fill")
                      .font(.system(size: 13, weight: .bold))
                      .foregroundColor(Color("Text"))
                    Text("\(String((room?.Guests.count ?? 0) + 1))")
                      .font(.system(size: 13, weight: .semibold))
                      .foregroundColor(Color("Text"))
                      .zIndex(4)
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.075, alignment: .leading)
                }
              }
              .frame(width: UIScreen.main.bounds.size.width*0.8, alignment: .leading)
            }
          }
          .disabled(AlreadyIn)
        }
        .frame(width: UIScreen.main.bounds.size.width*0.8, alignment: .center)
        .padding(.bottom, 7)
        if(Channel != account.Channels.sorted().last || account.Channels.count == 1){
          Divider()
            .frame(width: UIScreen.main.bounds.size.width*0.83, height: 1)
            .background(Color("LightGray").opacity(0.6))
        }
      }
    }
    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .center)
    .background(Color("Secondary"))
    .onAppear{
      Task{
        if(room == nil){
          room = try await FirebaseManager.FetchRoomByID(ID: Channel.RoomData.roomID)
        }
        if(!(room?.Playlist.Queue.isEmpty ?? false)){
          if let firstSong = room?.Playlist.Queue.sorted()[0]{
            AM_Song = try await appleMusic.ConvertSong(AuxrSong: firstSong)
          }
        }
        if let rm: Room = room{
          if(rm.Creator.pai == account.ID ||
             rm.Host.pai == account.ID ||
             rm.Guests.contains(where: { $0.pai == account.ID })
          ){
            AlreadyIn = true
          }
        }
      }
    }
    .zIndex(1)
  }
}
