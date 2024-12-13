import SwiftUI

enum GeneralOverlayType: String, CaseIterable, Identifiable {
  case remove, copy, update, enablePlayPause, enableSkip, enableRemove, enableVote, enableShare, enableBeHost, noControls, play, pause, skip, queued, like, upvote, downvote, playNow, upNext, noSong, connectUserAppleMusic, noAppleMusic, addUserPlaylist, addUserPlaylistNoSong, maxSongs, inviteChannel, swapHost, swapHostError, saved, alreadySent, addedFriend
  var id: Self { self }
}

struct GeneralOverlay: View {
  @EnvironmentObject var room: Room
  
  let type: GeneralOverlayType
  let TMR = Timer.publish(every: 0.4, on: .current, in: .common).autoconnect()
  
  @Binding var Show: Bool
  
  @State private var DisplayTime: Int = 1
  
  var body: some View {
    ZStack(alignment: .center){
      Rectangle()
        .fill(Color("Secondary").opacity(0.75))
        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        .edgesIgnoringSafeArea(.all)
        .zIndex(5)
        .overlay(
          ZStack{
            if(Show){
              switch(type){
              case GeneralOverlayType.remove:
                HStack(spacing: 5){
                  Image(systemName: "slash.circle.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Red"))
                  Text("Removed")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.26, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.copy:
                HStack(spacing: 5){
                  Image(systemName: "square.fill.on.square.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("Copied")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.26, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.update:
                HStack(spacing: 5){
                  Image(systemName: "key.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("Reset")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.26, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.enablePlayPause:
                HStack(spacing: 5){
                  Image(systemName: "play.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("Enabled")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.26, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.enableSkip:
                HStack(spacing: 5){
                  Image(systemName: "forward.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("Enabled")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.26, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.enableRemove:
                HStack(spacing: 5){
                  Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("Enabled")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.26, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
                
              case GeneralOverlayType.enableVote:
                HStack(spacing: 5){
                  Image(systemName: "chevron.up")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("Enabled")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.26, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
                
              case GeneralOverlayType.enableShare:
                HStack(spacing: 5){
                  ZStack{
                    Image(systemName: "person.fill.badge.plus")
                      .font(.system(size: 14, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                  }
                  Text("Enabled")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.26, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.enableBeHost:
                HStack(spacing: 5){
                  ZStack{
                    Image(systemName: "person.2.wave.2.fill")
                      .font(.system(size: 14, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                  }
                  .offset(x: -3, y: -2.8)
                  Text("Enabled")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.26, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.noControls:
                HStack(spacing: 5){
                  Image(systemName: "play.slash.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("No Shared Control")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.38, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.play:
                HStack(spacing: 5){
                  Image(systemName: "play.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("Playing")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.26, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.pause:
                HStack(spacing: 5){
                  Image(systemName: "pause.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("Paused")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.26, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.skip:
                HStack(spacing: 5){
                  Image(systemName: "forward.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("Skipped")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.26, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.queued:
                HStack(spacing: 5){
                  Image(systemName: "text.line.last.and.arrowtriangle.forward")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("Queued")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.26, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.like:
                HStack(spacing: 5){
                  Image(systemName: "heart.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("Liked")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.26, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.upvote:
                HStack(spacing: 5){
                  Image(systemName: "chevron.up")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(Color("Tertiary"))
                  Text("Voted")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.26, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.downvote:
                HStack(spacing: 5){
                  Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("Tertiary"))
                  Text("Downvoted")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.26, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.playNow:
                HStack(spacing: 5){
                  Image(systemName: "play.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("Playing Now")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.26, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.upNext:
                HStack(spacing: 5){
                  Image(systemName: "arrow.up")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(Color("Tertiary"))
                  Text("Up Next")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.26, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.noSong:
                HStack(spacing: 7){
                  Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("No Song Queued")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.38, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.connectUserAppleMusic:
                HStack(spacing: 7){
                  Image(systemName: "app.connected.to.app.below.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("Connected")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.29, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.noAppleMusic:
                HStack(spacing: 7){
                  Image(systemName: "apple.logo")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("No Apple Music")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.35, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.addUserPlaylist:
                HStack(spacing: 5){
                  Image(systemName: "text.badge.plus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("Added Playlist")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.35, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.addUserPlaylistNoSong:
                HStack(spacing: 7){
                  Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("No Likes")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.29, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.maxSongs:
                HStack(spacing: 7){
                  Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("Max Songs")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.29, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.swapHostError:
                HStack(spacing: 7){
                  Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("Queue Playing")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.35, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.swapHost:
                HStack(spacing: 7){
                  Image(systemName: "person.2.wave.2.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("Host Changed")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.35, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.saved:
                HStack(spacing: 7){
                  ZStack{
                    Image(systemName: "pencil.line")
                      .font(.system(size: 14, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                  }
                  .offset(y: -2.5)
                  Text("Saved")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.26, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.addedFriend:
                HStack(spacing: 7){
                    Image(systemName: "plus")
                      .font(.system(size: 15, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                  ZStack{
                    Text("Added AUXR")
                      .font(.system(size: 13, weight: .semibold))
                      .foregroundColor(Color("Text"))
                  }
                  .offset(x: -1)
                }
                .frame(width: UIScreen.main.bounds.size.width*0.32, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.alreadySent:
                HStack(spacing: 7){
                  ZStack{
                    Image(systemName: "exclamationmark.triangle.fill")
                      .font(.system(size: 14, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                  }
                  Text("Already Sent")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.32, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              case GeneralOverlayType.inviteChannel:
                HStack(spacing: 5){
                  Image(systemName: "paperplane.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text("Invited")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.26, height: UIScreen.main.bounds.size.width*0.1, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
              }
            }
          }
        )
    }
    .frame(width: UIScreen.main.bounds.size.width*0.8, height: UIScreen.main.bounds.size.height*0.08, alignment: .center)
    .zIndex(5)
    .onReceive(TMR){ _ in
      if(DisplayTime > 0){ DisplayTime -= 1 }
      else{  withAnimation(.easeOut(duration: 0.2)){ Show = false }}
    }
  }
}
