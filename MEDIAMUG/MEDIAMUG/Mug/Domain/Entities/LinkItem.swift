//
//  LinkItem.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/09.
//

import Foundation

struct LinkItem: Codable, Hashable {
  var id: String = UUID().uuidString
  var urlString: String
  var createdAt: Date = Date()
  var updatedAt: Date = Date()
  var read: Bool = false

  init(urlString: String) {
    self.urlString = urlString
  }
}
