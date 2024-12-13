import SwiftUI

struct FriendsSearchResultsView: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var account: AuxrAccount
  
  @Binding var Loading: Bool
  @Binding var LoadedResults: Int
  @Binding var Completed: Bool
  @Binding var StartFriendsSearch: Bool
  @Binding var Filter: FriendsFilter
  @Binding var SelectedFriend: String
  @Binding var DisplayResults: [String]
  @Binding var AddFriend: Bool
  @Binding var RemoveFriend: Bool
  @Binding var CancelFriendRequest: Bool
  
  var body: some View {
    ZStack{
      if(!DisplayResults.isEmpty){
        ScrollView(showsIndicators: false){
          VStack(spacing: 15){
            Spacer().frame(height: 0)
            ForEach(DisplayResults.sorted(), id: \.self){ friendID in
              if(account.ID != friendID){
                FriendCell(friendID: friendID, Loading: $Loading, LoadedResults: $LoadedResults, Completed: $Completed, DisplayResults: $DisplayResults, SelectedID: $SelectedFriend, AddFriend: $AddFriend, RemoveFriend: $RemoveFriend, CancelFriendRequest: $CancelFriendRequest)
              }
            }
            if(DisplayResults.count > 6){
              Spacer().frame(height: UIScreen.main.bounds.size.height*0.02)
            }
          }
        }
        .frame(maxWidth: UIScreen.main.bounds.size.width*0.9, maxHeight: UIScreen.main.bounds.size.height*0.67, alignment: .center)
        .onTapGesture{
          if(StartFriendsSearch){
            UIApplication.shared.dismissKeyboard()
            StartFriendsSearch = false
            LoadedResults = 0
          }
        }
        if(DisplayResults.count > 6){
          ZStack{
            Spacer()
              .frame(width: UIScreen.main.bounds.size.width*0.8, height: UIScreen.main.bounds.size.height*0.3)
              .background(
                LinearGradient(
                  gradient: Gradient(stops: [.init(color: Color("Primary").opacity(0.01), location: 0), .init(color: Color("Primary"), location: 1)]),
                  startPoint: .top,
                  endPoint: .bottom
                )
                .cornerRadius(6)
                .allowsHitTesting(false)
              )
          }
          .offset(y: UIScreen.main.bounds.size.height*0.4)
        }
      }
      else{
        if(Filter == FriendsFilter.addFriends){
          VStack(spacing: 2){
            HStack(spacing: 4){
              Image(systemName: "minus.magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Capsule").opacity(0.6))
              Text("No Results")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Capsule").opacity(0.6))
            }
            Text("Add other users to share sessions and listen together")
              .font(.system(size: 11, weight: .medium))
              .foregroundColor(Color("Capsule").opacity(0.6))
          }
          .frame(maxWidth: UIScreen.main.bounds.size.width*0.9, maxHeight: UIScreen.main.bounds.size.height*0.5, alignment: .center)
          .offset(y: -UIScreen.main.bounds.size.height*0.3)
        }
        if(Filter == FriendsFilter.userFriends){
          if(account.Friends.isEmpty){
            VStack(spacing: 2){
              HStack(spacing: 4){
                ZStack{
                  Image(systemName: "person.3.fill")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("Capsule").opacity(0.6))
                }
                .offset(y: -1.25)
                Text("No Friends")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Capsule").opacity(0.6))
              }
              Text("Start searching to add your friends")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color("Capsule").opacity(0.6))
            }
            .frame(maxWidth: UIScreen.main.bounds.size.width*0.9, maxHeight: UIScreen.main.bounds.size.height*0.5, alignment: .center)
            .offset(y: -UIScreen.main.bounds.size.height*0.3)
            .onTapGesture{
              if(StartFriendsSearch){
                UIApplication.shared.dismissKeyboard()
                StartFriendsSearch = false
                LoadedResults = 0
              }
            }
          }
          else{
            VStack(spacing: 2){
              HStack(spacing: 4){
                ZStack{
                  Image(systemName: "minus.magnifyingglass")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("Capsule").opacity(0.6))
                }
                .offset(y: -1.25)
                Text("No Results")
                  .font(.system(size: 15, weight: .medium))
                  .foregroundColor(Color("Capsule").opacity(0.6))
              }
              Text("No friends match your search")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(Color("Capsule").opacity(0.6))
            }
            .frame(maxWidth: UIScreen.main.bounds.size.width*0.9, maxHeight: UIScreen.main.bounds.size.height*0.5, alignment: .center)
            .offset(y: -UIScreen.main.bounds.size.height*0.3)
            .onTapGesture{
              if(StartFriendsSearch){
                UIApplication.shared.dismissKeyboard()
                StartFriendsSearch = false
                LoadedResults = 0
              }
            }
          }
        }
      }
    }
    .ignoresSafeArea(.keyboard, edges: .all)
  }
}
