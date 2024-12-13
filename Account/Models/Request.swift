//
//  Request.swift
//  Auxr
//
//  Created by Justin Russo on 6/30/23.
//

import Foundation

class Request: Codable {
    
    enum RequestType: String, Codable {
        case friend, room
    }
    
    var id: String = UUID().uuidString
    var type: RequestType
    var sender: String
    var receiver: String
    
    // Room ID if room request
    var room_id: String?
    
    init(type: RequestType, sender: String, receiver: String, params: [String:Any]?){
        self.type = type
        self.sender = sender
        self.receiver = receiver
        
        if let p = params {
            if let roomId = p["room_id"] as? String {
              self.room_id = roomId
            }
        }
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.type = try container.decode(RequestType.self, forKey: .type)
        self.sender = try container.decode(String.self, forKey: .sender)
        self.receiver = try container.decode(String.self, forKey: .receiver)
        
        if (self.type == .room) {
            self.room_id = try container.decode(String.self, forKey: .room_id)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.type, forKey: .type)
        try container.encode(self.sender, forKey: .sender)
        try container.encode(self.receiver, forKey: .receiver)
        try container.encode(self.room_id, forKey: .room_id)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id,
             type,
             sender,
             receiver,
             room_id
    }
    
    func isReceiver(account_id: String) -> Bool{
        return self.receiver == account_id
    }
}
