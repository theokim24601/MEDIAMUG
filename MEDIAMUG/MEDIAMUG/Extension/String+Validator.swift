//
//  String+Validator.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/10.
//

import Foundation

extension String {
  var isValidLink: Bool {
    let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
      return match.range.length == self.utf16.count
    } else {
      return false
    }
  }
}
