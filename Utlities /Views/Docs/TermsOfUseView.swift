import SwiftUI

struct TermsOfServiceView: View {
  @AppStorage("isDarkMode") private var isDarkMode = false
  
  let lastUpdatedOn: String = "Last Updated: 08/15/2023"
  let subtitle: String = ("AUXR reserves the right to update and modify this clause to ensure a safe and respectful environment for all users. Your continued use of the app constitutes your acceptance of any such modifications").uppercased()
  
  var body: some View {
    ZStack{
      Color("Secondary").edgesIgnoringSafeArea(.all)
      VStack{
        ScrollView(showsIndicators: false){
          VStack(spacing: 10){
            VStack(alignment: .leading, spacing: 7){
              VStack{
                Text("Terms of Service")
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
                  Text("1 Introduction")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                  Group{
                    VStack(spacing: 5){
                      DocNumBullet(num: "1.1", text: "AUXR is a music application that works exclusively on the Apple App Store and is designed to enhance your music experience by integrating with Apple Music.")
                      DocNumBullet(num: "1.2", text: "These Terms of Service constitute a legally binding agreement between you and AUXR. Using the app, you acknowledge that you have read, understood, and accepted these terms and conditions.")
                    }
                  }
                }
              }
              Group{
                VStack(spacing: 10){
                  Text("2 User Account")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                  Group{
                    VStack(spacing: 5){
                      DocNumBullet(num: "2.1", text: "To access the app's full functionality, you must create a user account. During the account creation process, we collect and store the following information:")
                      VStack(spacing: 3){
                        DocBullet(text: "Username", height: 0.015)
                        DocBullet(text: "Password (encrypted for security purposes)", height: 0.015)
                      }
                      .frame(width: UIScreen.main.bounds.size.width*0.7, height: UIScreen.main.bounds.size.height*0.035, alignment: .center)
                      .offset(y: -UIScreen.main.bounds.size.height*0.005)
                      DocNumBullet(num: "2.2", text: "By providing this information, you warrant that it is accurate, current, and complete. You are responsible for maintaining the confidentiality of your account credentials and are entirely responsible for all activities under your account.")
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
                  DocNumBullet(num: "3.1", text: "You must be at least 13 years of age to use the app. By using the app, you confirm that you meet this age requirement. If you are under 13, you may not use the app, and your use is considered unauthorized.")
                }
              }
            }
            Group{
              Group{
                VStack(spacing: 10){
                  Text("4 Privacy and Data Collection")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                  DocNumBullet(num: "4.1", text: "At AUXR, we take your privacy seriously. We collect, use, and store your account information following our Privacy Policy, which you can review on the app or our website. By using the app, you consent to collecting and using your information as described in the Privacy Policy.")
                }
              }
              Group{
                VStack(spacing: 10){
                  Text("5 Intellectual Property")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                  Group{
                    DocNumBullet(num: "5.1", text: "The app and its content, including but not limited to text, graphics, images, logos, trademarks, icons, and software, are the property of AUXR and its licensors and are protected by applicable copyright and intellectual property laws.")
                    DocNumBullet(num: "5.2", text: "You are granted a limited, non-exclusive, non-transferable, and revocable license to use the app for personal, non-commercial purposes. You may not reproduce, distribute, modify, create derivative works, publicly display, or exploit any content from the app without prior written consent from AUXR.")
                  }
                }
              }
              Group{
                VStack(spacing: 10){
                  Text("6 Prohibited Conduct")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                  Group{
                    DocNumBullet(num: "6.1", text: "You agree not to use the app for any unlawful or prohibited purpose, including but not limited to:")
                    VStack(spacing: 3){
                      DocBullet(text: "Violating any applicable laws or regulations.", height: 0.015)
                      DocBullet(text: "Impersonating any person or entity or falsely representing your affiliation with any person or entity.", height: 0.025)
                      DocBullet(text: "Engaging in any activity that could harm, disable, overburden, impair the app, or interfere with its proper functioning.", height: 0.04)
                      DocBullet(text: "Attempting to gain unauthorized access to any portion of the app or its related systems or networks.", height: 0.025)
                    }
                  }
                }
              }
            }
            Group{
              Group{
                VStack(spacing: 10){
                  Text("7 Inappropriate Images and Language Clause")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                  Group{
                    DocNumBullet(num: "7.1", text: "Using inappropriate images for profile pictures or displaying inappropriate language in usernames and display names is strictly prohibited on AUXR.")
                    DocNumBullet(num: "7.2", text: "Inappropriate images include but are not limited to, pictures that are sexually explicit, violent, offensive, discriminatory, or otherwise violate applicable laws or community standards.")
                    DocNumBullet(num: "7.3", text: "Inappropriate language includes but is not limited to, content that is offensive, defamatory, abusive, harassing, or otherwise harmful to others.")
                    DocNumBullet(num: "7.4", text: "AUXR reserves the right to review and moderate all user-generated content, including profile pictures, display names, and usernames, to ensure compliance with this clause and the overall Terms of Service.")
                    DocNumBullet(num: "7.5", text: "Users found to be in violation of this clause may be subject to the following actions at the sole discretion of AUXR:")
                  }
                  Group{
                    VStack(spacing: 3){
                      DocBullet(text: "Removal of the inappropriate content.", height: 0.015)
                      DocBullet(text: "Temporary suspension or permanent termination of the user's account.", height: 0.03)
                      DocBullet(text: "Reporting of serious violations to relevant authorities.", height: 0.015)
                    }
                    .frame(width: UIScreen.main.bounds.size.width*0.7, alignment: .center)
                  }
                  Group{
                    DocNumBullet(num: "7.6", text: "Users are solely responsible for the content they upload, display, or use as their profile picture or username on the app. By using AUXR, you agree not to upload or display any content that violates this clause or any other provision of the Terms of Service.")
                    DocNumBullet(num: "7.7", text: "If you encounter any user-generated content you believe violates this clause or the Terms of Service, please report it to AUXR immediately through the in-app reporting system or contact us at Contact@AUXR.app.")
                    DocNumBullet(num: "7.8", text: "AUXR reserves the right to update and modify this clause to ensure a safe and respectful environment for all users. Your continued use of the app constitutes your acceptance of any such modifications")
                    DocNumBullet(num: "7.9", text: "By using AUXR, you acknowledge and agree to abide by the rules set forth in this clause regarding inappropriate images and language. Failure to comply may result in disciplinary action, up to and including the termination of your account.")
                  }
                }
              }
              Group{
                VStack(spacing: 10){
                  Text("8 Termination")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                  DocNumBullet(num: "8.1", text: "AUXR reserves the right to terminate or suspend your access to the app at any time, with or without cause, and without notice.")
                }
              }
              Group{
                VStack(spacing: 10){
                  Text("9 Modifications to Terms of Service")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                }
                DocNumBullet(num: "9.1", text: "AUXR may update or modify these Terms of Service from time to time. You will be notified of any material changes through the app or via email. Your continued use of the app after the changes take effect constitutes your acceptance of the revised terms.")
              }
            }
            Group{
              Group{
                VStack(spacing: 10){
                  Text("10 Governing Law")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                }
                DocNumBullet(num: "10.1", text: "These Terms of Service shall be governed by and construed following the laws of [Your Country/State/Region], without regard to its conflicts of law principles.")
              }
              Group{
                VStack(spacing: 10){
                  Text("11 Contact Us")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color("Tertiary"))
                    .frame(width: UIScreen.main.bounds.size.width*0.9, alignment: .leading)
                }
                DocNumBullet(num: "11.1", text: "If you have any questions, concerns, or feedback regarding these Terms of Service or the App, please contact us at Contact@AUXR.app.")
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
