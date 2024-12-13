import SwiftUI
import MessageUI
import MusicKit
import OSLog

extension UIApplication {
  func dismissKeyboard(){ sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }
}

extension Collection where Indices.Iterator.Element == Index {
  subscript (safe index: Index) -> Iterator.Element? {
    return indices.contains(index) ? self[index] : nil
  }
}

extension String {
  func widthOfString(usingFont font: UIFont) -> CGFloat {
    let fontAttributes = [NSAttributedString.Key.font: font]
    let size = self.size(withAttributes: fontAttributes)
    return size.width
  }
  
  func heightOfString(usingFont font: UIFont) -> CGFloat {
    let fontAttributes = [NSAttributedString.Key.font: font]
    let size = self.size(withAttributes: fontAttributes)
    return size.height
  }
}

extension Logger {
  private static var subsystem = Bundle.main.bundleIdentifier!
  static let room = Logger(subsystem: subsystem, category: "room_log")
}

extension View {
  @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
    if(hidden){ if(!remove){ self.hidden() } }
    else{ self }
  }
}
