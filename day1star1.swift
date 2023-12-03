import Foundation

func f(_ s: String) -> Int {
  s.components(separatedBy: .newlines).map {
    let x = $0.compactMap(\.wholeNumberValue)
    return x.first! * 10 + x.last!
  }.reduce(0, +)
}
