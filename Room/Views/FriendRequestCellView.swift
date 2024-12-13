//
//  FriendRequestCellView.swift
//  Auxr
//
//  Created by Lucas Vogel on 7/6/23.
//

import SwiftUI

struct FriendRequestCellView: View {
    @EnvironmentObject var user: User
    
    let requester_ID: String
    let Request: Request

    @Binding var Accepted: Bool
    
    @State var Friend: Account?
    @State var FriendUsername: String = ""
    
    var body: some View {
        VStack{
            HStack{
                NavigationLink(destination: SelectedProfileView(friend_ID: requester_ID)){
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
                    .offset(x: -8)
                }
                Button(action: {
                    Task{
                        try await AccountManager.acceptFriendRequest(request: Request)
                        Accepted = true
                    }
                }){
                    HStack{
                        ZStack(alignment: .center){
                            Capsule()
                                .foregroundColor(Color("Tertiary"))
                                .frame(width: 75, height: 25)
                            HStack(alignment: .center){
                                Image(systemName: "plus")
                                    .foregroundColor(Color("Text"))
                                    .font(.system(size: 10, weight: .medium))
                                    .padding(.leading, 3)
                                Text("Accept")
                                    .foregroundColor(Color("Text"))
                                    .font(.system(size: 12, weight: .medium))
                                    .offset(x: -5)
                            }
                        }
                    }
                    .frame(width: UIScreen.main.bounds.size.width*0.15, alignment: .trailing)
                }
            }
            .frame(width: UIScreen.main.bounds.size.width*0.9, height: UIScreen.main.bounds.size.height*0.065)
            Divider()
                .frame(width: UIScreen.main.bounds.size.width*0.9, height: 1.0)
                .background(Color("System").opacity(0.2))
        }
        .onAppear{
            Task{
                guard let SelectedFriend: Account? = try await AccountManager.getAccount(account_id: requester_ID) else{
                    print("Error")
                }
                Friend = SelectedFriend
                FriendUsername = Friend?.username ?? "Username"
            }
        }
    }
}
