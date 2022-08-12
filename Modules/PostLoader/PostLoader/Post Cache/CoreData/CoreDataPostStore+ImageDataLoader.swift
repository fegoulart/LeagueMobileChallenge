//
//  CoreDataPostStore+ImageDataLoader.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 12/08/22.
//

import Foundation

extension CoreDataPostStore: ImageDataStore {

    public func insert(_ data: Data, for url: URL, completion: @escaping (ImageDataStore.InsertionResult) -> Void) {
        perform { context in
            completion(Result {
                try ManagedUser.first(with: url, in: context)
                    .map { $0.data = data }
                    .map(context.save)
            })
        }
    }

    public func retrieve(dataForURL url: URL, completion: @escaping (ImageDataStore.RetrievalResult) -> Void) {
        perform { context in
            completion(Result {
                try ManagedUser.first(with: url, in: context)?.data
            })
        }
    }

}
