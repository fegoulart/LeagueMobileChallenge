//
//  CoreDataPostStore+ImageDataLoader.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 12/08/22.
//

import Foundation

extension CoreDataPostStore: UserImageDataStore {
    public func insert(_ data: Data, userId: Int, url: URL, completion: @escaping (InsertionResult) -> Void) {
        perform { context in
            completion(Result {
                try ManagedUser.first(with: userId, in: context)
                    .map { $0.data = data }
                    .map(context.save)
            })
        }
    }

    public func retrieve(
        dataForURL url: URL,
        userId: Int,
        completion: @escaping (UserImageDataStore.RetrievalResult) -> Void) {
        perform { context in
            completion(Result {
                try ManagedUser.first(with: userId, in: context)?.data
            })
        }
    }
}
