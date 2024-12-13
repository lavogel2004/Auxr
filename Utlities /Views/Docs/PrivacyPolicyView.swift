import SwiftUI

struct PrivacyPolicyView: View {
  @AppStorage("isDarkMode") private var isDarkMode = false
  
  let lastUpdatedOn: String = "Last Updated: 08/15/2023"
  let subtitle: String = ("AUXR reserves the right to update and modify this clause to ensure a safe and respectful environment for all users. Your continued use of the app constitutes your acceptance of any such modifications.").uppercased()
  
  var body: some View {
    ZStack{
      Color("Secondary").edgesIgnoringSafeArea(.all)
      VStack{
        ScrollView(showsIndicators: false){
          VStack(spacing: 10){
            VStack(alignment: .leading, spacing: 7){
              VStack{
                Text("Privacy Policy")
                  .font(.system(size: 40, weight: .bold))
                  .foregroundColor(Color("Tertiary"))
                  .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .center)
                Text(lastUpdatedOn)
                  .font(.system(size: 11, weight: .bold))
                  .foregroundColor(Color("Text"))
                  .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                Text(subtitle)
                  .font(.system(size: 10, weight: .bold))
                  .foregroundColor(Color("Text"))
                  .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
              }
            }
            .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
            Group{
              Group{
                VStack(spacing: 10){
                  Text("1 Information We Collect")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                  Group{
                    VStack(spacing: 5){
                      DocNumBullet(num: "1.1", text: "Account Information: When you create an account on AUXR, we collect the following information.")
                      VStack(spacing: 3){
                        DocBullet(text: "Username", height: 0.015)
                        DocBullet(text: "Password (encrypted for security purposes)", height: 0.015)
                      }
                      .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .center)
                      DocNumBullet(num: "1.2", text: "Other Data: We collect the following data to provide a better experience across the app.")
                      VStack(spacing: 3){
                        DocBullet(text: "Sessions - AUXR playlists", height: 0.015)
                        DocBullet(text: "Likes - AUXR Songs", height: 0.015)
                        DocBullet(text: "Friends - AUXR users", height: 0.015)
                      }
                      .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .center)
                      DocNumBullet(num: "1.3", text: "We do not collect personal information beyond the details mentioned above. We do not access, store, or collect data from your Apple Music account.")
                      //
                    }
                  }
                }
              }
              Group{
                VStack(spacing: 10){
                  Text("2 Use This Information")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                  Group{
                    VStack(spacing: 5){
                      DocNumBullet(num: "2.1", text: "Username and Password are used for account creation and authentication")
                      DocNumBullet(num: "2.2", text: "Sessions/Likes/Friends are stored providing the functionality of the app, including saving playlists, liking songs, user interactions and networking with other users on the platform")
                      DocNumBullet(num: "2.3", text: "We do not sell, rent, trade, or otherwise disclose your personal information to third parties without your explicit consent, except as required by law or as stated in this Privacy Policy." )
                    }
                  }
                }
              }
              Group{
                VStack(spacing: 10){
                  Text("3 Age Requirement")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                  DocNumBullet(num: "3.1", text: "Intended app use is for users who are at least 13 years old. We do not knowingly collect or store personal information from children under 13. If we know a user is under 13, we will promptly delete their account and any associated data.")
                }
              }
            }
            Group{
              Group{
                VStack(spacing: 10){
                  Text("4 Data Security")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                  DocNumBullet(num: "4.1", text: "We take appropriate measures to safeguard the personal information collected and stored in our app. These measures include encryption, access controls, and regular security assessments.")
                }
              }
              Group{
                VStack(spacing: 10){
                  Text("5 Inappropriate Content Moderation")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                  Group{
                    DocNumBullet(num: "5.1", text: "We reserve the right to review and moderate user-generated content, such as profile pictures, display names, and usernames, to ensure compliance with our Terms of Service, including the prohibition of inappropriate images and language.")
                  }
                }
              }
              Group{
                VStack(spacing: 10){
                  Text("6 Changes to this Privacy Policy")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                  Group{
                    DocNumBullet(num: "6.1", text: "We may update this Privacy Policy occasionally to reflect changes in our practices or for legal, operational, or regulatory reasons. New changes to the privacy policy will be accessible on our app or website.")
                  }
                }
              }
            }
            Group{
              VStack(spacing: 10){
                Text("Contact Us ")
                  .font(.system(size: 14, weight: .semibold))
                  .foregroundColor(Color("Tertiary"))
                  .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                Group{
                  DocNumBullet(num: "7.1", text: "If you have any questions, concerns, or feedback regarding this Privacy Policy or our app's privacy practices, please contact us at Contact@AUXR.app")
                }
              }
            }
          }
          .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .center)
        }
        .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .center)
        .padding(20)
      }
      .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .center)
    }
    .colorScheme(isDarkMode ? .dark : .light)
  }
}
