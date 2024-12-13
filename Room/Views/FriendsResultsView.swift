//
//  FriendsSubSearchView.swift
//  Auxr
//
//  Created by Lucas Vogel on 7/2/23.
//

import SwiftUI

struct FriendsSubSearchView: View {
    
    @EnvironmentObject var user: User
    
    @Binding var Input: String
    @Binding var SearchResults: [String]
    @Binding var StartFriendsSearch: Bool
    
    @State var AddFriends: Bool = true
    @State var YourFriends: Bool = false
    
    var body: some View {
        ZStack{
            VStack{
                HStack{
                    Button(action: {
                        AddFriends = true
                        YourFriends = false
                    }){
                        HStack(alignment: .center)
                        {
                            if(AddFriends){
                                Text("Add Friends")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color("Tertiary"))
                            }
                            if(!AddFriends){
                                Text("Add Friends")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color("Text"))
                            }
                        }
                        .frame(width: UIScreen.main.bounds.size.width*0.4)
                    }
                    Divider()
                        .frame(height: 50)
                        .background(Color("System").opacity(0.2))
                    Button(action: {
                        YourFriends = true
                        AddFriends = false
                    }){
                        HStack(alignment: .center){
                            if(YourFriends){
                                Text("My Friends")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color("Tertiary"))
                            }
                            if(!YourFriends){
                                Text("My Friends")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color("Text"))
                            }
                        }
                        .frame(width: UIScreen.main.bounds.size.width*0.4)
                    }
                }
                .frame(width: UIScreen.main.bounds.size.width*0.93, alignment: .center)
                Divider()
                    .frame(width: UIScreen.main.bounds.size.width*0.9, height: 1.0)
                    .background(Color("System").opacity(0.2))
                if(StartFriendsSearch || YourFriends){
                    FriendsSearchResultsView(AddFriends: $AddFriends, YourFriends: $YourFriends, SearchResults: $SearchResults, StartFriendsSearch: $StartFriendsSearch, Input: $Input)
                }
                else{
                    if(AddFriends){
                        ZStack{
                            Text("Find new music lovers")
                        }
                        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.4, alignment: .center)
                    }
                }
                
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.size.width*0.9, maxHeight: UIScreen.main.bounds.size.height*0.65, alignment: .top)
    }
}
