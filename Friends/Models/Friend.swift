import SwiftUI

class AuxrFriend: ObservableObject, Identifiable, Codable, Equatable, Comparable {
  var ID: String
  
  static func ==(LHS: AuxrFriend, RHS: AuxrFriend) -> Bool { return LHS.ID == RHS.ID }
  static func !=(LHS: AuxrFriend, RHS: AuxrFriend) -> Bool { return LHS.ID != RHS.ID }
  static func <(LHS: AuxrFriend, RHS: AuxrFriend) -> Bool { return LHS.ID < RHS.ID }
  static func >(LHS: AuxrFriend, RHS: AuxrFriend) -> Bool { return LHS.ID > RHS.ID }
  
  init(userID: String){ self.ID = userID }
  
  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.ID = try container.decode(String.self, forKey: .ID)
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(self.ID, forKey: .ID)
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
    case ID
  }
}
