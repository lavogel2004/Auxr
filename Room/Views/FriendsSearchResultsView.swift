//
//  FriendsSearchResultsView.swift
//  Auxr
//
//  Created by Lucas Vogel on 7/5/23.
//

import SwiftUI

struct FriendsSearchResultsView: View {
    @EnvironmentObject var user: User
    
    @Binding var AddFriends: Bool
    @Binding var YourFriends: Bool
    @Binding var SearchResults: [String]
    @Binding var StartFriendsSearch: Bool
    @Binding var Input: String
    
    var body: some View {
        ZStack{
            ScrollView(showsIndicators: false){
                VStack{
                    if(StartFriendsSearch){
                        if(!SearchResults.isEmpty){
                            if(AddFriends){
                                ForEach(0..<SearchResults.count){ i in
                                    if(user.account?.id != SearchResults[i]){
                                        if(user.account?.friends.contains(SearchResults[i]) ?? false){}
                                        else{
                                            FriendCellView(friend_ID: SearchResults[i], AddFriend: AddFriends, YourFriend: YourFriends)
                                        }
                                    }
                                }
                            }
                            if(YourFriends){
                                ForEach(0..<SearchResults.count){ i in
                                    if(user.account?.friends.contains(SearchResults[i]) ?? false){
                                        FriendCellView(friend_ID: SearchResults[i], AddFriend: AddFriends, YourFriend: YourFriends)
                                    } else{}
                                }
                            }
                        }
                        else{
                            ZStack{
                                Text("No Results")
                            }
                            .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.4, alignment: .center)
                        }
                    }
                    if(!StartFriendsSearch){
                        if let friends = user.account?.friends{
                            ForEach(0..<friends.count){ i in
                                let friend_id = friends[i]
                                FriendCellView(friend_ID: friend_id, AddFriend: false, YourFriend: true)
                            }
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.size.width*0.9, height: UIScreen.main.bounds.size.height*0.4, alignment: .top)
            }
        }
        .frame(width: UIScreen.main.bounds.size.width*0.9, height: UIScreen.main.bounds.size.height*0.4, alignment: .top)
        .onTapGesture {
            
        }
    }
}
