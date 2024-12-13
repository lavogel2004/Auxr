import SwiftUI

class Router: ObservableObject {
  init(){}
  
  let root: Route = Route(path: "root/")
  let login: Route = Route(path: "root/Login")
  let signUp: Route = Route(path: "root/SignUp")
  let noAccount: Route = Route(path: "root/NoAccount")
  let account: Route = Route(path: "root/Account")
  let createRoom: Route = Route(path: "/root/CreateRoom")
  let joinRoom: Route = Route(path: "/root/JoinRoom")
  let room: Route = Route(path: "/root/Room")
  let search: Route = Route(path: "/root/Room/Search")
  let settings: Route = Route(path: "/root/Room/Settings")
  let similarSongs: Route = Route(path: "/root/Room/SimilarSongs")
  
  // Default nav selection
  @Published var selectedNavView: AccountViews = AccountViews.profile
  @Published var routes:[Route] = []
  @Published var currPath: String = "root/"
  
  func popToRoot(){
    routes.removeAll()
    self.currPath = self.root.path
  }

  func popToAccount(){
    routes.append(account)
    self.currPath = self.account.path
  }
  
}

class Route: ObservableObject, Identifiable, Hashable {
  init(path: String){ self.path = path }
  
  @Published var id = UUID().uuidString
  
  let path: String
  
  func hash(into hasher: inout Hasher){
    hasher.combine(id)
    hasher.combine(path)
  }
  
  static func ==(LHS: Route, RHS: Route) -> Bool { return LHS.id == RHS.id }
}
