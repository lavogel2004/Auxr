import SwiftUI

struct VoterView: View {
  @EnvironmentObject var user: User
  @EnvironmentObject var room: Room
  
  let Song: AuxrSong
  
  @Binding var Upvote: Bool
  @Binding var Downvote: Bool
  @Binding var ShowMenu: Bool
  @Binding var Offline: Bool
  
  var body: some View {
    ZStack{
      VStack(spacing: 11){
        if(!(user.Votes.contains(Song))){
          Button(action: {
            let networkStatus: NetworkStatus = CheckNetworkStatus()
            if(networkStatus == NetworkStatus.reachable){
              ShowMenu = false
              Upvote = true
              Task{
                if let Account = user.Account{ try await AccountManager.addPoints(account: Account, p: 1) }
                room.Voting = true
                try await FirebaseManager.UpdateRoomVoting(Room: room)
                room.Controlled = true
                try await FirebaseManager.UpdateRoomControlled(Room: room)
                Song.Upvotes = Song.Upvotes + 1
                let firstSong: AuxrSong = room.Playlist.Queue.sorted()[0]
                for i in 1..<room.Playlist.Queue.count {
                  let currSong: AuxrSong = room.Playlist.Queue.sorted()[i]
                  var j: Int = i - 1
                  var exceptFirst: Int = 0
                  if(room.PlaySong && room.Playlist.Queue.count > 1){ exceptFirst = 1 }
                  while j >= exceptFirst && room.Playlist.Queue.sorted()[j].Upvotes < currSong.Upvotes {
                    let song1: AuxrSong = room.Playlist.Queue.sorted()[j]
                    let song2: AuxrSong = room.Playlist.Queue.sorted()[j+1]
                    let tmp: Int = song1.Index
                    song1.Index = song2.Index
                    song2.Index = tmp
                    j -= 1
                  }
                  room.Playlist.Queue.sorted()[j+1].Index = currSong.Index
                }
                if(firstSong != room.Playlist.Queue.sorted()[0]){
                  if let i: Int = room.Playlist.History.firstIndex(where: { $0.ID == firstSong.ID }){
                    let historySong: AuxrSong = room.Playlist.History.sorted()[i]
                    try await FirebaseManager.RemoveSongFromPlaylistHistory(Room: room, AuxrSong: historySong)
                  }
                }
                try await FirebaseManager.UpdatePlaylistQueue(Room: room)
                user.Votes.append(Song)
                user.Votes = Array(Set(user.Votes))
                try await FirebaseManager.UpdateRoomVoteCount(Room: room)
                room.Controlled = false
                try await FirebaseManager.UpdateRoomControlled(Room: room)
                room.Voting = false
                try await FirebaseManager.UpdateRoomVoting(Room: room)
              }
            }
            if(networkStatus == NetworkStatus.notConnected){ Offline = true }
          }){
            Image(systemName: "chevron.up")
              .font(.system(size: 22, weight: .medium))
              .foregroundColor(Color("Tertiary").opacity(0.8))
          }
          .disabled(room.Voting)
        }
        if(user.Votes.contains(Song)){
          Button(action: {
            let networkStatus: NetworkStatus = CheckNetworkStatus()
            if(networkStatus == NetworkStatus.reachable){
              ShowMenu = false
              Downvote = true
              Task{
                if let Account = user.Account{ try await AccountManager.subtractPoints(account: Account, p: 1) }
                room.Voting = true
                try await FirebaseManager.UpdateRoomVoting(Room: room)
                room.Controlled = true
                try await FirebaseManager.UpdateRoomControlled(Room: room)
                Song.Upvotes = Song.Upvotes - 1
                let firstSong: AuxrSong = room.Playlist.Queue.sorted()[0]
                for i in 1..<room.Playlist.Queue.count {
                  let currSong: AuxrSong = room.Playlist.Queue.sorted()[i]
                  var j: Int = i - 1
                  var exceptFirst: Int = 0
                  if(room.PlaySong && room.Playlist.Queue.count > 1){ exceptFirst = 1 }
                  while j >= exceptFirst && room.Playlist.Queue.sorted()[j].Upvotes < currSong.Upvotes {
                    let song1: AuxrSong = room.Playlist.Queue.sorted()[j]
                    let song2: AuxrSong = room.Playlist.Queue.sorted()[j+1]
                    let tmp: Int = song1.Index
                    song1.Index = song2.Index
                    song2.Index = tmp
                    j -= 1
                  }
                  room.Playlist.Queue.sorted()[j+1].Index = currSong.Index
                }
                if(firstSong != room.Playlist.Queue.sorted()[0]){
                  if let i: Int = room.Playlist.History.firstIndex(where: { $0.ID == firstSong.ID }){
                    let historySong: AuxrSong = room.Playlist.History.sorted()[i]
                    try await FirebaseManager.RemoveSongFromPlaylistHistory(Room: room, AuxrSong: historySong)
                  }
                }
                try await FirebaseManager.UpdatePlaylistQueue(Room: room)
                user.Votes = user.Votes.filter({ $0 != Song})
                user.Votes = Array(Set(user.Votes))
                try await FirebaseManager.UpdateRoomVoteCount(Room: room)
                room.Controlled = false
                try await FirebaseManager.UpdateRoomControlled(Room: room)
                room.Voting = false
                try await FirebaseManager.UpdateRoomVoting(Room: room)
              }
            }
            if(networkStatus == NetworkStatus.notConnected){ Offline = true }
          }){
            Image(systemName: "chevron.up")
              .font(.system(size: 25, weight: .heavy))
              .foregroundColor(Color("Tertiary"))
          }
          .disabled(room.Voting)
        }
        Text(String(Song.Upvotes))
          .font(.system(size: 15, weight: .semibold))
          .foregroundColor(Color("Text"))
      }
    }
    .frame(width:25, height: UIScreen.main.bounds.size.height*0.08)
    .onAppear{
      Task{
        if(Song.Upvotes <= 0){
          Song.Upvotes = 0
          user.Votes = user.Votes.filter({ $0 != Song})
          user.Votes = Array(Set(user.Votes))
          try await FirebaseManager.UpdatePlaylistQueueSong(Room: room, AuxrSong: Song)
        }
      }
    }
  }
}
