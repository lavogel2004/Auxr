import SwiftUI

struct ProfileFriendCell: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var account: AuxrAccount
  
  let friendID: String
  
  @State private var Friends: Bool = false
  @State private var Friend: AuxrAccount?
  @State private var FriendUsername: String = ""
  @State private var ProfileImage: UIImage? = nil
  
  var body: some View {
    ZStack{
      if(Friend != nil){
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
            .disabled(friendID == account.ID)
            if(Friends && friendID != account.ID){
              ZStack{
                Text("Friends")
                  .font(.system(size: 10, weight: .bold))
                  .foregroundColor(Color("Label"))
              }
              .frame(width: String("Friends").widthOfString(usingFont: UIFont.systemFont(ofSize: 13)))
              .padding(5)
              .background(Capsule().fill(Color("Tertiary").opacity(0.6)))
            }
          }
          .frame(width: UIScreen.main.bounds.size.width*0.8, height: UIScreen.main.bounds.size.height*0.07, alignment: .leading)
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
              .frame(width: UIScreen.main.bounds.size.width*0.4, height: 9, alignment: .leading)
              .padding(3)
          }
          .frame(maxWidth: UIScreen.main.bounds.size.width*0.4, alignment: .leading)
        }
        .frame(width: UIScreen.main.bounds.size.width*0.8, height: UIScreen.main.bounds.size.height*0.07, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
      }
    }
    .frame(width: UIScreen.main.bounds.size.width*0.9)
    .onAppear{
      Task{
        if let i: Int = account.Friends.firstIndex(where: { $0.ID == friendID }){
          if(!account.Friends[i].ID.isEmpty){ Friends = true }
          else{ Friends = false }
        }
        if let profile_pic = try await AccountManager.getProfilePicture(account_id: friendID){
          ProfileImage = profile_pic
        }
        Friend = try await AccountManager.getAccount(account_id: friendID)
        FriendUsername = Friend?.Username ?? "Username"
      }
    }
  }
}

