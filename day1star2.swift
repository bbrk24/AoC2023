import Foundation
import RegexBuilder

let digits: [Substring] = [
  "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"
]

let regex = ChoiceOf {
  Capture(.digit) { Int($0)! }
  Capture {
    ChoiceOf {
      "one"
      "two"
      "three"
      "four"
      "five"
      "six"
      "seven"
      "eight"
      "nine"
    }
  } transform: {
    digits.firstIndex(of: $0)! + 1
  }
}

extension String {
  func firstAndLastMatch<T: RegexComponent>(of regex: T) -> (Regex<T.RegexOutput>.Match, Regex<T.RegexOutput>.Match)? {
    guard let firstMatch = self.firstMatch(of: regex) else {
      return nil
    }
    let lastMatch = self.indices.reversed().lazy.compactMap {
      self[$0...].prefixMatch(of: regex)
    }.first ?? firstMatch
    return (firstMatch, lastMatch)
  }
}

func f(_ s: String) -> Int {
  s.components(separatedBy: .newlines).map {
    let (firstMatch, lastMatch) = $0.firstAndLastMatch(of: regex)!
    let first = firstMatch.output.1 ?? firstMatch.output.2!
    let last = lastMatch.output.2 ?? lastMatch.output.1!
    return first * 10 + last
  }.reduce(0, +)
}
