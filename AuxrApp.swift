import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseMessaging

@main
struct AuxrApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  var user: User
  var room: Room
  var appleMusic: AppleMusic
  var router: Router
  
  init(){
    self.user = User()
    self.room = Room()
    self.appleMusic = AppleMusic()
    self.router = Router()
    self.router = appDelegate.router
    self.appleMusic = appDelegate.appleMusic
    self.room = appDelegate.room
    self.user = appDelegate.user
  }
  
  var body: some Scene {
    WindowGroup{ rootView().environmentObject(router).environmentObject(user).environmentObject(room).environmentObject(appleMusic) }
  }
}
