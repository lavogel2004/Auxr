import SwiftUI

struct FriendPopoverCell: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var account: AuxrAccount
  
  let friendID: String
  let roomID: String
  
  @Binding var SelectedFriend: String
  @Binding var Loading: Bool
  @Binding var LoadedResults: Int
  @Binding var Completed: Bool
  @Binding var SendInvite: Bool
  @Binding var CancelInvite: Bool
  @Binding var Offline: Bool
  
  @State private var room: Room? = nil
  @State private var Friends: Bool = false
  @State private var Friend: AuxrAccount? = nil
  @State private var FriendUsername: String = ""
  @State private var ProfileImage: UIImage? = nil
  @State private var Pending: Bool = false
  @State private var Invited: Bool = false
  @State private var FromSender: Bool = false
  @State private var AlreadyIn: Bool = false
  @State private var loadedImage: Bool = false
  
  var body: some View {
    ZStack{
      VStack(spacing: 10){
        HStack{
          Button(action: {
            SendInvite = true
            let networkStatus: NetworkStatus = CheckNetworkStatus()
            if(networkStatus == NetworkStatus.reachable){
              Task{
                if let account: AuxrAccount = user.Account{
                  try await AccountManager.sendRoomInvite(room_id: roomID, recieving_account: friendID, sending_account: account)
                  withAnimation(.easeIn(duration: 0.4)){
                    Invited = true
                  }
                }
              }
            }
            if(networkStatus == NetworkStatus.notConnected){ Offline = true }
          }){
            HStack{
              if let UserImage = ProfileImage{
                Image(uiImage: UserImage)
                  .resizable()
                  .clipShape(Circle())
                  .aspectRatio(contentMode: .fill)
                  .frame(width: UIScreen.main.bounds.size.height*0.045, height: UIScreen.main.bounds.size.height*0.045)
                  .background(Circle().fill(Color("Capsule").opacity(0.3)))
              }
              else{
                Image(systemName: "person.fill")
                  .font(.system(size: 25, weight: .bold))
                  .clipShape(Circle())
                  .foregroundColor(Color("Capsule").opacity(0.6))
                  .frame(width: UIScreen.main.bounds.size.height*0.045, height: UIScreen.main.bounds.size.height*0.045)
                  .background(Circle().fill(Color("Capsule").opacity(0.3)))
              }
              Text(FriendUsername)
                .lineLimit(1)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Text"))
            }
            .frame(width: UIScreen.main.bounds.size.width*0.55, alignment: .leading)
            .padding(.leading, 10)
          }
          .disabled((Invited && FromSender) || AlreadyIn)
          HStack(spacing: 3){
            ZStack{
              ZStack{
                if(Invited && FromSender){
                  HStack{
                    ZStack{
                      Text("Invited")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color("Label"))
                    }
                    .frame(width: String("Invited").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)))
                    .padding(5)
                    .background(Capsule().fill(Color("Capsule")).opacity(0.3))
                  }
                }
                else{
                  HStack{
                    ZStack{
                      Text("Invited")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color("Secondary"))
                    }
                    .frame(width: String("Invited").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)))
                    .padding(5)
                    .background(Capsule().fill(Color("Secondary")))
                  }
                }
                if(AlreadyIn){
                  HStack{
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
            }
            ZStack{
              if(Invited && FromSender){
                Button(action: {
                  CancelInvite = true
                  SelectedFriend = friendID
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
                  .fill(Color("Secondary"))
                  .frame(width: 20, height: 20)
              }
            }
            .offset(x: UIScreen.main.bounds.size.width*0.04)
          }
        }
        .frame(width: UIScreen.main.bounds.size.width*0.87, height: UIScreen.main.bounds.size.height*0.06, alignment: .leading)
        if(Friend != nil &&
           (friendID != account.Friends.sorted().last?.ID || account.Friends.count == 1)){
          Divider()
            .frame(width: UIScreen.main.bounds.size.width*0.89, height: 1)
            .background(Color("LightGray").opacity(0.6))
        }
      }
    }
    .onAppear{
      Task{
        let friendAccount = try await AccountManager.getAccount(account_id: friendID)
        room = try await FirebaseManager.FetchRoomByID(ID: roomID)
        Friend = friendAccount
        if let i: Int = friendAccount.RoomRequests.firstIndex(where: { $0.room_id == roomID }){
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
        if let profile_pic = try await AccountManager.getProfilePicture(account_id: friendID){
          ProfileImage = profile_pic
          loadedImage = true
        }
        else{
          loadedImage = true
        }
        FriendUsername = friendAccount.Username
        LoadedResults += 1
      }
    }
  }
}

