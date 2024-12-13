import UIKit
import MusicKit
import FirebaseMessaging
import FirebaseFunctions

class NotificationManager {
  private var AppleMusic: AppleMusic
  private var Room: Room
  private var User: User
  
  init(appleMusic: AppleMusic, room: Room, user: User){
    self.AppleMusic = appleMusic
    self.User = user
    self.Room = room
  }
  
  func HandleNotification(userInfo: [AnyHashable: Any]){
    if let type = userInfo["type"] as? String {
      switch(type){
      case "wakeup_host":
        WakeupHost(userInfo: userInfo)
      default:
        print("ERROR: Notification contains un-implememted type")
      }
    }
  }
  
  private func WakeupHost(userInfo: [AnyHashable: Any]){
    if let action = userInfo["action"] as? String{
      switch(action){
      case "play":
        Task{
          do
          {
            // MARK: Resume Playling [Play]
            if(!(AppleMusic.player.state.playbackStatus == .playing)){
              if(AppleMusic.player.state.playbackStatus == .paused &&
                 Room.Controlled &&
                 (Room.Playlist.Queue.sorted()[0].AppleMusic ==
                  AppleMusic.player.queue.currentEntry?.item?.id.rawValue)){
                try await AppleMusic.player.prepareToPlay()
                try await AppleMusic.player.play()
                Room.Controlled = false
                try await FirebaseManager.UpdateRoomControlled(Room: Room)
              }
              else{
                // MARK: Initialize Player [Play]
                if(!Room.Playlist.Queue.isEmpty && Room.Controlled){
                  AppleMusic.player.queue.entries = []
                  AppleMusic.Queue = []
                  var queueSize = 2
                  for song in Room.Playlist.Queue.sorted(){
                    guard let AM_Song = try await AppleMusic.ConvertSong(AuxrSong: song)
                    else{ return }
                    AppleMusic.Queue.append(AM_Song)
                    if(queueSize > 0){ queueSize -= 1 }
                    else{ break }
                  }
                  
                  AppleMusic.player.queue = ApplicationMusicPlayer.Queue(for: AppleMusic.Queue, startingAt: AppleMusic.Queue.first)
                  AppleMusic.player.state.repeatMode = MusicPlayer.RepeatMode.none
                  try await AppleMusic.player.prepareToPlay()
                  try await AppleMusic.player.play()
                  
                  if(!Room.Playlist.Queue.isEmpty){
                    Room.Playlist.History.append(Room.Playlist.Queue.sorted()[0])
                    try await FirebaseManager.AddSongToPlaylistHistory(Room: Room, AuxrSong: Room.Playlist.Queue.sorted()[0])
                  }
                  Room.Playlist.QueueInitializing = false
                  try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: Room)
                  Room.Controlled = false
                  try await FirebaseManager.UpdateRoomControlled(Room: Room)
                }
              }
            }
          }
          catch _ {}
        }
      case "skip":
        Task{
          do
          {
            // MARK: Skip Control
            if(Room.SkipSong && Room.Controlled){
              if(Room.MusicService == "AppleMusic"){
                if(Room.PlaySong){
                  if(Room.Playlist.Queue.sorted()[0].AppleMusic == AppleMusic.player.queue.currentEntry?.item?.id.rawValue){
                    if(!Room.Playlist.QueueInitializing){
                      if(Room.Playlist.Queue.count > 1){
                        Room.Playlist.QueueInitializing = true
                        try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: Room)
                        let currSong = Room.Playlist.Queue.sorted()[0]
                        try await FirebaseManager.RemoveSongFromPlaylistQueue(Room: Room, AuxrSong: currSong)
                        try await AppleMusic.PlayerUpdateQueue(Room: Room)
                        if(!Room.PlaySong){
                          Room.PlaySong = true
                          try await FirebaseManager.UpdateRoomPlaySong(Room: Room)
                        }
                        try await AppleMusic.player.prepareToPlay()
                        try await AppleMusic.player.play()
                        if(!Room.Playlist.Queue.isEmpty){
                          Room.Playlist.History.append(Room.Playlist.Queue.sorted()[0])
                          try await FirebaseManager.AddSongToPlaylistHistory(Room: Room, AuxrSong: Room.Playlist.Queue.sorted()[0])
                        }
                        if(Room.SkipSong){
                          Room.SkipSong = false
                          try await FirebaseManager.UpdateRoomSkipSong(Room: Room)
                          if(Room.Controlled){
                            Room.Controlled = false
                            try await FirebaseManager.UpdateRoomControlled(Room: Room)
                          }
                        }
                        Room.Playlist.QueueInitializing = false
                        try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: Room)
                      }
                    }
                  }
                }
                else{
                  if(!Room.Playlist.QueueInitializing){
                    if(Room.Playlist.Queue.count > 1){
                      Room.Playlist.QueueInitializing = true
                      try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: Room)
                      let currSong = Room.Playlist.Queue.sorted()[0]
                      try await FirebaseManager.RemoveSongFromPlaylistQueue(Room: Room, AuxrSong: currSong)
                      try await AppleMusic.PlayerUpdateQueue(Room: Room)
                      if(!Room.PlaySong){
                        Room.PlaySong = true
                        try await FirebaseManager.UpdateRoomPlaySong(Room: Room)
                      }
                      try await AppleMusic.player.prepareToPlay()
                      try await AppleMusic.player.play()
                      if(!Room.Playlist.Queue.isEmpty){
                        Room.Playlist.History.append(Room.Playlist.Queue.sorted()[0])
                        try await FirebaseManager.AddSongToPlaylistHistory(Room: Room, AuxrSong: Room.Playlist.Queue.sorted()[0])
                      }
                      if(Room.SkipSong){
                        Room.SkipSong = false
                        try await FirebaseManager.UpdateRoomSkipSong(Room: Room)
                        if(Room.Controlled){
                          Room.Controlled = false
                          try await FirebaseManager.UpdateRoomControlled(Room: Room)
                        }
                      }
                      Room.Playlist.QueueInitializing = false
                      try await FirebaseManager.UpdatePlaylistQueueInitializing(Room: Room)
                    }
                  }
                }
              }
            }
          }
          catch _ {}
        }
      case "refresh":
        Task{
          do{
            try await AppleMusic.BackgroundTaskFetch(Room: Room)
            try await AppleMusic.QueueControl(Room: Room)
          }
          catch _ {}
        }
      default:
        print("[WakeupHost] ERROR: No Notification Case")
      }
    }
  }
  
  static func SendWakeupHostNotification(hostFcmToken: String, queueAction: String, completion: @escaping (_ Bool: Bool, _ String: String) -> Void){
    let functions = Functions.functions()
    let payload = ["token": hostFcmToken, "action": queueAction]
    
    functions.httpsCallable("wakeup_host").call(payload){ result, error in
      if let error = error as NSError? {
        if error.domain == FunctionsErrorDomain {
          _ = FunctionsErrorCode(rawValue: error.code)
          let message = error.localizedDescription
          _ = error.userInfo[FunctionsErrorDetailsKey]
          completion(false, message)
        }
      }
      if let data = result?.data as? [String: Any], let success = data["success"] as? Bool {
        completion(success, "")
      }
    }
  }
}


extension AppDelegate {
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
    let NotificationManager = NotificationManager(appleMusic: self.appleMusic, room: self.room, user: self.user)
      NotificationManager.HandleNotification(userInfo: userInfo)
    return UIBackgroundFetchResult.newData
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void){ completionHandler([[.banner, .sound]]) }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void){ completionHandler() }
  
  // MARK: Application Token
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data){
    _ = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    Messaging.messaging().apnsToken = deviceToken
  }
  
  // MARK: Firebase Token
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?){
    let tokenDict = ["token": fcmToken ?? ""]
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: tokenDict)
    if let token = fcmToken {
      self.user.token = token
    }
  }
}
