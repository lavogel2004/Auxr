import SwiftUI
import UniformTypeIdentifiers
import OSLog

@MainActor
func SystemReset(User: User, Room: Room, AppleMusic: AppleMusic) async throws {
  Logger.room.log("System Reset")
  try await AppleMusic.Reset()
  AppleMusic.player.stop()
  AppleMusic.player.queue.entries = []
  AppleMusic.player.queue.currentEntry = nil
  try await User.Reset()
  try await Room.Reset()
}

@MainActor
func RoomReset(User: User, Room: Room, AppleMusic: AppleMusic) async throws {
  Logger.room.log("Room Reset")
  try await AppleMusic.Reset()
  try await AppleMusic.PlayerReset()
}

func FormatTextFieldInput(Input: String) -> String {
  var inputCopy: String = Input
  var invalidChars:Set<Character> = []
  for char in Input{
    if(char.isPunctuation || char.isWhitespace || char.isCurrencySymbol){
      invalidChars.insert(char)
    }
  }
  inputCopy.removeAll(where: { invalidChars.contains($0) })
  return inputCopy
}

func FormatTextFieldInputKeepWhitespace(Input: String) -> String {
  var inputCopy: String = Input
  var invalidChars:Set<Character> = []
  for char in Input{
    if(char.isPunctuation || char.isCurrencySymbol){
      invalidChars.insert(char)
    }
  }
  inputCopy.removeAll(where: { invalidChars.contains($0) })
  return inputCopy
}

func FormatDurationToString(s: Double) -> String {
  if(s == 0){ return "0:00" }
  let mins = Int(s/60.0)
  let secs = Int(s.truncatingRemainder(dividingBy: 60))
  let durationString = String(mins) + ":" + ( secs >= 10 ? String(secs) : "0" + String(secs))
  return durationString
}

func ConvertSecondsToString(s: Double) -> String {
  let mins = Int(s/60.0)
  let secs = Int(s.truncatingRemainder(dividingBy: 60))
  let durationString = String(mins) + "m " + String(secs) + "s"
  return durationString
}

func CopyToClipboard(Text: String){ UIPasteboard.general.setValue(Text, forPasteboardType: UTType.plainText.identifier) }

func MostFrequentString(A: [String], howMany: Int) -> [String] {
  var frequencyDict: [String: Int] = [:]
  for str in A{ frequencyDict[str, default: 0] += 1 }
  let sortedPairs = frequencyDict.sorted { $0.value > $1.value }
  return Array(sortedPairs.prefix(howMany)).map { $0.key }
}

struct PriorityItem<T>{
  let item: T
  let percentage: Double
}

func GetRandomPriorityItem<T>(from items: [PriorityItem<T>]) -> T? {
  let totalPercentage = items.reduce(0){ $0 + $1.percentage }
  let randomValue = Double.random(in: 0..<totalPercentage)
  var cumulativePercentage = 0.0
  for itm in items{
    cumulativePercentage += itm.percentage
    if(randomValue < cumulativePercentage){ return itm.item }
  }
  return nil
}

func ParseArtistName(input: String, getFirst: Bool) -> String? {
  let symbols = [",", "&"]
  var names: [String] = []
  
  let pattern = "(?<!\\S)[\\w.\\s]+(?![\\w.])"
  let regex = try! NSRegularExpression(pattern: pattern, options: [])
  let matches = regex.matches(in: input, options: [], range: NSRange(input.startIndex..., in: input))
  
  for match in matches {
    if let range = Range(match.range, in: input){
      let substring = String(input[range])
      if(!symbols.contains(substring)){ names.append(substring) }
    }
  }
  
  if(getFirst){ return names.first }
  
  if(names.count > 1){
    let bound = names.count
    let randNameIndex = Int.random(in: 0...bound-1)
    let randName = names[randNameIndex]
    return randName
  }
  
  return names.first
}

func FormatTimeToDate(Time: Int?) -> String {
  let dateFormatter = DateFormatter()
  dateFormatter.dateFormat = "MM/dd/yy"
  let date = Date(timeIntervalSince1970: TimeInterval(Time ?? 0))
  return dateFormatter.string(from: date)
}

func TimeElapsedString(Time: Int) -> String {
  let currentTime = Date().timeIntervalSince1970
  let timeElapsed = currentTime - Double(Time)
  if timeElapsed < 60 { return "\(Int(timeElapsed))s"}
  else if timeElapsed < 3600 { return "\(Int(timeElapsed / 60))m" }
  else if timeElapsed < 86400 { return "\(Int(timeElapsed / 3600))h" }
  else if timeElapsed < 604800 { return "\(Int(timeElapsed / 86400))d" }
  else if timeElapsed < 31536000 { return "\(Int(timeElapsed / 604800))w" }
  else{ return "\(Int(timeElapsed / 31536000))y" }
}
