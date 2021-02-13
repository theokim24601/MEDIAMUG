//
//  String+Validator.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/10.
//

import UIKit

extension String {
  var isValidLink: Bool {
    let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
    if let url = URL(string: self),
       let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
      return match.range.length == self.utf16.count && UIApplication.shared.canOpenURL(url)
    }
    return false
  }

  func refineLink() -> String? {
    let link = self.trimmingCharacters(in: .whitespacesAndNewlines)
    if link.isValidLink {
      return link
    }

    if link.hasPrefix("https") || link.hasPrefix("http") {
      return nil
    }

    let httpsUrl = "https://" + link
    if httpsUrl.isValidLink {
      return httpsUrl
    }

    let httpUrl = "http://" + link
    if httpUrl.isValidLink {
      return httpUrl
    }

    return nil
  }
}
