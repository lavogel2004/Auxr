func env_prnt(User: User, Room: Room, AppleMusic: AppleMusic, Router: Router){
  rtr_prnt(Router: Router)
  usr_prnt(User: User, Room: Room)
  rm_prnt(Room: Room)
  
  if(Room.MusicService == "AppleMusic"){ print("Authorization Status (Apple Music): ", AppleMusic.Authorized) }
}

func usr_prnt(User: User, Room: Room){
  print("User.ID: ", User.ID)
  print("User.Nickname: ", User.Nickname)
  if(Room.Host(User: User)){ print("User is Host") }
  if(Room.Guest(User: User)){ print("User is Guest") }
}

func rm_prnt(Room: Room){
  print("Room.Name: ", Room.Name)
  print("Room.Passcode: ", Room.Passcode)
  print("Room.MusicService: ", Room.MusicService)
  print("\n")
  
  print("==Memebers==")
  print("Room.Host: ", Room.Host)
  print("Room.Guests")
  if(Room.Guests.isEmpty){ print("** no guests in room **") }
  else{ for guest in Room.Guests{ print(guest) } }
  print("\n")
  
  print("==Music Playlist==")
  print("Room.MusicPlaylist")
  if(Room.Playlist.Queue.isEmpty){ print("** no songs in playlist **") }
  else{ for song in Room.Playlist.Queue{ print(song) } }
  print("\n")
  
  print("==Permissions==")
  print("Room.PlayPausePermission:  ", Room.PlayPausePermission)
  print("Room.SkipPermission: ", Room.SkipPermission)
  print("Room.RemovePermission: ", Room.RemovePermission)
}

func rt_prnt(Route: Route){
  print(" Route.id:  ", Route.id)
  print(" Route.path:  ", Route.path)
}

func rtr_prnt(Router: Router){
  print("[Router] Current Path: ", Router.currPath)
}
