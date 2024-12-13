//
//  FriendCellView.swift
//  Auxr
//
//  Created by Lucas Vogel on 7/3/23.
//

import SwiftUI

struct FriendCellView: View {
    @EnvironmentObject var user: User
    
    let friend_ID: String
    let AddFriend: Bool
    let YourFriend: Bool
    
    
    @State var Friend: Account?
    @State var FriendUsername: String = ""
    
    var body: some View {
        VStack{
            HStack{
                if(friend_ID != user.account_id){
                    NavigationLink(destination: SelectedProfileView(friend_ID: friend_ID)){
                        HStack{
                            Image("IMG-3022")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .clipShape(Circle())
                            Text(FriendUsername)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color("Text"))
                        }
                        .frame(width: UIScreen.main.bounds.size.width*0.65, alignment: .leading)
                        .padding(.leading, 10)
                    }
                }
                if(friend_ID == user.account_id){
                    Button(action: {
                    // SelectedView = .profile
                    }){
                        HStack{
                            Image("IMG-3022")
                                .resizable()
                                .frame(width: 35, height: 35)
                                .clipShape(Circle())
                            Text(FriendUsername)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(Color("Text"))
                        }
                        .frame(width: UIScreen.main.bounds.size.width*0.65, alignment: .leading)
                        .padding(.leading, 10)
                    }
                }
                if(AddFriend){
                    Button(action: {
                        Task{
                            try await AccountManager.sendFriendRequest(account_id: friend_ID, user: user)
                        }
                    }){
                        HStack{
                            ZStack(alignment: .center){
                                Capsule()
                                    .foregroundColor(Color("Tertiary"))
                                    .frame(width: 60, height: 25)
                                HStack(alignment: .center){
                                    Image(systemName: "plus")
                                        .foregroundColor(Color("Text"))
                                        .font(.system(size: 10, weight: .medium))
                                        .padding(.leading, 3)
                                    Text("Add")
                                        .foregroundColor(Color("Text"))
                                        .font(.system(size: 12, weight: .medium))
                                        .offset(x: -5)
                                }
                                
                                
                            }
                        }
                        .frame(width: UIScreen.main.bounds.size.width*0.15, alignment: .trailing)
                    }
                }
                if(YourFriend){
                    Button(action: {}){
                        HStack{
                            ZStack(alignment: .center){
                                Capsule()
                                    .foregroundColor(Color("Tertiary"))
                                    .frame(width: 60, height: 25)
                                HStack(alignment: .center){
                                    Image(systemName: "paperplane.fill")
                                        .foregroundColor(Color("Text"))
                                        .font(.system(size: 10, weight: .medium))
                                        .padding(.leading, 3)
                                    Text("Invite")
                                        .foregroundColor(Color("Text"))
                                        .font(.system(size: 12, weight: .medium))
                                        .offset(x: -5)
                                }
                                
                                
                            }
                        }
                        .frame(width: UIScreen.main.bounds.size.width*0.15, alignment: .trailing)
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.size.width*0.9, height: UIScreen.main.bounds.size.height*0.08, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")).shadow(color: Color("Shadow"), radius: 1))
//            Divider()
//                .frame(width: UIScreen.main.bounds.size.width*0.9, height: 1.0)
//                .background(Color("System").opacity(0.2))
        }
        .onAppear{
            Task{
                do {
                    Friend = try await AccountManager.getAccount(account_id: friend_ID)
                    FriendUsername = Friend?.username ?? "Username"
                } catch {
                    print("Error getting friend")
                }
            }
        }
    }
}
