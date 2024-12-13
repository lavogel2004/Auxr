import SwiftUI

struct AuxrAboutOverlay: View {
  let GeneralNote: String = "Network connection is required"
  let CreateInfo: String = "Create and share a real-time playlist with multiple listeners in 2 simple steps"
  let CreateInfo1: String = "1. Connect your Apple Music account"
  let CreateNote1: String = "Note: Must have an active subscription"
  let CreateInfo2: String = "2. Enter a playlist name and a display name"
  let CreateNote2: String = "Note: Host should be connected to a sound output device"
  let JoinInfo: String =  "Join a playlist by entering a display name and a valid passcode"
  let JoinNote: String = "Note: No active subscription required"
  
  @Binding var Show: Bool
  
  var body: some View {
    ZStack{
      if(Show){
        Rectangle()
          .fill(Color("Secondary").opacity(0.75))
          .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
          .edgesIgnoringSafeArea(.all)
          .zIndex(5)
          .overlay(
            VStack{
              VStack(spacing: 20){
                HStack(spacing: 4){
                  Image(systemName: "wifi")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color("Tertiary"))
                  Text(GeneralNote)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("Text"))
                }
                .frame(width: UIScreen.main.bounds.size.width*0.75, alignment: .leading)
                VStack(alignment: .leading, spacing: 7){
                  HStack(spacing: 4){
                    Image(systemName: "info.circle.fill")
                      .font(.system(size: 15, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                    Text("Create Session")
                      .font(.system(size: 15, weight: .semibold))
                      .foregroundColor(Color("Tertiary"))
                  }
                  Text(CreateInfo)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("Text"))
                    .multilineTextAlignment(.leading)
                  Text(CreateInfo1)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("Text"))
                    .multilineTextAlignment(.leading)
                  Text(CreateNote1)
                    .font(.system(size: 12, weight: .thin))
                    .foregroundColor(Color("Text"))
                    .multilineTextAlignment(.leading)
                  Text(CreateInfo2)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("Text"))
                    .multilineTextAlignment(.leading)
                  Text(CreateNote2)
                    .font(.system(size: 12, weight: .thin))
                    .foregroundColor(Color("Text"))
                    .multilineTextAlignment(.leading)
                }
                .frame(width: UIScreen.main.bounds.size.width*0.75, alignment: .leading)
                VStack(alignment: .leading, spacing: 7){
                  HStack(spacing: 4){
                    Image(systemName: "info.circle.fill")
                      .font(.system(size: 15, weight: .bold))
                      .foregroundColor(Color("Tertiary"))
                    Text("Join Session")
                      .font(.system(size: 15, weight: .semibold))
                      .foregroundColor(Color("Tertiary"))
                  }
                  Text(JoinInfo)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("Text"))
                    .multilineTextAlignment(.leading)
                  Text(JoinNote)
                    .font(.system(size: 12, weight: .thin))
                    .foregroundColor(Color("Text"))
                    .multilineTextAlignment(.leading)
                }
                .frame(width: UIScreen.main.bounds.size.width*0.75, alignment: .leading)
                Button(action: { Show = false } ){
                  ZStack{
                    Text("CLOSE")
                      .font(.system(size: 13, weight: .bold))
                      .foregroundColor(Color("Red"))
                  }
                  .padding(.top, 10)
                }
                .frame(alignment: .bottom)
              }
              .padding(20)
            }
              .frame(alignment: .center)
              .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")).shadow(color: Color("Shadow").opacity(0.5), radius: 1))
              .zIndex(5)
          )
      }
    }
    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, alignment: .center)
    .zIndex(5)
    .onTapGesture{ Show = false }
  }
}
