//
//  Apply.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/10.
//

import Foundation

public protocol Apply {}
public extension Apply where Self: Any {

  ///  `apply`
  ///
  ///  let org = Organization().apply {
  ///    $0.name = "podo"
  ///    $0.member = Member(name: "esther", role: .owner)
  ///  }
  @discardableResult
  func apply(_ block: ((Self) throws -> Void)) rethrows -> Self {
    try block(self)
    return self
  }
}

extension NSObject: Apply {}

extension Array: Apply {}
extension Dictionary: Apply {}
extension Set: Apply {}
