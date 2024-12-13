//
//  FriendsView.swift
//  Auxr
//
//  Created by Justin Russo on 6/30/23.
//

import SwiftUI
struct FriendsView: View {
    @EnvironmentObject var user: User
    
    @Binding var ShowFriendsSubSearch: Bool
    
    @State var Input: String = ""
    @State var SearchResults: [String] = []
    @State var StartFriendsSearch: Bool = false
    
    @Environment(\.presentationMode) var Presentation
    var body: some View {
        ZStack{
                VStack{
                    HStack{
                        Text("Friends")
                            .font(.system(size: 25, weight: .medium))
                            .foregroundColor(Color("Text"))
                    }
                    .frame(width: UIScreen.main.bounds.size.width*0.93, alignment: .center)
                    .padding(.bottom, 5)
                    ZStack{
                        FriendsSearchBarView(Input: $Input)
                            .onTapGesture {
                                ShowFriendsSubSearch = true
                            }
                            .onSubmit{
                                let networkStatus: NetworkStatus = CheckNetworkStatus()
                                if(networkStatus == NetworkStatus.reachable){
                                    StartFriendsSearch = true
                                    ShowFriendsSubSearch = true
                                    Task{
                                        guard let results: [Account]? = try await AccountManager.searchAccounts(query_string: Input) else{
                                            print("Error")
                                        }
                                        if(!Input.isEmpty){
                                            for res in results ?? [Account]() {
                                                SearchResults.append(res.id)
                                            }
                                        }
                                    }
                                }
                            }
                    }
                    .frame(width: UIScreen.main.bounds.size.width*0.9, height: UIScreen.main.bounds.size.height*0.04)
                    .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary").opacity(0.75)))
                    .padding(.bottom, 10)
                        if(!ShowFriendsSubSearch){
                            FriendsListView()
                        }
                    if(ShowFriendsSubSearch){
                        FriendsSubSearchView(Input: $Input, SearchResults: $SearchResults, StartFriendsSearch: $StartFriendsSearch)
                    }
                }
        }
        .frame(maxHeight: UIScreen.main.bounds.size.height, alignment: .top)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
