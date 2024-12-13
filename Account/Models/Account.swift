//
//  Account.swift
//  Auxr
//
//  Created by Justin Russo on 6/17/23.
//

import Foundation

class Account: Codable, ObservableObject {
    
    var id: String
    @Published var username: String
    @Published var display_name: String = "" // TODO add to init?
    @Published var genres: [Genre] = []
    @Published var friend_requests: [Request] = []
    @Published var friends: [String] = []
    @Published var room_requests: [Request] = []
    @Published var points: Int = 0
    @Published var songs_queued: Int = 0
    
    enum Genre: String, Codable { // We may want to move this somewhere else
        case rock = "Rock",
             pop = "Pop",
             rap = "Rap",
             edm = "Electronic",
             jazz = "Jazz",
             country = "Country",
             classical = "Classical",
             indie = "Indie"
    }
    
    init(id: String, username: String){
        self.id = id
        self.username = username
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.username = try container.decode(String.self, forKey: .username)
        self.display_name = try container.decode(String.self, forKey: .display_name)
        self.points = try container.decode(Int.self, forKey: .points)
        self.songs_queued = try container.decode(Int.self, forKey: .songs_queued)
        do
        {
          let RequestsDictionary = try container.decode([String: Request].self, forKey: .friend_requests)
          self.friend_requests = Array(RequestsDictionary.values)
        }
        catch _
        {
          self.friend_requests = []
        }
        do
        {
          let friendsDictionary = try container.decode([String: String].self, forKey: .friends)
          self.friends = Array(friendsDictionary.values)
        }
        catch _
        {
          self.friends = []
        }
        do
        {
          let RequestsDictionary = try container.decode([String: Request].self, forKey: .room_requests)
          self.room_requests = Array(RequestsDictionary.values)
        }
        catch _
        {
          self.room_requests = []
        }
        do
        {
          let GenresDictionary = try container.decode([String: Genre].self, forKey: .genres)
          self.genres = Array(GenresDictionary.values)
        }
        catch _
        {
          self.genres = []
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.username, forKey: .username)
        try container.encode(self.display_name, forKey: .display_name)
        try container.encode(self.friend_requests, forKey: .friend_requests)
        try container.encode(self.friends, forKey: .friends)
        try container.encode(self.room_requests, forKey: .room_requests)
        try container.encode(self.genres, forKey: .genres)
        try container.encode(self.points, forKey: .points)
        try container.encode(self.songs_queued, forKey: .songs_queued)
    }
    
    var description: String {
        do
        {
            let Encoder = JSONEncoder()
            let JSON = try Encoder.encode(self)
            return String(data: JSON, encoding: .utf8)!
        }
        catch let error{ return error.localizedDescription }
    }

    func copy(account: Account){
        self.id = account.id
        self.username = account.username
        self.display_name = account.display_name
        self.friend_requests = account.friend_requests
        self.friends = account.friends
        self.room_requests = account.room_requests
        self.genres = account.genres
        self.points = account.points
        self.songs_queued = account.songs_queued
    }
    
    private enum CodingKeys: String, CodingKey {
        case id,
             username,
             display_name,
             friend_requests,
             friends,
             room_requests,
             genres,
             points,
             songs_queued
    }
}
