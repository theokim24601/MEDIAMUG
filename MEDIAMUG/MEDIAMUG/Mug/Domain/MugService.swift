//
//  MugService.swift
//  VIDEOMUG
//
//  Created by hbkim on 2021/02/08.
//

import SwiftUI
import Combine
import LinkPresentation

protocol MugService {
  func getLinkItems() -> AnyPublisher<[LinkItem], MugError>
  func addNewLink(urlString: String) -> AnyPublisher<[LinkItem], MugError>
  func deleteLink(id: String) -> AnyPublisher<[LinkItem], MugError>
}

class MugMediaService: MugService {

  @Storage(key: "link_items", defaultValue: [])
  var linkItems: [LinkItem]
  @Storage(key: "is_first_load", defaultValue: true)
  var isFirstLoad: Bool

  init() {
    if isFirstLoad {
      linkItems = ["https://developer.apple.com/news/"].map(LinkItem.init)
      isFirstLoad = false
    }
  }

  func getLinkItems() -> AnyPublisher<[LinkItem], MugError> {
    return Just(linkItems)
      .mapError { _ -> MugError in
        .invalidUrl
      }
      .eraseToAnyPublisher()
  }

  func addNewLink(urlString: String) -> AnyPublisher<[LinkItem], MugError> {
    guard urlString.isValidLink else {
      return Fail(error: MugError.invalidUrl)
        .eraseToAnyPublisher()
    }
    let linkItem = LinkItem(urlString: urlString)
    linkItems.insert(linkItem, at: 0)
    return getLinkItems()
  }

  func deleteLink(id: String) -> AnyPublisher<[LinkItem], MugError> {
    linkItems.removeAll(where: { $0.id == id })
    return getLinkItems()
  }
}

enum MugError: Error {
  case invalidUrl
}
