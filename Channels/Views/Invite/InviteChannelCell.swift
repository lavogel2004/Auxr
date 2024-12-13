import SwiftUI
import MusicKit

struct InviteChannelCell: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var account: AuxrAccount
  @EnvironmentObject var appleMusic: AppleMusic
  
  let Channel: AuxrChannel
  let SelectedFriendID: String
  @Binding var SelectedChannelID: String
  @Binding var Loaded: Bool
  @Binding var SendInvite: Bool
  @Binding var CancelInvite: Bool
  @Binding var Offline: Bool
  
  @State private var Invited: Bool = false
  @State private var FromSender: Bool =  false
  @State private var AlreadyIn: Bool = false
  @State private var Completed: Bool = false
  @State private var room: Room? = nil
  @State private var AM_Song: Song? = nil
  
  var body: some View {
    ZStack{
      Color("Primary").edgesIgnoringSafeArea(.all)
      VStack(spacing: 2){
        HStack{
          Button(action: {
            SendInvite = true
            let networkStatus: NetworkStatus = CheckNetworkStatus()
            if(networkStatus == NetworkStatus.reachable){
              Task{
                try await AccountManager.sendRoomInvite(room_id: Channel.RoomData.roomID, recieving_account: SelectedFriendID, sending_account: account)
              }
            }
            if(networkStatus == NetworkStatus.notConnected){ Offline = true }
          }){
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
                }
                .frame(width: UIScreen.main.bounds.size.width*0.52, alignment: .leading)
                ZStack{
                  HStack(spacing: 3){
                    ZStack{
                      if(Invited && FromSender){
                        ZStack{
                          Text("Invited")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color("Label"))
                        }
                        .frame(width: String("Invited").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)))
                        .padding(5)
                        .background(Capsule().fill(Color("Capsule")).opacity(0.3))
                      }
                      else{
                        Spacer()
                          .frame(width: String("Invited").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)))
                          .padding(5)
                      }
                      if(AlreadyIn){
                        ZStack{
                          Text("Joined")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color("Label"))
                        }
                        .frame(width: String("Joined").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)))
                        .padding(5)
                        .background(Capsule().fill(Color("Tertiary")).opacity(0.6))
                      }
                    }
                  }
                  .offset(x: -UIScreen.main.bounds.size.width*0.13)
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
          .disabled((Invited && FromSender) || AlreadyIn)
          ZStack{
            if(Invited && FromSender){
              Button(action: {
                SelectedChannelID = Channel.RoomData.roomID
                CancelInvite = true
              }){
                ZStack{
                  Image(systemName: "xmark")
                    .foregroundColor(Color("Capsule").opacity(0.6))
                    .font(.system(size: 12, weight: .bold))
                }
                .padding(5)
              }
            }
            else{
              Circle()
                .fill(Color("Primary"))
                .frame(width: 20, height: 20)
            }
          }
          .offset(x: -UIScreen.main.bounds.size.width*0.04)
        }
        .frame(width: UIScreen.main.bounds.size.width*0.8, alignment: .leading)
        .padding(.bottom, 3)
        if(Channel != account.Channels.sorted().last || account.Channels.count == 1){
          Divider()
            .frame(width: UIScreen.main.bounds.size.width*0.86, height: 1)
            .background(Color("LightGray").opacity(0.6))
        }
      }
    }
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
        let friendAccount = try await AccountManager.getAccount(account_id: SelectedFriendID)
        if let i: Int = friendAccount.RoomRequests.firstIndex(where: { $0.room_id == Channel.RoomData.roomID }){
          if(!friendAccount.RoomRequests[i].Responded){
            Invited = true
            if(friendAccount.RoomRequests[i].Sender == account.ID){
              FromSender = true
            }
          }
          else{ Invited = false }
        }
        if let rm: Room = room{
          if(rm.Creator.pai == friendAccount.ID ||
             rm.Host.pai == friendAccount.ID ||
             rm.Guests.contains(where: { $0.pai == friendAccount.ID })
          ){
            AlreadyIn = true
            Invited = false
          }
        }
      }
    }
  }
}

