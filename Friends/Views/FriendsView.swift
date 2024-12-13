import SwiftUI

enum FriendsFilter: String, CaseIterable, Identifiable {
  case userFriends, addFriends
  var id: Self { self }
}

struct FriendsView: View {
  @Environment(\.presentationMode) var Presentation
  @EnvironmentObject var user: User
  @EnvironmentObject var account: AuxrAccount
  
  @Binding var Filter: FriendsFilter
  
  @State private var SearchInput: String = ""
  @State var SearchResults: [AuxrAccount] = []
  @State private var StartFriendsSearch: Bool = false
  @State private var ShowInfoOverlay: Bool = false
  @State private var Loading: Bool = false
  @State private var LoadedResults: Int = 0
  @State private var Completed: Bool = false
  @State private var SelectedFriendID: String = ""
  @State private var RemoveFriend: Bool = false
  @State private var RemoveFriendResponse: Bool = false
  @State private var CancelFriendRequest: Bool = false
  @State private var CancelFriendRequestResponse: Bool = false
  @State private var DenyFriendRequest: Bool = false
  @State private var DenyFriendRequestResponse: Bool = false
  @State private var DisplayResults: [String] = []
  @State private var PendingRequests: [String] = []
  @State private var AddFriend: Bool = false
  @State private var ShowRemoveOverlay: Bool = false
  @State private var ShowOfflineOverlay: Bool = false
  @State private var reload: Bool = true
  
  var body: some View {
    ZStack{
      if(AddFriend){ GeneralOverlay(type: GeneralOverlayType.addedFriend, Show: $AddFriend) }
      else if(RemoveFriend){ AccountOverlay(type: AccountOverlayType.removeFriend, Show: $RemoveFriend, Response: $RemoveFriendResponse) }
      else if(CancelFriendRequest){ AccountOverlay(type: AccountOverlayType.cancelFriendRequest, Show: $CancelFriendRequest, Response: $CancelFriendRequestResponse) }
      else if(DenyFriendRequest){ AccountOverlay(type: AccountOverlayType.denyFriendRequest, Show: $DenyFriendRequest, Response: $DenyFriendRequestResponse) }
      else if(ShowRemoveOverlay){ GeneralOverlay(type: GeneralOverlayType.remove, Show: $ShowRemoveOverlay) }
      
      Spacer().frame(height: 10)
      ZStack{
        HStack(spacing: UIScreen.main.bounds.size.width*0.3){
          Text("Friends")
            .font(.system(size: 30, weight: .semibold))
            .foregroundColor(Color("Text"))
          //          Button(action: { ShowInfoOverlay = true }){
          //            ZStack{
          //              Image(systemName: "questionmark.circle.fill")
          //                .foregroundColor(Color("Tertiary"))
          //                .font(.system(size: 15, weight: .semibold))
          //            }
          //            .offset(y: 3)
          //            .frame(width: 30, alignment: .center)
          //          }
          ShareLink(item: "https://apps.apple.com/us/app/auxr-share-the-aux/id1667666452", message: Text(String(account.Username + " invited you to be their friend on AUXR! Download now in the App Store for all things social music!"))){
            HStack(spacing: 3){
              Text("Add More")
                .foregroundColor(Color("Tertiary"))
                .font(.system(size: 14, weight: .bold))
                .frame(height: 30, alignment: .center)
              Image(systemName: "plus")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color("Tertiary"))
                .frame(height: 30, alignment: .center)
            }
            .frame(width: UIScreen.main.bounds.size.width*0.3, height: 30, alignment: .bottomTrailing)
            .offset(x: UIScreen.main.bounds.size.width*0.03, y: 7)
          }
        }
        .padding(3)
      }
      .padding(10)
      .frame(width:UIScreen.main.bounds.size.width*0.95, alignment: .topLeading)
      .offset(y: -UIScreen.main.bounds.size.height*0.4)
      ZStack{
        FriendsSearchBarView(Input: $SearchInput)
          .onTapGesture {
            StartFriendsSearch = true
          }
          .onChange(of: SearchInput, perform: { newValue in
            StartFriendsSearch = true
            let networkStatus: NetworkStatus = CheckNetworkStatus()
            if(networkStatus == NetworkStatus.reachable){
              Task{ SearchResults = try await AccountManager.searchAccounts(query_string: newValue) }
              StartFriendsSearch = true
              if(StartFriendsSearch){
                if let i: Int = account.FriendRequests.firstIndex(where: { $0.Sender == user.pai }){
                  DisplayResults = DisplayResults.filter { $0 == account.FriendRequests[i].Sender }
                }
              }
              if(Filter == FriendsFilter.addFriends){
                for res in SearchResults{
                  if(res.ID != user.pai){
                    if(!account.Friends.contains(where: { $0.ID == res.ID })){
                      if(!DisplayResults.contains(res.ID)){ DisplayResults.append(res.ID) }
                    }
                  }
                }
              }
              if(Filter == FriendsFilter.userFriends){
                DisplayResults = []
                for res in SearchResults{
                  if(account.Friends.contains(where: { $0.ID == res.ID })){
                    if(!DisplayResults.contains(res.ID)){ DisplayResults.append(res.ID) }
                  }
                }
              }
            }
            else{ ShowOfflineOverlay = false }
            if(SearchInput.isEmpty){
              if(Filter == FriendsFilter.addFriends){
                DisplayResults = []
                for pending in account.FriendRequests{
                  if(pending.Receiver != user.pai){
                    if(!account.FriendRequests.contains(where: { $0.ID == pending.Receiver })){
                      if(!DisplayResults.contains(pending.Receiver)){ DisplayResults.append(pending.Receiver) }
                    }
                  }
                }
              }
              if(Filter == FriendsFilter.userFriends){
                DisplayResults = []
                for friend in account.Friends{ if(!DisplayResults.contains(friend.ID)){ DisplayResults.append(friend.ID) } }
              }
            }
          })
          .onSubmit { Loading = true }
      }
      .offset(y: -UIScreen.main.bounds.size.height*0.345)
      
      HStack{
        Button(action: {
          UIApplication.shared.dismissKeyboard()
          LoadedResults = 0
          Loading = true
          Completed = false
          Filter = FriendsFilter.addFriends
          DisplayResults = []
          if(!SearchInput.isEmpty){
            Task{
              SearchResults = try await AccountManager.searchAccounts(query_string: SearchInput)
              for res in SearchResults{
                if(res.ID != user.pai){
                  if(!account.Friends.contains(where: { $0.ID == res.ID })){
                    if(!DisplayResults.contains(res.ID)){ DisplayResults.append(res.ID) }
                  }
                }
              }
            }
          }
          else{
            DisplayResults = []
            for pending in account.FriendRequests{ if(!DisplayResults.contains(pending.Receiver)){ DisplayResults.append(pending.Receiver) } }
          }
        }){
          VStack(spacing: 3){
            HStack(spacing: 4){
              Image(systemName: "magnifyingglass")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color("Text"))
              Text("Find AUXRs")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color("Text"))
            }
            ZStack{
              RoundedRectangle(cornerRadius: 3)
                .fill((Filter == FriendsFilter.addFriends) ? Color("Tertiary") : Color.clear)
                .frame(width: String("Find Friends").widthOfString(usingFont: UIFont.systemFont(ofSize: 19)), height: 2)
            }
            .offset(x: 1.5)
          }
          .frame(width: UIScreen.main.bounds.size.width*0.4)
        }
        Button(action: {
          UIApplication.shared.dismissKeyboard()
          LoadedResults = 0
          Filter = FriendsFilter.userFriends
          Loading = true
          Completed = false
          Task{
            DisplayResults = []
            SearchResults = try await AccountManager.searchAccounts(query_string: SearchInput)
            if(Filter == FriendsFilter.userFriends){
              if(!SearchResults.isEmpty || !SearchInput.isEmpty){
                for res in SearchResults{
                  if(account.Friends.contains(where: { $0.ID == res.ID })){
                    if(!DisplayResults.contains(res.ID)){ DisplayResults.append(res.ID) }
                  }
                }
              }
              else{
                DisplayResults = []
                for friend in account.Friends{ if(!DisplayResults.contains(friend.ID)){ DisplayResults.append(friend.ID) } }
              }
            }
          }
        }){
          VStack(spacing: 3){
            HStack(spacing: 4){
              Image(systemName: "person.3.fill")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color("Text"))
              Text("Friends")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color("Text"))
            }
            ZStack{
              RoundedRectangle(cornerRadius: 3)
                .fill((Filter == FriendsFilter.userFriends) ? Color("Tertiary") : Color.clear)
                .frame(width: String("Friends").widthOfString(usingFont: UIFont.systemFont(ofSize: 27)), height: 2)
            }
            .offset(x: 1.5)
          }
          .frame(width: UIScreen.main.bounds.size.width*0.4)
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.75, alignment: .center)
      .offset(y: -UIScreen.main.bounds.size.height*0.28)
      
      ZStack{
        FriendsSearchResultsView(Loading: $Loading, LoadedResults: $LoadedResults, Completed: $Completed, StartFriendsSearch: $StartFriendsSearch, Filter: $Filter, SelectedFriend: $SelectedFriendID, DisplayResults: $DisplayResults, AddFriend: $AddFriend, RemoveFriend: $RemoveFriend, CancelFriendRequest: $CancelFriendRequest)
          .onAppear{
            Task{
              if(StartFriendsSearch){
                if(Filter == FriendsFilter.addFriends){
                  DisplayResults = []
                  if(!SearchInput.isEmpty){
                    SearchResults = try await AccountManager.searchAccounts(query_string: SearchInput)
                    for res in SearchResults{
                      if(!DisplayResults.contains(res.ID)){ DisplayResults.append(res.ID) }
                    }
                  }
                  else{
                    DisplayResults = []
                    for pending in account.FriendRequests{ if(!DisplayResults.contains(pending.Receiver)){ DisplayResults.append(pending.Receiver) } }
                  }
                }
                if(Filter == FriendsFilter.userFriends){
                  DisplayResults = []
                  SearchResults = try await AccountManager.searchAccounts(query_string: SearchInput)
                  if(Filter == FriendsFilter.userFriends){
                    if(!SearchResults.isEmpty || !SearchInput.isEmpty){
                      for res in SearchResults{
                        if(account.Friends.contains(where: { $0.ID == res.ID })){
                          if(!DisplayResults.contains(res.ID)){ DisplayResults.append(res.ID) }
                        }
                      }
                    }
                    else{
                      DisplayResults = []
                      for friend in account.Friends{ if(!DisplayResults.contains(friend.ID)){ DisplayResults.append(friend.ID) } }
                    }
                  }
                }
              }
              else{
                DisplayResults = []
                for friend in account.Friends{ if(!DisplayResults.contains(friend.ID)){ DisplayResults.append(friend.ID) } }
              }
            }
          }
          .offset(y: UIScreen.main.bounds.size.height*0.08)
      }
      
      if(CancelFriendRequestResponse ||
         RemoveFriendResponse ||
         DenyFriendRequestResponse){
        Spacer().frame(height: 0).onAppear{
          Task{
            if(CancelFriendRequestResponse){
              if let i: Int = account.FriendRequests.firstIndex(where: {
                $0.Receiver == SelectedFriendID }){
                let request: AuxrRequest = account.FriendRequests[i]
                try await AccountManager.denyFriendRequest(request: request)
              }
            }
            
            if(RemoveFriendResponse){
              try await AccountManager.removeFriend(friendID: SelectedFriendID)
            }
            
            if(DenyFriendRequestResponse){
              if let i: Int = account.FriendRequests.firstIndex(where: {
                $0.Receiver == account.ID }){
                let request: AuxrRequest = account.FriendRequests[i]
                try await AccountManager.denyFriendRequest(request: request)
              }
            }
            
            if(Filter == FriendsFilter.addFriends){
              DisplayResults = []
              if(!SearchInput.isEmpty){
                SearchResults = try await AccountManager.searchAccounts(query_string: SearchInput)
                for res in SearchResults{
                  if(!account.Friends.contains(where: { $0.ID == res.ID })){
                    if(!DisplayResults.contains(res.ID)){ DisplayResults.append(res.ID) }
                  }
                }
              }
              else{
                DisplayResults = []
                for pending in account.FriendRequests{
                  if(pending.Receiver != user.pai){
                    if(!DisplayResults.contains(pending.Receiver)){
                      DisplayResults.append(pending.Receiver)
                    }
                  }
                }
              }
            }
            if(Filter == FriendsFilter.userFriends){
              DisplayResults = []
              SearchResults = try await AccountManager.searchAccounts(query_string: SearchInput)
              if(Filter == FriendsFilter.userFriends){
                if(!SearchResults.isEmpty || !SearchInput.isEmpty){
                  for res in SearchResults{
                    if(account.Friends.contains(where: { $0.ID == res.ID })){
                      if(!DisplayResults.contains(res.ID)){ DisplayResults.append(res.ID) }
                    }
                  }
                }
                else{
                  DisplayResults = []
                  for friend in account.Friends{ if(!DisplayResults.contains(friend.ID)){ DisplayResults.append(friend.ID) } }
                }
              }
            }
            if(CancelFriendRequestResponse){ CancelFriendRequestResponse = false }
            if(RemoveFriendResponse){ RemoveFriendResponse = false }
            if(DenyFriendRequest){ DenyFriendRequest = false }
            ShowRemoveOverlay = true
          }
        }
      }
      if(Loading){ SearchLoaderView(Searching: $Loading, Completed: $Completed, length: 0.5)
          .frame(maxWidth: UIScreen.main.bounds.size.width, maxHeight: UIScreen.main.bounds.height*0.75, alignment: .bottom)
      }
    }
    .frame(maxHeight: UIScreen.main.bounds.size.height)
    .ignoresSafeArea(.keyboard, edges: .all)
    .onAppear{
      Loading = true
      Filter = FriendsFilter.userFriends
      Task{
        if(StartFriendsSearch){
          if(Filter == FriendsFilter.addFriends){
            DisplayResults = []
            if(!SearchInput.isEmpty){
              SearchResults = try await AccountManager.searchAccounts(query_string: SearchInput)
              for res in SearchResults{
                if(!DisplayResults.contains(res.ID)){ DisplayResults.append(res.ID) }
              }
            }
            else{
              DisplayResults = []
              for pending in account.FriendRequests{ if(!DisplayResults.contains(pending.Receiver)){ DisplayResults.append(pending.Receiver) } }
            }
          }
          if(Filter == FriendsFilter.userFriends){
            DisplayResults = []
            SearchResults = try await AccountManager.searchAccounts(query_string: SearchInput)
            if(Filter == FriendsFilter.userFriends){
              if(!SearchResults.isEmpty || !SearchInput.isEmpty){
                for res in SearchResults{
                  if(account.Friends.contains(where: { $0.ID == res.ID })){
                    if(!DisplayResults.contains(res.ID)){ DisplayResults.append(res.ID) }
                  }
                }
              }
              else{
                DisplayResults = []
                for friend in account.Friends{ if(!DisplayResults.contains(friend.ID)){ DisplayResults.append(friend.ID) } }
              }
            }
          }
        }
        else{
          DisplayResults = []
          for friend in account.Friends{ if(!DisplayResults.contains(friend.ID)){ DisplayResults.append(friend.ID) } }
        }
      }
    }
    .onTapGesture {
      if(StartFriendsSearch){
        UIApplication.shared.dismissKeyboard()
        StartFriendsSearch = false
        LoadedResults = 0
      }
    }
  }
}
