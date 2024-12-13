import SwiftUI

struct RoomOnboardingErrorView: View {
  @Binding var Error: RoomOnboardingError
  
  var body: some View {
    ZStack{
      switch(Error){
      case RoomOnboardingError.nicknameInput:
        ZStack{
          VStack(spacing: 4){
            HStack(alignment: .center, spacing: 4){
              Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Red"))
              Text("Invalid Display Name")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Red"))
            }
            Text("Please enter a valid Display Name")
              .font(.system(size: 11, weight: .medium))
              .foregroundColor(Color("Text"))
          }
        }
        
      case RoomOnboardingError.roomInput:
        ZStack{
          VStack(spacing: 4){
            HStack(alignment: .center, spacing: 4){
              Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Red"))
              Text("Invalid Playlist Name")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Red"))
            }
            Text("Please enter a valid Playlist Name")
              .font(.system(size: 11, weight: .medium))
              .foregroundColor(Color("Text"))
          }
        }
        
      case RoomOnboardingError.passwordInput:
        ZStack{
          VStack(spacing: 4){
            HStack(alignment: .center, spacing: 4){
              Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Red"))
              Text("Invalid Playlist Passcode")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Red"))
            }
            Text("Please enter a valid Playlist Passcode")
              .font(.system(size: 11, weight: .medium))
              .foregroundColor(Color("Text"))
          }
        }
        
      case RoomOnboardingError.roomLimit:
        ZStack{
          VStack(spacing: 4){
            HStack(alignment: .center, spacing: 4){
              Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Red"))
              Text("Playlist Full")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Red"))
            }
            Text("Maximum 100 listeners")
              .font(.system(size: 11, weight: .medium))
              .foregroundColor(Color("Text"))
          }
        }
        
      case RoomOnboardingError.getRoom:
        ZStack{
          VStack(spacing: 4){
            HStack(alignment: .center, spacing: 4){
              Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Red"))
              Text("Unable To Join Playlist")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Red"))
            }
          }
        }
        
      case RoomOnboardingError.joinRoom:
        ZStack{
          VStack(spacing: 4){
            HStack(alignment: .center, spacing: 4){
              Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Red"))
              Text("Unable To Join Playlist")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Red"))
            }
          }
        }
        
      case RoomOnboardingError.connectAppleMusicAccount:
        ZStack{
          VStack(spacing: 4){
            HStack(alignment: .center, spacing: 4){
              Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Red"))
              Text("No Apple Music Connected")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Red"))
            }
            Text("Please press the Apple Music icon to connect your account")
              .font(.system(size: 11, weight: .medium))
              .foregroundColor(Color("Text"))
          }
        }
        
      case RoomOnboardingError.appleMusicAuthorization:
        ZStack{
          VStack(spacing: 4){
            HStack(alignment: .center, spacing: 4){
              Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Red"))
              Text("No Media & Apple Music")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Red"))
            }
            Text("Please enable in Settings > Auxr > Media & Apple Music")
              .font(.system(size: 11, weight: .medium))
              .foregroundColor(Color("Text"))
          }
        }
        
      case RoomOnboardingError.appleMusicSubscription:
        ZStack{
          VStack(spacing: 4){
            HStack(alignment: .center, spacing: 4){
              Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Red"))
              Text("No Apple Music")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Red"))
            }
            Text("Please purchase a subscription to create a playlist")
              .font(.system(size: 11, weight: .medium))
              .foregroundColor(Color("Text"))
          }
        }
        
      case RoomOnboardingError.unknown:
        ZStack{
          VStack(spacing: 4){
            HStack(alignment: .center, spacing: 4){
              Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Red"))
              Text("Unknown Error")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Red"))
            }
          }
        }
        
      case RoomOnboardingError.none: EmptyView().hidden()
      }
    }
    .frame(width: UIScreen.main.bounds.size.width*0.85, height: 300, alignment: .bottom)
  }
}
