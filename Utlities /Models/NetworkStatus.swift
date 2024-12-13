import SwiftUI
import SystemConfiguration

enum NetworkStatus: String, CaseIterable, Identifiable {
  case reachable, notConnected
  var id: Self { self }
}

func CheckNetworkStatus() -> NetworkStatus {
  let NetworkStatus: NetworkStatus
  var ZeroAddress = sockaddr_in()
  ZeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: ZeroAddress))
  ZeroAddress.sin_family = sa_family_t(AF_INET)
  
  let DefaultRouteReachability = withUnsafePointer(to: &ZeroAddress){
    $0.withMemoryRebound(to: sockaddr.self, capacity: 1){ ZeroSockAddress in
      SCNetworkReachabilityCreateWithAddress(nil, ZeroSockAddress)
    }
  }
  
  var flags = SCNetworkReachabilityFlags()
  if !SCNetworkReachabilityGetFlags(DefaultRouteReachability!, &flags){ return .notConnected }
  
  let reachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
  let notConnected = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
  NetworkStatus = (reachable && !notConnected) ? .reachable : .notConnected
  
  return NetworkStatus
}
