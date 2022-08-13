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
    @NSManaged var timestamp: Date
}

extension ManagedUser {
    static func first(with id: Int, in context: NSManagedObjectContext) throws -> ManagedUser? {
        let request = NSFetchRequest<ManagedUser>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "id == %i", id)
        request.returnsObjectsAsFaults = false
        request.fetchLimit = 1
        return try context.fetch(request).first
    }

    static func all(in context: NSManagedObjectContext) throws -> [ManagedUser] {
        let request = NSFetchRequest<ManagedUser>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request)
    }

    static func cleanAll(in context: NSManagedObjectContext) throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity().name!)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        try context.execute(deleteRequest)
    }

    static func delete(users: [LocalUser], in context: NSManagedObjectContext) throws {
        guard !users.isEmpty else { return }
        let ids: [Int] = users.map { $0.id }
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity().name!)
        request.predicate = NSPredicate(format: "id IN %@", ids)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        try context.execute(deleteRequest)
    }

    static func newUniqueInstance(with id: Int, in context: NSManagedObjectContext) throws -> ManagedUser {
        try first(with: id, in: context).map(context.delete)
        let newManagedUser = ManagedUser(context: context)
        newManagedUser.id = id
        return newManagedUser
    }

    var local: LocalUser {
        return LocalUser(id: id, name: name, imageUrl: imageUrl, cacheInsertionDate: timestamp)
    }
}
