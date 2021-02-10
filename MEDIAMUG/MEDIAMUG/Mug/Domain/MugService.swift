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

  lazy var operationQueue: OperationQueue = {
      let queue = OperationQueue()
      queue.maxConcurrentOperationCount = 10
    queue.qualityOfService = .userInteractive
      return queue
  }()

  @Storage(key: "link_items", defaultValue: [])
  var linkItems: [LinkItem]
  @Storage(key: "is_first_load", defaultValue: true)
  var isFirstLoad: Bool

  init() {
    if isFirstLoad {
      linkItems = ["https://developer.apple.com/news/"].map(LinkItem.init)
      isFirstLoad = false
    }
    linkItems = [ "https://medium.com/official-podo/ios-clean-architecture-with-tdd-2-entities-use-cases-81be5a714a14", "https://medium.com/charged-tech/apple-just-told-the-world-it-has-no-idea-who-the-mac-is-for-722a2438389b"].map(LinkItem.init)

//    linkItems = [ "https://medium.com/official-podo/ios-clean-architecture-with-tdd-2-entities-use-cases-81be5a714a14", "https://medium.com/charged-tech/apple-just-told-the-world-it-has-no-idea-who-the-mac-is-for-722a2438389b", "", "", "", "", "", "", "", "", ""].map(LinkItem.init)
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
