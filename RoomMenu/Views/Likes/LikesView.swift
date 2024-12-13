import SwiftUI

struct LikesView: View {
  @Environment(\.presentationMode) var Presentation
  @Environment(\.scenePhase) var scenePhase
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  @EnvironmentObject var appleMusic: AppleMusic
  
  @State private var ShowOfflineOverlay: Bool = false
  @State private var ShowInfoOverlay: Bool = false
  @State private var ShowRemoveOverlay: Bool = false
  @State private var ShowNoAppleMusic: Bool = false
  @State private var ShowAddPlaylistOverlay: Bool = false
  @State private var ShowNoSongPlaylistOverlay: Bool = false
  
  var body: some View {
    ZStack{
      Color("Primary").edgesIgnoringSafeArea(.all)
      
      if(ShowRemoveOverlay){ GeneralOverlay(type: GeneralOverlayType.remove, Show: $ShowRemoveOverlay) }
      if(ShowInfoOverlay){ RoomFeatureInfoOverlay(feature: FeatureViews.likes, Show: $ShowInfoOverlay) }
      if(ShowNoAppleMusic){ GeneralOverlay(type: GeneralOverlayType.noAppleMusic, Show: $ShowNoAppleMusic) }
      if(ShowAddPlaylistOverlay){ GeneralOverlay(type: GeneralOverlayType.addUserPlaylist, Show: $ShowAddPlaylistOverlay) }
      if(ShowNoSongPlaylistOverlay){ GeneralOverlay(type: GeneralOverlayType.addUserPlaylistNoSong, Show: $ShowNoSongPlaylistOverlay) }
      
      ZStack{
        ZStack{
          HStack(spacing: 3){
            ZStack{
              Image(systemName: "heart.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color("Text"))
            }
            .frame(width: 25, alignment: .trailing)
            Text("Likes")
              .font(.system(size: 18, weight: .semibold))
              .foregroundColor(Color("Text"))
            Button(action: { ShowInfoOverlay = true }){
              ZStack{
                Image(systemName: "questionmark.circle.fill")
                  .foregroundColor(Color("Tertiary"))
                  .font(.system(size: 15, weight: .semibold))
              }
              .frame(width: 25, alignment: .center)
            }
          }
          .padding(3)
        }
        .padding(10)
        .frame(width:UIScreen.main.bounds.size.width*0.95, alignment: .topTrailing)
        
        ZStack{
          VStack(spacing: 3){
            HStack(spacing: 5){
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
                  if(appleMusic.Subscription == AppleMusicSubscriptionStatus.active &&
                     appleMusic.CheckedForSubscription){
                    if(user.Likes.isEmpty){
                      ShowNoSongPlaylistOverlay = true
                      return
                    }
                    ShowAddPlaylistOverlay = true
                    Task{ try await appleMusic.AddLikeSongsToPlaylistFromRoom(User: user, Room: room) }
                  }
                  else{ ShowNoAppleMusic = true }
                }
              }){
                Text("ADD")
                  .font(.system(size: 12, weight: .bold))
                  .foregroundColor(Color("Tertiary"))
              }
              .frame(width: UIScreen.main.bounds.size.width*0.15, height: 25)
              .background(RoundedRectangle(cornerRadius: 3).fill(Color("Secondary")))
            }
          }
          .padding(.leading, 20)
        }
        .frame(width: UIScreen.main.bounds.size.width*0.95, alignment: .topLeading)
      }
      .frame(width: UIScreen.main.bounds.size.width*0.95)
      .offset(y: -UIScreen.main.bounds.size.height/2*0.75)
      
      HStack(alignment: .top){
        Button(action: { Presentation.wrappedValue.dismiss() }){
          Image(systemName: "chevron.left")
            .frame(width: UIScreen.main.bounds.size.width*0.2, height: 20, alignment: .leading)
            .font(.system(size: 20, weight: .medium))
            .foregroundColor(Color("Tertiary"))
            .padding(.leading, 10)
        }
      }
      .frame(width: UIScreen.main.bounds.size.width*0.95, alignment: .topLeading)
      .offset(y: -UIScreen.main.bounds.size.height/2*0.85)
      
      if(user.Likes.isEmpty){
        ZStack{
          VStack(spacing: 2){
            HStack(spacing: 4){
              Image(systemName: "heart.fill")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Capsule").opacity(0.6))
              Text("No Likes")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Capsule").opacity(0.6))
            }
            Text("Like songs from the queue or history")
              .font(.system(size: 11, weight: .medium))
              .foregroundColor(Color("Capsule").opacity(0.6))
          }
        }
        .frame(height: UIScreen.main.bounds.size.height, alignment: .center)
      }
      
      
      // MARK: Likes Scroll View
      if(!user.Likes.isEmpty){
        VStack{
          ZStack{
            Spacer()
            ScrollView(showsIndicators: false){
              VStack(alignment: .center, spacing: 11){
                ForEach(Array(Set(user.Likes)).sorted()){ like in
                  if(room.MusicService == "AppleMusic"){
                    AppleMusicLikeCell(Song: like, Remove: $ShowRemoveOverlay)
                  }
                }
                if(user.Likes.count > 7){ Spacer().frame(width: 1, height: UIScreen.main.bounds.size.height*0.08) }
              }
              .frame(width: UIScreen.main.bounds.size.width)
            }
          }
          .frame(height: UIScreen.main.bounds.size.height*0.8, alignment: .bottom)
        }
        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.68, alignment: .top)
      }
    }
    .navigationBarHidden(true)
    // MARK: Handle Likes scenePhase Change
    .onChange(of: scenePhase){ phase in
      room.ScenePhaseHandler(phase: phase, User: user, AppleMusic: appleMusic)
    }
    .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .global)
      .onEnded{ position in
        let HorizontalDrag = position.translation.width
        let VerticalDrag = position.translation.height
        if(abs(HorizontalDrag) > abs(VerticalDrag)){
          if(HorizontalDrag > 0){ Presentation.wrappedValue.dismiss() }
        }
      })
  }
}
