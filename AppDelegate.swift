
import SwiftUI
import Firebase
import FirebaseMessaging
import Siren

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
  var appleMusic = AppleMusic()
  var room =  Room()
  var user = User()
  var router = Router()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    // Configure Firebase
    FirebaseApp.configure()
    
    // Set messaging delegate
    Messaging.messaging().delegate = self
    
    // Configure Siren
    let siren = Siren.shared
    siren.rulesManager = RulesManager(majorUpdateRules: .critical,
                                      minorUpdateRules: .critical,
                                      patchUpdateRules: .persistent)
    siren.presentationManager = PresentationManager(
      alertTintColor: UIColor(Color("Tertiary")),
      nextTimeButtonTitle: "Skip"
    )
    
    // Request notification permissions on first-boot
    // check version after notification permissions set
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
      switch settings.authorizationStatus {
      case .authorized, .provisional:
        print("authorized")
        siren.wail()
      case .denied:
        print("denied")
        siren.wail()
      case .notDetermined:
        print("not determined")
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions){ _, _ in }
      default:
        print("Siren Notification Error")
      }
    })

    if let identifierForVendor = UIDevice.current.identifierForVendor {
        let uuidString = identifierForVendor.uuidString
        print("Vendor UUID:", uuidString)
        user.device_id = uuidString
    }
    return true
  }
}
