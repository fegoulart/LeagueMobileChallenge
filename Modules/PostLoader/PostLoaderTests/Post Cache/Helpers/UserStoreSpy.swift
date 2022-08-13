//
//  UserStoreSpy.swift
//  PostLoaderTests
//
//  Created by Fernando Luiz Goulart on 13/08/22.
//

import Foundation
import PostLoader

class UserStoreSpy: UserStore {
    enum ReceivedMessage: Equatable {
        case deleteCachedUser([LocalUser])
        case insert(LocalUser, Date)
        case retrieve(Int)
        case retrieveAll
        case cleanCache
    }

    init() { }

    private(set) var receivedMessages = [ReceivedMessage]()

    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletion]()
    private var retrievalCompletions = [RetrievalCompletion]()
    private var retrievalAllCompletions = [RetrievalAllCompletion]()
    private var cleanCacheCompletions = [DeletionCompletion]()

    func deleteCachedUser(
        _ users: [LocalUser],
        completion: @escaping DeletionCompletion
    ) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedUser(users))
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }

    func insert(_ user: LocalUser, timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(user, timestamp))
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }

    func retrieve(
        userWithId id: Int,
        completion: @escaping RetrievalCompletion
    ) {
        retrievalCompletions.append(completion)
        receivedMessages.append(.retrieve(id))
    }

    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }

    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompletions[index](.success(.none))
    }

    func completeRetrievalAllWithEmptyCache(at index: Int = 0) {
        retrievalAllCompletions[index](.success([]))
    }

    func completeRetrieval(with user: LocalUser, timestamp: Date, at index: Int = 0) {
        var expectedUser = user
        expectedUser.cacheInsertionDate = timestamp
        retrievalCompletions[index](.success(expectedUser))
    }

    func retrieveAll(completion: @escaping RetrievalAllCompletion) {
        retrievalAllCompletions.append(completion)
        receivedMessages.append(.retrieveAll)
    }

    func completeRetrievalAll(with error: Error, at index: Int = 0) {
        retrievalAllCompletions[index](.failure(error))
    }

    func completeRetrievalAll(with users: [LocalUser], timestamp: Date, at index: Int = 0) {
        let expectedUsers = users.map {
            return LocalUser(id: $0.id, name: $0.name, imageUrl: $0.imageUrl, cacheInsertionDate: timestamp)
        }
        retrievalAllCompletions[index](.success(expectedUsers))
    }

    func cleanCache(completion: @escaping DeletionCompletion) {
        cleanCacheCompletions.append(completion)
        receivedMessages.append(.cleanCache)
    }

    func completeCleanCache(with error: Error, at index: Int = 0) {
        cleanCacheCompletions[index](.failure(error))
    }

    func completeCleanCacheSuccessfully(at index: Int = 0) {
        cleanCacheCompletions[index](.success(()))
    }
}
