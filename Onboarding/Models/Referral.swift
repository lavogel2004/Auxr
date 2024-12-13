import Foundation

class AuxrReferral: Codable {
  var ID: String
  var username: String
  var code: String
  var num_referrals: Int
  var referred_tokens: [String]
  var referred_usernames: [String]
  var ambassador: Bool
  var name: String
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.ID = try container.decode(String.self, forKey: .ID)
    do
    {
      self.username = try container.decode(String.self, forKey: .username)
    }
    catch _
    {
      self.username = "unknown"
    }
    do
    {
      self.code = try container.decode(String.self, forKey: .code)
    }
    catch _
    {
      self.code = ""
    }
    do
    {
      self.num_referrals = try container.decode(Int.self, forKey: .num_referrals)
    }
    catch _
    {
      self.num_referrals = 0
    }
    do
    {
      self.referred_tokens = try container.decode([String].self, forKey: .referred_tokens)
    }
    catch _
    {
      self.referred_tokens = []
    }
    do
    {
      self.referred_usernames = try container.decode([String].self, forKey: .referred_usernames)
    }
    catch _
    {
      self.referred_usernames = []
    }
    do
    {
      self.ambassador = try container.decode(Bool.self, forKey: .ambassador)
    }
    catch _
    {
      self.ambassador = false
    }
    do
    {
      self.name = try container.decode(String.self, forKey: .name)
    }
    catch _
    {
      self.name = "none"
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.ID, forKey: .ID)
    try container.encode(self.username, forKey: .username)
    try container.encode(self.code, forKey: .code)
    try container.encode(self.num_referrals, forKey: .num_referrals)
    try container.encode(self.referred_tokens, forKey: .referred_tokens)
    try container.encode(self.referred_usernames, forKey: .referred_usernames)
    try container.encode(self.ambassador, forKey: .ambassador)
    try container.encode(self.name, forKey: .name)
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
  
  private enum CodingKeys: String, CodingKey {
    case ID,
         code,
         username,
         num_referrals,
         referred_tokens,
         referred_usernames,
         ambassador,
         name
  }
}
