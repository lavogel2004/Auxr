import SwiftUI

struct FriendCell: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var account: AuxrAccount
  
  let friendID: String
  
  @Binding var Loading: Bool
  @Binding var LoadedResults: Int
  @Binding var Completed: Bool
  @Binding var DisplayResults: [String]
  @Binding var SelectedID: String
  @Binding var AddFriend: Bool
  @Binding var RemoveFriend: Bool
  @Binding var CancelFriendRequest: Bool
  
  @State private var Friends: Bool = false
  @State private var Friend: AuxrAccount?
  @State private var FriendUsername: String = ""
  @State private var ProfileImage: UIImage? = nil
  @State private var Pending: Bool = false
  @State private var ToSender: Bool = false
  @State private var loadedImage: Bool = false
  
  var body: some View {
    ZStack{
      if(Friend != nil && loadedImage){
        VStack{
          HStack{
            NavigationLink(destination: SelectedProfileView(friendID: friendID).environmentObject(account)){
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
            
            if(!Friends && !Pending){
              HStack{
                ZStack{
                  Button(action: {
                    withAnimation(.easeIn(duration: 0.4)){
                      UIApplication.shared.dismissKeyboard()
                      AddFriend = true
                      Pending = true
                      SelectedID = friendID
                    }
                    Task{ try await AccountManager.sendFriendRequest(account_id: SelectedID, user: user) }
                  }){
                    HStack(spacing: 3){
                      Text("Friend ")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color("Label"))
                      Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color("Label"))
                    }
                    .padding(5)
                    .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")).shadow(color: Color("Tertiary"), radius: 1))
                    .frame(width: UIScreen.main.bounds.size.width*0.3, height: 25, alignment: .center)
                    .offset(x: -UIScreen.main.bounds.size.width*0.01)
                  }
                }
              }
            }
            
            if(!Friends && Pending){
              HStack{
                ZStack{
                  Text("Pending")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color("Label"))
                }
                .frame(width: String("Pending").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)))
                .padding(5)
                .background(Capsule().fill(Color("Capsule")).opacity(0.3))
                .offset(x: (!ToSender) ? 0 : UIScreen.main.bounds.size.width*0.032)
                if(!ToSender){
                  Button(action: {
                    UIApplication.shared.dismissKeyboard()
                    CancelFriendRequest = true
                    SelectedID = friendID
                  }){
                    ZStack{
                      Image(systemName: "xmark")
                        .foregroundColor(Color("Capsule").opacity(0.6))
                        .font(.system(size: 12, weight: .bold))
                    }
                    .padding(5)
                  }
                  .offset(x: UIScreen.main.bounds.size.width*0.023)
                }
              }
              .frame(width: UIScreen.main.bounds.size.width*0.4, alignment: .center)
              .offset(x: -UIScreen.main.bounds.size.width*0.105)
            }
            
            if(Friends && !Pending){
              NavigationLink(destination: InviteChannelsView(SelectedFriendID: friendID).environmentObject(account)){
                ZStack{
                  HStack(spacing: 3){
                    Text("INVITE")
                      .foregroundColor(Color("Tertiary"))
                      .font(.system(size: 14, weight: .bold))
                    Image(systemName: "paperplane.fill")
                      .font(.system(size: 14, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                      .frame(width: 20, height: 20, alignment: .center)
                  }
                  .offset(x: UIScreen.main.bounds.size.width*0.02)
                }
                .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .trailing)
              }
              .offset(x: -UIScreen.main.bounds.size.width*0.01)
            }
          }
          .frame(width: UIScreen.main.bounds.size.width*0.85, height: UIScreen.main.bounds.size.height*0.07, alignment: .leading)
          .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
        }
      }
      else{
        ZStack{
          HStack(spacing: 10){
            Circle()
              .fill(Color("Capsule").opacity(0.3))
              .frame(width: UIScreen.main.bounds.size.height*0.045, height: UIScreen.main.bounds.size.height*0.045)
              .padding(.leading, 10)
            Capsule()
              .fill(Color("Capsule").opacity(0.3))
              .frame(width: UIScreen.main.bounds.size.width*0.3, height: 9, alignment: .leading)
              .padding(3)
          }
          .frame(maxWidth: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
        }
        .frame(width: UIScreen.main.bounds.size.width*0.85, height: UIScreen.main.bounds.size.height*0.07, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
      }
    }
    .frame(width: UIScreen.main.bounds.size.width*0.9)
    .onAppear{
      Task{
        if let i: Int = account.FriendRequests.firstIndex(where: { $0.Sender == friendID }){
          if(!account.FriendRequests[i].Responded){ Pending = true }
          else{ Pending = false }
          ToSender = true
        }
        else if let i: Int = account.FriendRequests.firstIndex(where: { $0.Receiver == friendID }){
          if(!account.FriendRequests[i].Responded){ Pending = true }
          else{ Pending = false }
        }
        else if let i: Int = account.Friends.firstIndex(where: { $0.ID == friendID }){
          if(!account.Friends[i].ID.isEmpty){ Friends = true }
          else{ Friends = false }
        }
        if let profile_pic = try await AccountManager.getProfilePicture(account_id: friendID){
          ProfileImage = profile_pic
          loadedImage = true
        }
        else{
          loadedImage = true
        }
        Friend = try await AccountManager.getAccount(account_id: friendID)
        FriendUsername = Friend?.Username ?? "Username"
        LoadedResults += 1
        if(LoadedResults <= DisplayResults.count){
          Loading = true
          Completed = false
        }
      }
    }
  }
}
