//
//  CoreData+UserStore.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 13/08/22.
//

import CoreData

extension CoreDataPostStore: UserStore {
    public func cleanCache(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result {
                try ManagedUser.cleanAll(in: context)
            })
        }
    }

    public func retrieveAll(completion: @escaping RetrievalAllCompletion) {
        perform { context in
            completion( Result {
                try ManagedUser.all(in: context).map {
                    $0.local
                }
            })
        }
    }

    public func deleteCachedUser(_ users: [LocalUser], completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result {
                try ManagedUser.delete(users: users, in: context)
            })
        }
    }

    public func insert(_ user: LocalUser, timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion(Result {
                let managedUser = try ManagedUser.newUniqueInstance(with: user.id, in: context)
                managedUser.name = user.name
                managedUser.imageUrl = user.imageUrl
                managedUser.timestamp = timestamp
                try context.save()
            })
        }
    }

    public func retrieve(userWithId id: Int, completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(Result {
                try ManagedUser.first(with: id, in: context).map { $0.local }
            })
        }
    }
}
