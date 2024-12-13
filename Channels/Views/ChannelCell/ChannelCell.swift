import SwiftUI
import MusicKit

struct ChannelCell: View {
  @EnvironmentObject var router: Router
  @EnvironmentObject var room: Room
  @EnvironmentObject var account: AuxrAccount
  @EnvironmentObject var appleMusic: AppleMusic
  
  let Channel: AuxrChannel
  @Binding var Loading: Bool
  @Binding var LoadedResults: Int
  @Binding var Completed: Bool
  @Binding var Selected: String
  @Binding var ShowMenu: Bool
  @Binding var Passcode: String
  @Binding var Joining: Bool
  @Binding var Joined: Bool
  @Binding var NameChange: Bool
  @Binding var Refresh: Bool
  @Binding var Offline: Bool
  
  @State private var rm: Room? = nil
  @State private var AM_Song: Song?
  
  var body: some View {
    ZStack{
      if(rm != nil){
        withAnimation(.easeIn(duration: 0.2)){
          VStack(alignment: .leading, spacing: nil){
            HStack(spacing: 7){
              Button(action: {
                let networkStatus: NetworkStatus = CheckNetworkStatus()
                if(networkStatus == NetworkStatus.reachable){
                  if(appleMusic.Authorized != .denied || appleMusic.Authorized != .restricted){
                    if let joinedRoom: Room = rm{
                      room.ID = joinedRoom.ID
                      room.Passcode = joinedRoom.Passcode
                      Passcode = joinedRoom.Passcode
                      Joining = true
                      Joined = true
                    }
                  }
                }
                if(networkStatus == NetworkStatus.notConnected){ Offline = true }
              }){
                if let AlbumImage:Artwork = AM_Song?.artwork{
                  ArtworkImage(AlbumImage, width: UIScreen.main.bounds.size.height*0.06)
                    .padding(.leading, 5)
                }
                else{
                  Image(systemName: "music.note")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: UIScreen.main.bounds.size.height*0.06, height: UIScreen.main.bounds.size.height*0.06)
                    .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
                    .padding(.leading, 5)
                }
                HStack(spacing: 7){
                  VStack(alignment: .leading, spacing: 2){
                    Text(rm?.Name ?? "...")
                      .lineLimit(1)
                      .font(.system(size: 13, weight: .bold))
                      .foregroundColor(Color("Text"))
                    Text(rm?.Creator.Nickname ?? "@Username")
                      .lineLimit(1)
                      .font(.system(size: 11, weight: .medium))
                      .foregroundColor(Color("Text"))
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
                }
              }
              .frame(width: UIScreen.main.bounds.size.width*0.53, alignment: .leading)
              
              NavigationLink(destination: ChannelListenersView(RoomID: rm?.ID ?? "").environmentObject(account)){
                HStack(spacing: 3){
                  Image(systemName: "person.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("\(String((rm?.Guests.count ?? 0) + 1))")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Tertiary"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.075, alignment: .leading)
              }
              ZStack{
                Button(action: {
                  ShowMenu.toggle()
                  Selected = Channel.RoomData.roomID
                }){
                  ZStack{
                    if(!ShowMenu){
                      Image(systemName: "ellipsis")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(Color("Tertiary").opacity(0.8))
                    }
                    if(ShowMenu && Channel.RoomData.roomID == Selected){
                      Image(systemName: "ellipsis")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundColor(Color("Tertiary").opacity(0.4))
                    }
                  }
                }
                .offset(x: UIScreen.main.bounds.size.width*0.06)
              }
            }
            .frame(width: UIScreen.main.bounds.size.width*0.85, height: UIScreen.main.bounds.size.height*0.07, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
            ZStack{
              if(rm?.PlaySong ?? false){
                Text("Playing Now")
                  .font(.system(size: 12, weight: .medium))
                  .foregroundColor(Color("Capsule").opacity(0.6))
              }
              if(!(rm?.PlaySong ?? false)){
                Text("Last played on " + "\(FormatTimeToDate(Time: rm?.timestamp))")
                  .font(.system(size: 12, weight: .medium))
                  .foregroundColor(Color("Capsule").opacity(0.6))
              }
            }
            .padding(.leading, 5)
          }
        }
      }
      else{
        ZStack{
          HStack(spacing: 10){
            Image(systemName: "music.note")
              .font(.system(size: 13, weight: .bold))
              .foregroundColor(Color("Tertiary"))
              .frame(width: UIScreen.main.bounds.size.height*0.06, height: UIScreen.main.bounds.size.height*0.06)
              .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              .padding(.leading, 5)
            VStack(alignment: .leading, spacing: 2){
              Capsule()
                .fill(Color("Capsule").opacity(0.3))
                .frame(width: UIScreen.main.bounds.size.width*0.1, height: 9, alignment: .leading)
                .padding(3)
              Capsule()
                .fill(Color("Capsule").opacity(0.3))
                .frame(width: UIScreen.main.bounds.size.width*0.2, height: 9, alignment: .leading)
                .padding(3)
            }
            .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
            .padding(.leading, 5)
          }
        }
        .frame(width: UIScreen.main.bounds.size.width*0.85, height: UIScreen.main.bounds.size.height*0.07, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
      }
      
      if(Refresh){
        Spacer().frame(height: 0).onAppear{
          Task{ rm = try await FirebaseManager.FetchRoomByID(ID: Channel.RoomData.roomID) }
        }
      }
    }
    .frame(width: UIScreen.main.bounds.size.width*0.9)
    .onAppear{
      Task{
        if(rm == nil){
          rm = try await FirebaseManager.FetchRoomByID(ID: Channel.RoomData.roomID)
        }
        if(!(rm?.Playlist.Queue.isEmpty ?? false)){
          if let firstSong = rm?.Playlist.Queue.sorted()[0]{
            AM_Song = try await appleMusic.ConvertSong(AuxrSong: firstSong)
          }
        }
        if(NameChange){
          rm = try await FirebaseManager.FetchRoomByID(ID: Channel.RoomData.roomID)
          NameChange = false
        }
        LoadedResults += 1
        if(LoadedResults <= account.Channels.count){
          Loading = true
          Completed = false
        }
      }
    }
    .zIndex(1)
  }
}
