import SwiftUI


class User: ObservableObject, Identifiable, Codable, Equatable, Comparable{
	init(){}
	
	@Published var ID = UUID().uuidString
	@Published var Nickname: String = ""
	@Published var InRoom: Bool = true
	@Published var Likes: [AuxrSong] = []
	@Published var Votes: [AuxrSong] = []
	@Published var Controlled: Bool = false
	@Published var PlayPausePermission: Bool = false
	@Published var SkipPermission: Bool = false
	@Published var RemovePermission: Bool = false
	@Published var Account: AuxrAccount?
	
	// MARK: Public Auxr Account Identifier
	var pai: String = ""
	// MARK: Message Token
	var token: String = ""
	// MARK: Device Token
	var device_id: String = ""
	
#if(!Account)
	static func ==(LHS: User, RHS: User) -> Bool { return LHS.pai == RHS.pai }
	static func !=(LHS: User, RHS: User) -> Bool { return LHS.pai != RHS.pai }
#else
	static func ==(LHS: User, RHS: User) -> Bool { return LHS.token == RHS.token }
	static func !=(LHS: User, RHS: User) -> Bool { return LHS.token != RHS.token }
#endif
	static func <(LHS: User, RHS: User) -> Bool { return LHS.Nickname < RHS.Nickname }
	static func >(LHS: User, RHS: User) -> Bool { return LHS.Nickname > RHS.Nickname }
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		self.ID = try container.decode(String.self, forKey: .ID)
		self.Nickname = try container.decode(String.self, forKey: .Nickname)
		do
		{
			self.InRoom = try container.decode(Bool.self, forKey: .InRoom)
		}
		catch _
		{
			self.InRoom = false
		}
		do
		{
			self.Controlled = try container.decode(Bool.self, forKey: .Controlled)
		}
		catch _
		{
			self.Controlled = false
		}
		do
		{
			self.PlayPausePermission = try container.decode(Bool.self, forKey: .PlayPausePermission)
		}
		catch _
		{
			self.PlayPausePermission = false
		}
		do
		{
			self.SkipPermission = try container.decode(Bool.self, forKey: .SkipPermission)
		}
		catch _
		{
			self.SkipPermission = false
		}
		do
		{
			self.RemovePermission = try container.decode(Bool.self, forKey: .RemovePermission)
		}
		catch _
		{
			self.RemovePermission = false
		}
		do
		{
			self.token = try container.decode(String.self, forKey: .token)
		}
		catch _
		{
			self.token = ""
		}
		do
		{
			self.pai = try container.decode(String.self, forKey: .pai)
		}
		catch _
		{
			self.pai = ""
		}
		do
		{
			self.device_id = try container.decode(String.self, forKey: .device_id)
		}
		catch _
		{
			self.device_id = ""
		}
	}
	
	// MARK: Set User Account
	@MainActor
	func SetAccount(Account: AuxrAccount){
		self.Account = Account
		self.pai = Account.ID
	}
	
	// MARK: Remove User Account
	func RemoveAccount(){
		self.Account = nil
		self.pai = ""
	}
	
	// MARK: Store User Channel Likes/Votes From
	@MainActor
	func StoreChannelLikesVotes(User: User, Account: AuxrAccount, Room: Room) async throws -> Bool {
		var Storing = true
		var Stored = false
		try await AccountManager.deleteChannelLikes(account: Account, room: Room)
		try await AccountManager.deleteChannelVotes(account: Account, room: Room)
		if(Storing){
			for like in User.Likes{ try await AccountManager.updateChannelLikes(account: Account, room: Room, like: like) }
			for vote in User.Votes{ try await AccountManager.updateChannelVotes(account: Account, room: Room, vote: vote) }
			Stored = true
			Storing = false
		}
		return Stored
	}
	
	// MARK: User Reset
	@MainActor
	func Reset() async throws {
		self.ID = UUID().uuidString
		self.Nickname = ""
		self.InRoom = false
		self.Likes = []
		self.Votes = []
		self.Controlled = false
		self.PlayPausePermission = false
		self.SkipPermission = false
		self.RemovePermission = false
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
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(self.ID, forKey: .ID)
		try container.encode(self.Nickname, forKey: .Nickname)
		try container.encode(self.InRoom, forKey: .InRoom)
		try container.encode(self.Controlled, forKey: .Controlled)
		try container.encode(self.PlayPausePermission, forKey: .PlayPausePermission)
		try container.encode(self.SkipPermission, forKey: .SkipPermission)
		try container.encode(self.RemovePermission, forKey: .RemovePermission)
		try container.encode(self.token, forKey: .token)
		try container.encode(self.pai, forKey: .pai)
		try container.encode(self.device_id, forKey: .device_id)
	}
	
	private enum CodingKeys: String, CodingKey {
		case ID,
				 Nickname,
				 InRoom,
				 Likes,
				 Controlled,
				 PlayPausePermission,
				 SkipPermission,
				 RemovePermission,
				 pai,
				 token,
				 device_id
	}
}
