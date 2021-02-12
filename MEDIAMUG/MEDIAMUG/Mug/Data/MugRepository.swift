//
//  MugRepository.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/12.
//

import SwiftUI
import CoreData

class MugRepository: Mug {
  private let repository: CoreDataRepository<LinkItemModel>

  init(persistentContainer: NSPersistentCloudKitContainer) {
    self.repository = CoreDataRepository<LinkItemModel>(persistentContainer: persistentContainer)
  }

  func getAll() throws -> [LinkItem] {
    let result = repository.fetch(
      predicate: nil,
      sortDescriptors: [
        NSSortDescriptor(keyPath: \LinkItemModel.updatedAt, ascending: false)
      ]
    )
    switch result {
    case .success(let linkItemModels):
      var linkItems: [LinkItem] = []
      for itemModel in linkItemModels {
        linkItems.append(
          LinkItem(
            id: itemModel.id,
            urlString: itemModel.urlString,
            createdAt: itemModel.createdAt,
            updatedAt: itemModel.updatedAt,
            read: itemModel.read
          )
        )
      }
      return linkItems
    case .failure:
      throw RepositoryError.failedToLoad
    }
  }

  func create(_ linkItem: LinkItem) throws {
    let result = repository.create { linkItemModel in
      linkItemModel.id = linkItem.id
      linkItemModel.urlString = linkItem.urlString
      linkItemModel.createdAt = linkItem.createdAt
      linkItemModel.updatedAt = linkItem.updatedAt
      linkItemModel.read = linkItem.read
    }
    switch result {
    case .success:
      return
    case .failure:
      throw RepositoryError.failedToCreate
    }
  }

  func delete(_ id: String) throws {
    let fetchResult = repository.fetch(predicate: nil, sortDescriptors: [])
    switch fetchResult {
    case .success(let linkItemModels):
      if let linkItemModel = linkItemModels.first(where: { $0.id == id }) {
        let deleteResult = repository.delete(entity: linkItemModel)
        switch deleteResult {
        case .success:
          return
        case .failure:
          break
        }
      }
    case .failure:
      break
    }
    throw RepositoryError.failedToDelete
  }

  func exist(_ urlString: String) -> Bool {
    do {
      let linkItems = try getAll()
      return linkItems.contains(where: { $0.urlString == urlString })
    } catch {
      return false
    }
  }
}
