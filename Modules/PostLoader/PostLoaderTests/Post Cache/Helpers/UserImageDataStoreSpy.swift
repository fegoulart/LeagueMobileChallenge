//
//  ImageDataStoreSpy.swift
//  PostLoaderTests
//
//  Created by Fernando Luiz Goulart on 12/08/22.
//

import Foundation
import PostLoader

class UserImageDataStoreSpy: UserImageDataStore {
    func insert(
        _ data: Data,
        userId: Int,
        url: URL,
        completion: @escaping (UserImageDataStore.InsertionResult) -> Void
    ) {
        receivedMessages.append(.insert(data: data, for: url))
        insertionCompletions.append(completion)
    }

    func retrieve(
        dataForURL url: URL,
        userId: Int,
        completion: @escaping (UserImageDataStore.RetrievalResult) -> Void
    ) {
        receivedMessages.append(.retrieve(dataFor: url))
        retrievalCompletions.append(completion)
    }

    enum Message: Equatable {
        case insert(data: Data, for: URL)
        case retrieve(dataFor: URL)
    }

    private(set) var receivedMessages = [Message]()
    private var retrievalCompletions = [(UserImageDataStore.RetrievalResult) -> Void]()
    private var insertionCompletions = [(UserImageDataStore.InsertionResult) -> Void]()

    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }

    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
}
