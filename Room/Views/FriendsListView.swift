//
//  FriendsListView.swift
//  Auxr
//
//  Created by Lucas Vogel on 7/2/23.
//

import SwiftUI

struct FriendsListView: View {
    @EnvironmentObject var account: Account
    
    
    var body: some View {
        ZStack{
            ScrollView(showsIndicators: false){
                VStack{
                    // For Each friend in account list of friends you would pass in an account to friend cell view
                    if(account.friends.isEmpty){
                        Spacer()
                        ZStack{
                            Text("No Friends")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color("System"))
                        }
                        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.65,  alignment: .center)
                        Spacer()
                    }
                    else{
                        ForEach(account.friends, id: \.self) { friend_id in
                            FriendCellView(friend_ID: friend_id, AddFriend: false, YourFriend: true)
                        }
                    }
                }
            }
        }
        .frame(maxHeight: UIScreen.main.bounds.size.height*0.65, alignment: .top)
    }
}
