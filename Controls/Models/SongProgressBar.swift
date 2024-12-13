import SwiftUI

struct SongProgressBar: Shape {
  var progress: CGFloat
  func path(in rect: CGRect) -> Path {
    let width = rect.width * progress
    let roundedRect = RoundedRectangle(cornerRadius: 5)
    let path = roundedRect.path(in: CGRect(x: 0, y: 0, width: width, height: rect.height))
    return path
  }
}
