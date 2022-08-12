//
//  ManagedUser.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 12/08/22.
//

import CoreData

@objc(ManagedUser)
class ManagedUser: NSManagedObject {
    @NSManaged var id: Int
    @NSManaged var name: String?
    @NSManaged var imageUrl: URL?
    @NSManaged var data: Data?
}

extension ManagedUser {
    static func first(with url: URL, in context: NSManagedObjectContext) throws -> ManagedUser? {
        let request = NSFetchRequest<ManagedUser>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedUser.imageUrl), url])
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    var local: LocalUser {
        return LocalUser(id: id, name: name, imageUrl: imageUrl)
    }
}
