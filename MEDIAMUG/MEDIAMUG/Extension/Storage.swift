//
//  Storage.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/10.
//

import Foundation

@propertyWrapper
struct Storage<T: Codable> {
  private let key: String
  private let defaultValue: T

  init(key: String, defaultValue: T) {
    self.key = key
    self.defaultValue = defaultValue
  }

  var wrappedValue: T {
    get {
      guard let data = UserDefaults.standard.data(forKey: key) else {
        return defaultValue
      }
      let value = try? JSONDecoder().decode(T.self, from: data)
      return value ?? defaultValue
    }
    set {
      let data = try? JSONEncoder().encode(newValue)

      UserDefaults.standard.set(data, forKey: key)
    }
  }
}
