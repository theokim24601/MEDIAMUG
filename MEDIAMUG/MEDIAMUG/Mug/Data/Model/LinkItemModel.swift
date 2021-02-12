//
//  LinkItemModel.swift
//  MEDIAMUG
//
//  Created by hbkim on 2021/02/12.
//

import CoreData

class LinkItemModel: NSManagedObject {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<LinkItemModel> {
      return NSFetchRequest<LinkItemModel>(entityName: "LinkItemModel")
  }

  @NSManaged var id: String
  @NSManaged var urlString: String
  @NSManaged var createdAt: Date
  @NSManaged var updatedAt: Date
  @NSManaged var read: Bool
}
