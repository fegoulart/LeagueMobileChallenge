//
//  ManagedPostCache.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 13/08/22.
//

import CoreData

@objc(ManagedPostCache)
class ManagedPostCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var user: NSOrderedSet
}

extension ManagedPostCache {
    static func find(in context: NSManagedObjectContext) throws -> ManagedPostCache? {
        let request = NSFetchRequest<ManagedPostCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }

    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedPostCache {
        try find(in: context).map(context.delete)
        return ManagedPostCache(context: context)
    }

    var localUser: [LocalPost] {
        return user.compactMap { ($0 as? ManagedPost)?.local }
    }
}
