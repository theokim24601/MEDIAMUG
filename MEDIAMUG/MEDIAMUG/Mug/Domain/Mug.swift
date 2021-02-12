//
//  Mug.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/12.
//

import SwiftUI
import Combine

protocol Mug {
  func getAll() throws -> [LinkItem]
  func create(_ linkItem: LinkItem) throws
  func delete(_ id: String) throws
  func exist(_ urlString: String) -> Bool
}
