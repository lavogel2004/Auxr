import SwiftUI

struct FriendsProfileView: View {
  @Environment(\.presentationMode) var Presentation
  @EnvironmentObject var account: AuxrAccount
  
  let accountID: String
  @State var friendAccount: AuxrAccount?
  var body: some View {
    ZStack{
      Color("Primary").edgesIgnoringSafeArea(.all)
      HStack(alignment: .top){
        Button(action: { Presentation.wrappedValue.dismiss() }){
          Image(systemName: "chevron.left")
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(Color("Tertiary"))
            .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .leading)
            .padding(.leading, 10)
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.95, alignment: .topLeading)
      .offset(y: -UIScreen.main.bounds.size.height/2*0.85)
      
      ZStack{
        HStack(spacing: 4){
          Image(systemName: "person.3.fill")
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Color("Text"))
          Text("Friends")
            .font(.system(size: 20, weight: .bold))
            .foregroundColor(Color("Text"))
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .trailing)
      .offset(y: -UIScreen.main.bounds.size.height/2*0.8)
      .zIndex(2)
      
      if(friendAccount?.Friends.isEmpty ?? false){
        VStack(spacing: 2){
          HStack(spacing: 4){
            Text("No Friends")
              .font(.system(size: 15, weight: .medium))
              .foregroundColor(Color("Capsule").opacity(0.6))
          }
        }
        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.7, alignment: .top)
      }
      else{
        VStack{
          ZStack{
            ScrollView(showsIndicators: false){
              Spacer().frame(height: 1)
              VStack(alignment: .center, spacing: 11){
                if(account.Friends.contains(where: { $0.ID == accountID })){
                  ProfileFriendCell(friendID: account.ID)
                }
                ForEach(friendAccount?.Friends.sorted() ?? [] ){ friend in
                  if(account.Friends.contains(where: { $0.ID == friend.ID })){
                    ProfileFriendCell(friendID: friend.ID)
                  }
                }
                ForEach(friendAccount?.Friends.sorted() ?? [] ){ friend in
                  if(friend.ID != account.ID){
                    if(!account.Friends.contains(where: { $0.ID == friend.ID })){
                      ProfileFriendCell(friendID: friend.ID)
                    }
                  }
                }
                if(friendAccount?.Friends.count ?? 0 > 5){
                  Spacer().frame(width: 1, height: UIScreen.main.bounds.size.height*0.02)
                }
              }
              .frame(width: UIScreen.main.bounds.size.width)
            }
            .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.85, alignment: .top)
          }
          .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, alignment: .top)
          .offset(y: UIScreen.main.bounds.size.height*0.125)
        }
      }
    }
    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, alignment: .top)
    .navigationBarHidden(true)
    .onAppear{
      Task{
        friendAccount = try await AccountManager.getAccount(account_id: accountID)
      }
    }
    .gesture(DragGesture(minimumDistance: 25, coordinateSpace: .global)
      .onEnded{ position in
        let HorizontalDrag = position.translation.width
        let VerticalDrag = position.translation.height
        if(abs(HorizontalDrag) > abs(VerticalDrag)){
          if(HorizontalDrag > 0){ Presentation.wrappedValue.dismiss() }
        }
      })
  }
}
