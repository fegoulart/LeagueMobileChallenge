//
//  ManagedPost.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 13/08/22.
//

import CoreData

@objc(ManagedPost)
class ManagedPost: NSManagedObject {
    @NSManaged var id: Int
    @NSManaged var userId: Int
    @NSManaged var title: String?
    @NSManaged var body: String?
}

extension ManagedPost {
    static func first(with id: Int, in context: NSManagedObjectContext) throws -> ManagedPost? {
        let request = NSFetchRequest<ManagedPost>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "id == %i", id)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    var local: LocalPost {
        return LocalPost(id: id, userId: userId, title: title, body: body)
    }
}
