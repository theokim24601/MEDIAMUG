//
//  CoreDataStack.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/12.
//

import CoreData

class CoreDataContextProvider {
  static let shared = CoreDataContextProvider()

  lazy var persistentContainer: NSPersistentCloudKitContainer = {
    let path = filesFolder
    let localStoreLocation = path.appendingPathComponent("local.sqlite")
    let localStoreDescription = NSPersistentStoreDescription(url: localStoreLocation)
    localStoreDescription.configuration = "Local"
    localStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
    localStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

    let cloudStoreLocation = path.appendingPathComponent("cloud.sqlite")
    let cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreLocation)
    cloudStoreDescription.configuration = "Cloud"
    cloudStoreDescription.cloudKitContainerOptions =
      NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.seasons.mediamug")
    cloudStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
    cloudStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

    let container = NSPersistentCloudKitContainer(name: "MEDIAMUG")
    container.persistentStoreDescriptions = [
      cloudStoreDescription,
      localStoreDescription
    ]
    container.loadPersistentStores { storeDescription, error in
      if let error = error as NSError? {
        fatalError("###\(#function): Failed to load persistent stores:\(error)")
      }
    }
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    container.viewContext.transactionAuthor = appTransactionAuthorName

    // Pin the viewContext to the current generation token and set it to keep itself up to date with local changes.
    container.viewContext.automaticallyMergesChangesFromParent = true
    do {
        try container.viewContext.setQueryGenerationFrom(.current)
    } catch {
        fatalError("###\(#function): Failed to pin viewContext to the current generation:\(error)")
    }

    // Observe Core Data remote change notifications.
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(type(of: self).storeRemoteChange(_:)),
      name: .NSPersistentStoreRemoteChange,
      object: container.persistentStoreCoordinator
    )

    return container
  }()

  /**
   Track the last history token processed for a store, and write its value to file.

   The historyQueue reads the token when executing operations, and updates it after processing is complete.
   */
  private var lastHistoryToken: NSPersistentHistoryToken? = nil {
    didSet {
      guard let token = lastHistoryToken,
            let data = try? NSKeyedArchiver.archivedData( withRootObject: token, requiringSecureCoding: true) else { return }

      do {
        try data.write(to: tokenFile)
      } catch {
        print("###\(#function): Failed to write token data. Error = \(error)")
      }
    }
  }

  /**
   The file URL for persisting the persistent history token.
  */
  private lazy var tokenFile: URL = {
    let url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("MEDIAMUG", isDirectory: true)
    if !FileManager.default.fileExists(atPath: url.path) {
      do {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
      } catch {
        print("###\(#function): Failed to create persistent container URL. Error = \(error)")
      }
    }
    return url.appendingPathComponent("token.data", isDirectory: false)
  }()

  /**
   An operation queue for handling history processing tasks: watching changes, deduplicating tags, and triggering UI updates if needed.
   */
  private lazy var historyQueue: OperationQueue = {
      let queue = OperationQueue()
      queue.maxConcurrentOperationCount = 1
      return queue
  }()

  /**
   The URL of the link files folder.
   */
  private var filesFolder: URL = {
    var url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("MEDIAMUG", isDirectory: true)
    url = url.appendingPathComponent("files", isDirectory: true)

    // Create it if it doesn’t exist.
    if !FileManager.default.fileExists(atPath: url.path) {
      do {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
      } catch {
        print("###\(#function): Failed to files folder URL: \(error)")
      }
    }
    return url
  }()

  init() {
    // Load the last token from the token file.
    if let tokenData = try? Data(contentsOf: tokenFile) {
      do {
        lastHistoryToken = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSPersistentHistoryToken.self, from: tokenData)
      } catch {
        print("###\(#function): Failed to unarchive NSPersistentHistoryToken. Error = \(error)")
      }
    }
  }
}

// MARK: - Notifications

extension CoreDataContextProvider {
  /**
   Handle remote store change notifications (.NSPersistentStoreRemoteChange).
   */
  @objc
  func storeRemoteChange(_ notification: Notification) {
    print("###\(#function): Merging changes from the other persistent store coordinator.")
    
    // Process persistent history to merge changes from other coordinators.
    historyQueue.addOperation {
      self.processPersistentHistory()
    }
  }
}

/**
 Custom notifications
 */
extension Notification.Name {
  static let didFindRelevantTransactions = Notification.Name("didFindRelevantTransactions")
  static let didAcceptRemoteChanges = Notification.Name("didAcceptRemoteChanges")
}

// MARK: - Persistent history processing

extension CoreDataContextProvider {

  /**
   Process persistent history, posting any relevant transactions to the current view.
   */
  func processPersistentHistory() {
    let taskContext = persistentContainer.newBackgroundContext()
    taskContext.performAndWait {

      // Fetch history received from outside the app since the last token
      let historyFetchRequest = NSPersistentHistoryTransaction.fetchRequest!
      historyFetchRequest.predicate = NSPredicate(format: "author != %@", appTransactionAuthorName)
      let request = NSPersistentHistoryChangeRequest.fetchHistory(after: lastHistoryToken)
      request.fetchRequest = historyFetchRequest

      let result = (try? taskContext.execute(request)) as? NSPersistentHistoryResult
      guard let transactions = result?.result as? [NSPersistentHistoryTransaction],
            !transactions.isEmpty
      else { return }

      // Post transactions relevant to the current view.
      DispatchQueue.main.async {
        NotificationCenter.default.post(name: .didFindRelevantTransactions, object: self, userInfo: ["transactions": transactions])
      }

      // Deduplicate the new tags.
      var newLinkObjectIDs = [NSManagedObjectID]()
      let linkEntityName = LinkItemModel.entity().name

      for transaction in transactions where transaction.changes != nil {
        for change in transaction.changes!
        where change.changedObjectID.entity.name == linkEntityName && change.changeType == .insert {
          newLinkObjectIDs.append(change.changedObjectID)
        }
      }
      if !newLinkObjectIDs.isEmpty {
        deduplicateAndWait(linkObjectIDs: newLinkObjectIDs)
      }

      // Update the history token using the last transaction.
      lastHistoryToken = transactions.last!.token
    }
  }
}

// MARK: - Deduplicate links

extension CoreDataContextProvider {
  /**
   Deduplicate links with the same name by processing the persistent history, one link at a time, on the historyQueue.

   All peers should eventually reach the same result with no coordination or communication.
   */
  private func deduplicateAndWait(linkObjectIDs: [NSManagedObjectID]) {
    // Make any store changes on a background context
    let taskContext = persistentContainer.backgroundContext()

    // Use performAndWait because each step relies on the sequence. Since historyQueue runs in the background, waiting won’t block the main queue.
    taskContext.performAndWait {
      linkObjectIDs.forEach { linkObjectID in
        self.deduplicate(linkObjectID: linkObjectID, performingContext: taskContext)
      }
      // Save the background context to trigger a notification and merge the result into the viewContext.
      taskContext.save(with: .deduplicate)
    }
  }

  /**
   Deduplicate a single link.
   */
  private func deduplicate(linkObjectID: NSManagedObjectID, performingContext: NSManagedObjectContext) {
    guard let linkItemModel = performingContext.object(with: linkObjectID) as? LinkItemModel else {
      fatalError("###\(#function): Failed to retrieve a valid link with ID: \(linkObjectID)")
    }

    let linkUrl = linkItemModel.urlString
    // Fetch all links with the same name, sorted by uuid
    let fetchRequest: NSFetchRequest<LinkItemModel> = LinkItemModel.fetchRequest()
    fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \LinkItemModel.urlString, ascending: true)]
    fetchRequest.predicate = NSPredicate(format: "urlString == %@", linkUrl)

    // Return if there are no duplicates.
    guard var duplicatedLinks = try? performingContext.fetch(fetchRequest), duplicatedLinks.count > 1 else {
      return
    }
    print("###\(#function): Deduplicating link with url: \(linkUrl), count: \(duplicatedLinks.count)")

    // Pick the first link as the winner.
    let winner = duplicatedLinks.first!
    duplicatedLinks.removeFirst()
    remove(duplicatedLinks: duplicatedLinks, winner: winner, performingContext: performingContext)
  }

  /**
   Remove duplicate links from their respective posts, replacing them with the winner.
   */
  private func remove(duplicatedLinks: [LinkItemModel], winner: LinkItemModel, performingContext: NSManagedObjectContext) {
    duplicatedLinks.forEach { link in
      performingContext.delete(link)
    }
  }
}
