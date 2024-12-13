import SwiftUI

enum ProfileViewFilter: String, CaseIterable, Identifiable {
  case likes, rooms
  var id: Self { self }
}

struct ProfileView: View {
  @AppStorage("isDarkMode") private var isDarkMode = false
  
  @EnvironmentObject var router: Router
  @EnvironmentObject var user: User
  @EnvironmentObject var account: AuxrAccount
  @EnvironmentObject var appleMusic: AppleMusic
  
  @State private var ProfilePicture: UIImage? = nil
  @State private var ShowRemoveOverlay: Bool = false
  @State private var ShowAddPlaylistOverlay: Bool = false
  @State private var ShowNoSongPlaylistOverlay: Bool = false
  @State private var ShowNoAppleMusic: Bool = false
  @State private var SongPlaying: Bool = false
  
  var body: some View {
    ZStack{
      Color("LightGray").edgesIgnoringSafeArea(.all)
      if(ShowRemoveOverlay){ GeneralOverlay(type: GeneralOverlayType.remove, Show: $ShowRemoveOverlay) }
      else if(ShowAddPlaylistOverlay){ GeneralOverlay(type: GeneralOverlayType.addUserPlaylist, Show: $ShowAddPlaylistOverlay) }
      else if(ShowNoSongPlaylistOverlay){ GeneralOverlay(type: GeneralOverlayType.addUserPlaylistNoSong, Show: $ShowNoSongPlaylistOverlay) }
      else if(ShowNoAppleMusic){ GeneralOverlay(type: GeneralOverlayType.noAppleMusic, Show: $ShowNoAppleMusic) }
      ZStack{
        NavigationLink(destination: ProfileSettingsView().environmentObject(account)){
          Image(systemName: "gearshape.fill")
            .foregroundColor(Color("Tertiary"))
            .font(.system(size: 22, weight: .bold))
        }
      }
      .padding(10)
      .frame(width:UIScreen.main.bounds.size.width*0.95, alignment: .topTrailing)
      .offset(y: -UIScreen.main.bounds.size.height*0.435)
      .zIndex(2)
      VStack(spacing: 0){
        VStack(spacing: 10){
          HStack(spacing: UIScreen.main.bounds.size.width*0.1){
            VStack(spacing: 5){
              ZStack{
                if let ProfilePicture = ProfilePicture{
                  Image(uiImage: ProfilePicture)
                    .resizable()
                    .clipShape(Circle())
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.size.width*0.25, height: UIScreen.main.bounds.size.width*0.25)
                    .background(Circle().fill(Color("Capsule").opacity(0.3)))
                }
                else{
                  Image(systemName: "person.fill")
                    .font(.system(size: 25, weight: .bold))
                    .clipShape(Circle())
                    .foregroundColor(Color("Capsule").opacity(0.6))
                    .frame(width: UIScreen.main.bounds.size.width*0.25, height: UIScreen.main.bounds.size.width*0.25)
                    .background(Circle().fill(Color("Capsule").opacity(0.3)))
                }
              }
              .frame(width: UIScreen.main.bounds.size.width*0.18, alignment: .center)
              ZStack{
                Text(account.DisplayName)
                  .font(.system(size: 13, weight: .regular))
                  .foregroundColor(Color("Text"))
              }
              .frame(width: UIScreen.main.bounds.size.width*0.18, height: 30, alignment: .center)
              .offset(y: -5)
            }
            VStack(spacing: 10){
              ZStack{
                Text(account.Username)
                  .font(.system(size: 25, weight: .bold))
                  .foregroundColor(Color("Text"))
              }
              .frame(width: UIScreen.main.bounds.size.width, height: 30, alignment: .top)
              .offset(y: -UIScreen.main.bounds.size.height*0.02)
              HStack(spacing: 5){
                NavigationLink(destination: FriendsProfileView(accountID: account.ID).environmentObject(account)){
                  VStack(spacing: 2){
                    Text(String(account.Friends.count))
                      .font(.system(size: 15, weight: .semibold))
                      .foregroundColor(Color("Text"))
                      .frame(height: 20)
                    Text("Friends")
                      .font(.system(size: 14, weight: .medium))
                      .foregroundColor(Color("Text"))
                      .frame(height: 20)
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .bottom)
                }
                VStack(spacing: 2){
                  Text(String(account.Points))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("Text"))
                  Text("Points")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("Text"))
                    .frame(height: 20)
                }
                .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .bottom)
                VStack(spacing: 2){
                  Text(String(account.Likes.count))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("Text"))
                  Text("Likes")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("Text"))
                    .frame(height: 20)
                }
                .frame(width: UIScreen.main.bounds.size.width*0.2, alignment: .bottom)
              }
              .frame(width: UIScreen.main.bounds.size.width*0.55, alignment: .center)
              NavigationLink(destination: EditProfileView(ProfilePicture: $ProfilePicture).environmentObject(account)){
                ZStack{
                  Text("Edit Profile")
                    .foregroundColor(Color("Label"))
                    .font(.system(size: 14, weight: .medium))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.55, height: 20, alignment: .center)
                .padding(5)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Tertiary")).shadow(color: Color("Shadow"), radius: 1))
              }
              .frame(width: UIScreen.main.bounds.size.width*0.55, height: 20, alignment: .leading)
            }
            .frame(width: UIScreen.main.bounds.size.width*0.55, height: UIScreen.main.bounds.size.height*0.2, alignment: .center)
          }
        }
        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.38, alignment: .bottom)
        .padding(.bottom, UIScreen.main.bounds.size.height*0.01)
        .background(Color("Primary"))
        .offset(y: -UIScreen.main.bounds.size.height*0.2)
        .zIndex(2)
        ZStack{
          VStack{
            HStack{
              HStack(spacing: 20){
                VStack(spacing: 10){
                  Image(systemName: "heart.fill")
                    .foregroundColor(Color("Tertiary"))
                    .font(.system(size: 20, weight: .medium))
                  RoundedRectangle(cornerRadius: 3)
                    .fill(Color("Tertiary"))
                    .frame(width: 20, height: 2)
                }
                ZStack{
                  if(SongPlaying){ AudioVisualizer() }
                }
                .offset(y: -1.5)
              }
              .frame(width: UIScreen.main.bounds.size.width*0.275, alignment: .leading)
              if(account.AppleMusicConnected){
                HStack(spacing: 10){
                  ZStack{
                    Image("AppleMusicIcon2")
                      .resizable()
                      .aspectRatio(contentMode: .fit)
                      .frame(height: 25)
                      .padding(.bottom, 5)
                  }
                  .offset(y: 1.5)
                  Button(action: {
                    withAnimation(.easeIn(duration: 0.2)){
                      if(account.AppleMusicConnected){
                        if(account.Likes.isEmpty){
                          ShowNoSongPlaylistOverlay = true
                          return
                        }
                        ShowAddPlaylistOverlay = true
                        Task{ try await appleMusic.AddLikeSongsToPlaylistFromAccount(User: user, Account: account) }
                      }
                      else{ ShowNoAppleMusic = true }
                    }
                  }){
                    Text("ADD")
                      .font(.system(size: 12, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                  }
                  .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
                  .background(RoundedRectangle(cornerRadius: 3).fill(Color((isDarkMode) ? "Secondary" : "Primary")))
                }
                .offset(x: UIScreen.main.bounds.size.width*0.0325)
              }
            }
            .frame(width: UIScreen.main.bounds.size.width*0.8, alignment: .leading)
            .padding(.leading, 10)
            .padding(.bottom, UIScreen.main.bounds.size.height*0.01)
            
            if(account.Likes.isEmpty){
              VStack(spacing: 2){
                HStack(spacing: 4){
                  Image(systemName: "heart.fill")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("Capsule").opacity(0.6))
                  Text("No Likes")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("Capsule").opacity(0.6))
                }
                Text("Start liking songs from your sessions")
                  .font(.system(size: 11, weight: .medium))
                  .foregroundColor(Color("Capsule").opacity(0.6))
              }
              .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.48, alignment: .center)
            }
            else{
              ZStack{
                ScrollView(showsIndicators: false){
                  Spacer().frame(height: 1)
                  VStack(alignment: .center, spacing: 20){
                    ForEach(account.Likes.sorted()){ song in
                      ProfileLikeSongCell(Song: song, profileID: account.ID, Remove: $ShowRemoveOverlay, SongPlaying: $SongPlaying)
                    }
                    if(account.Likes.count > 5){
                      Spacer().frame(width: 1, height: UIScreen.main.bounds.size.height*0.02)
                    }
                  }
                  .frame(width: UIScreen.main.bounds.size.width)
                }
                .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.55, alignment: .top)
              }
            }
          }
        }
        .offset(y: -UIScreen.main.bounds.size.height*0.18)
        .zIndex(2)
      }
      .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.83, alignment: .top)
    }
    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, alignment: .center)
    .onAppear{
      Task{
        ProfilePicture = try await AccountManager.getProfilePicture(account_id: account.ID)
      }
    }
  }
}
