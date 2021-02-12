//
//  CoreDataRepository.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/12.
//

import CoreData

enum CoreDataError: Error {
    case invalidManagedObjectType
}

class CoreDataRepository<T: NSManagedObject>: LocalRepository {
  typealias Entity = T

  /// The NSManagedObjectContext instance to be used for performing the operations.
//  private let persistentContainer: NSPersistentContainer

  private var persistentContainer: NSPersistentCloudKitContainer

  /// Designated initializer.
  /// - Parameter managedObjectContext: The NSManagedObjectContext instance to be used for performing the operations.
  init(persistentContainer: NSPersistentCloudKitContainer) {
    self.persistentContainer = persistentContainer
//    self.persistentContainer = persistentContainer

    NotificationCenter.default.addObserver(
        self, selector: #selector(type(of: self).didFindRelevantTransactions(_:)),
        name: .didFindRelevantTransactions, object: nil)
  }

  var context: NSManagedObjectContext {
    persistentContainer.viewContext
  }

  /// Gets an array of NSManagedObject entities.
  /// - Parameters:
  ///   - predicate: The predicate to be used for fetching the entities.
  ///   - sortDescriptors: The sort descriptors used for sorting the returned array of entities.
  /// - Returns: A result consisting of either an array of NSManagedObject entities or an Error.
  func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> Result<[Entity], Error> {
    // Create a fetch request for the associated NSManagedObjectContext type.
    let fetchRequest = Entity.fetchRequest()
    fetchRequest.predicate = predicate
    fetchRequest.sortDescriptors = sortDescriptors
    do {
      // Perform the fetch request
      if let fetchResults = try context.fetch(fetchRequest) as? [Entity] {
        return .success(fetchResults)
      } else {
        return .failure(CoreDataError.invalidManagedObjectType)
      }
    } catch {
      return .failure(error)
    }
  }

  /// Creates a NSManagedObject entity.
  /// - Returns: A result consisting of either a NSManagedObject entity or an Error.
  func create(completion: (Entity) -> Void) -> Result<Bool, Error> {


//      try managedObjectContext.save()
    context.performAndWait {
      let managedObject = Entity(context: context)
      completion(managedObject)

      context.save(with: .addLink)
    }
    return .success(true)
  }

  /// Deletes a NSManagedObject entity.
  /// - Parameter entity: The NSManagedObject to be deleted.
  /// - Returns: A result consisting of either a Bool set to true or an Error.
  func delete(entity: Entity) -> Result<Bool, Error> {
    context.delete(entity)

    do {
      try context.save()
      return .success(true)
    } catch {
      return .failure(error)
    }
  }

  @objc
  func didFindRelevantTransactions(_ notification: Notification) {
    guard let relevantTransactions = notification.userInfo?["transactions"] as? [NSPersistentHistoryTransaction] else { preconditionFailure() }
    update(with: relevantTransactions)

  }

  private func update(with transactions: [NSPersistentHistoryTransaction]) {
    transactions.forEach { transaction in
      guard let userInfo = transaction.objectIDNotification().userInfo else { return }
      let viewContext = persistentContainer.viewContext
      NSManagedObjectContext.mergeChanges(fromRemoteContextSave: userInfo, into: [viewContext])
    }

    DispatchQueue.main.async {
        NotificationCenter.default.post(name: .didAcceptRemoteChanges, object: self, userInfo: nil)
    }
  }
}
