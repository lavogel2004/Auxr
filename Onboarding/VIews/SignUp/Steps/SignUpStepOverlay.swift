import SwiftUI

struct SignUpStepOverlay: View {
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
                ZStack{
                  VStack{
                    VStack(spacing: 10){
                      VStack(alignment: .leading, spacing: 10){
                        HStack(spacing: 4){
                          Image(systemName: "1.circle.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color("Tertiary"))
                          Text("Create Account")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color("Tertiary"))
                        }
                        Text("Username and password are used to login")
                          .font(.system(size: 14, weight: .medium))
                          .foregroundColor(Color("Text"))
                          .multilineTextAlignment(.leading)
                        Text("Note: Username cannot be changed after this step")
                          .font(.system(size: 11, weight: .thin))
                          .foregroundColor(Color("Text"))
                          .multilineTextAlignment(.leading)
                      }
                      .frame(width: UIScreen.main.bounds.size.width*0.75, alignment: .leading)
                      VStack(alignment: .leading, spacing: 10){
                        Spacer().frame(height: 0)
                        HStack(spacing: 4){
                          Image(systemName: "2.circle.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color("Tertiary"))
                          Text("Personalization")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Color("Tertiary"))
                        }
                        VStack(spacing: 7){
                          VStack(spacing: 2){
                            HStack(spacing: 2){
                              ZStack{
                                Image(systemName: "person.crop.circle")
                                  .font(.system(size: 14, weight: .medium))
                                  .foregroundColor(Color("Text"))
                              }
                              .offset(y: -1.5)
                              Text("Profile Picture")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("Text"))
                                .frame(width: UIScreen.main.bounds.size.width*0.75, alignment: .leading)
                            }
                          }
                          .frame(width: UIScreen.main.bounds.size.width*0.75, alignment: .leading)
                          Text("Add a custom picture for your profile")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color("Text"))
                            .frame(width: UIScreen.main.bounds.size.width*0.75, alignment: .leading)
                        }
                        .frame(width: UIScreen.main.bounds.size.width*0.75, alignment: .leading)
                        VStack(spacing: 7){
                          VStack(spacing: 2){
                            HStack(spacing: 2){
                              ZStack{
                                Image(systemName: "pencil")
                                  .font(.system(size: 12, weight: .bold))
                                  .foregroundColor(Color("Text"))
                              }
                              .offset(y: -1)
                              Text("Display Name")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("Text"))
                                .frame(width: UIScreen.main.bounds.size.width*0.75, alignment: .leading)
                            }
                          }
                          ZStack{
                            Text("Add an alternative name to show in created and joined sessions")
                              .font(.system(size: 12, weight: .medium))
                              .foregroundColor(Color("Text"))
                              .multilineTextAlignment(.leading)
                          }
                          .frame(width: UIScreen.main.bounds.size.width*0.75, alignment: .leading)
                          .offset(x: -7)
                        }
                        .frame(width: UIScreen.main.bounds.size.width*0.75, alignment: .leading)
                        VStack(spacing: 7){
                          VStack(spacing: 2){
                            HStack(spacing: 2){
                              ZStack{
                                Image(systemName: "apple.logo")
                                  .font(.system(size: 14, weight: .medium))
                                  .foregroundColor(Color("Text"))
                              }
                              .offset(y: -1.5)
                              Text("Apple Music")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color("Text"))
                                .frame(width: UIScreen.main.bounds.size.width*0.75, alignment: .leading)
                            }
                          }
                          ZStack{
                            Text("Connect your Apple Music to create and host sessions")
                              .font(.system(size: 12, weight: .medium))
                              .foregroundColor(Color("Text"))
                              .multilineTextAlignment(.leading)
                          }
                          .frame(width: UIScreen.main.bounds.size.width*0.75, alignment: .leading)
                          .offset(x: -7)
                        }
                        .frame(width: UIScreen.main.bounds.size.width*0.75, alignment: .leading)
                        Text("Note: This step is optional")
                          .font(.system(size: 11, weight: .thin))
                          .foregroundColor(Color("Text"))
                          .multilineTextAlignment(.leading)
                      }
                      .frame(width: UIScreen.main.bounds.size.width*0.75, alignment: .leading)
                    }
                    .frame(width: UIScreen.main.bounds.size.width*0.78, alignment: .center)
                    .padding(20)
                  }
                }
                .frame(alignment: .center)
                .background(RoundedRectangle(cornerRadius: 3).fill(Color("Primary")))
                .zIndex(5)
              }
            }
          )
      }
    }
    .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height, alignment: .center)
    .zIndex(5)
    .onTapGesture{ Show = false }
  }
}
