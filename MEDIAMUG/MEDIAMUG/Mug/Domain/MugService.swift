//
//  MugService.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/08.
//

import SwiftUI
import Combine

protocol MugService {
  func getLinkItems() -> AnyPublisher<[LinkItem], MugError>
  func addNewLink(urlString: String) -> AnyPublisher<[LinkItem], MugError>
  func deleteLink(id: String) -> AnyPublisher<[LinkItem], MugError>
  func existLink(urlString: String) -> AnyPublisher<Bool, MugError>
}

class MugMediaService: MugService {
  @Storage(key: "is_first_load", defaultValue: true)
  var isFirstLoad: Bool

  private let mug: Mug
  init(mug: Mug) {
    self.mug = mug
    if isFirstLoad {
//      linkItems = ["https://www.youtube.com/watch?v=GEZhD3J89ZE"].map(LinkItem.init)
      isFirstLoad = false
    }
  }

  func getLinkItems() -> AnyPublisher<[LinkItem], MugError> {
    do {
      let linkItems = try mug.getAll()
      return Just(linkItems)
        .mapError { _ -> MugError in
          .failedToLoad
        }
        .eraseToAnyPublisher()
    } catch {
      return Fail(error: MugError.failedToLoad)
        .eraseToAnyPublisher()
    }
  }

  func addNewLink(urlString: String) -> AnyPublisher<[LinkItem], MugError> {
    guard urlString.isValidLink else {
      return Fail(error: MugError.invalidUrl)
        .eraseToAnyPublisher()
    }
    let linkItem = LinkItem(urlString: urlString)
    do {
      try mug.create(linkItem)
      return getLinkItems()
    } catch {
      return Fail(error: MugError.failedToCreate)
        .eraseToAnyPublisher()
    }
  }

  func deleteLink(id: String) -> AnyPublisher<[LinkItem], MugError> {
    do {
      try mug.delete(id)
      return getLinkItems()
    } catch {
      return Fail(error: MugError.failedToDelete)
        .eraseToAnyPublisher()
    }
  }

  func existLink(urlString: String) -> AnyPublisher<Bool, MugError> {
    let exist = mug.exist(urlString)
    return Just(exist)
      .mapError { _ -> MugError in
        .failedToLoad
      }
      .eraseToAnyPublisher()
  }
}
