//
//  LocalRepository.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/12.
//

import CoreData

protocol LocalRepository {
  /// The entity managed by the repository.
  associatedtype Entity
  
  /// Gets an array of entities.
  /// - Parameters:
  ///   - predicate: The predicate to be used for fetching the entities.
  ///   - sortDescriptors: The sort descriptors used for sorting the returned array of entities.
  func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> Result<[Entity], Error>
  
  /// Creates an entity.
  func create(completion: (Entity) -> Void) -> Result<Bool, Error>

  /// Deletes an entity.
  /// - Parameter entity: The entity to be deleted.
  func delete(entity: Entity) -> Result<Bool, Error>
}
