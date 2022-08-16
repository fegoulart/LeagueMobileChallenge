//
//  InMemoryUserStore
//  LeagueMobileChallenge
//
//  Created by Fernando Luiz Goulart on 16/08/22.
//  Copyright © 2022 Kelvin Lau. All rights reserved.
//

import Foundation
import PostLoader

class InMemoryUserStore {

    private(set) var userCache: [Int: LocalUser] = [:]
    private(set) var userImageCache: [Int: Data?] = [:]

    private init(userCache: [Int: LocalUser] = [:], userImageCache: [Int: Data?] = [:]) {
        self.userCache = userCache
        self.userImageCache = userImageCache
    }
}

extension InMemoryUserStore: UserStore {
    func deleteCachedUser(_ users: [LocalUser], completion: @escaping DeletionCompletion) {
        for user in users {
            userCache.removeValue(forKey: user.id)
            userImageCache.removeValue(forKey: user.id)
        }
        completion(.success(()))
    }

    func insert(_ user: LocalUser, timestamp: Date, completion: @escaping InsertionCompletion) {
        userCache.updateValue(user, forKey: user.id)
        userImageCache.updateValue(nil, forKey: user.id)
        completion(.success(()))
    }

    func retrieve(userWithId id: Int, completion: @escaping RetrievalCompletion) {
        let retrievedUser: LocalUser? = userCache[id]
        completion(.success(retrievedUser))
    }

    func retrieveAll(completion: @escaping RetrievalAllCompletion) {
        var result: [LocalUser] = []
        for item in userCache {
            result.append(item.value)
        }
        completion(.success(result))
    }

    func cleanCache(completion: @escaping DeletionCompletion) {
        userCache.removeAll()
        userImageCache.removeAll()
        completion(.success(()))
    }
}

extension InMemoryUserStore: UserImageDataStore {
    func insert(_ data: Data, userId: Int, url: URL, completion: @escaping (InsertionResult) -> Void) {
        userImageCache.updateValue(data, forKey: userId)
        completion(.success(()))
    }

    func retrieve(
        dataForURL url: URL,
        userId: Int,
        completion: @escaping (UserImageDataStore.RetrievalResult) -> Void
    ) {
        let data: Data? = userImageCache[userId] ?? nil
        completion(.success(data))
    }
}

extension InMemoryUserStore {
    static var empty: InMemoryUserStore {
        InMemoryUserStore()
    }

    static var withExpiredUserCache: InMemoryUserStore {
        InMemoryUserStore(
            userCache: [
                1: expiredUsers[0],
                2: expiredUsers[1]
            ]
        )
    }

    static var withNonExpiredUserCache: InMemoryUserStore {
        InMemoryUserStore(
            userCache: [
                3: nonExpiredUsers[0],
                4: nonExpiredUsers[1]
            ]
        )
    }
}

extension InMemoryUserStore {
    static let expiredUsers: [LocalUser] = [
        LocalUser(
            id: 1,
            name: "Ernest",
            imageUrl: nil,
            cacheInsertionDate: Date.distantPast
        ),
        LocalUser(
            id: 2,
            name: "John",
            imageUrl: nil,
            cacheInsertionDate: Date.distantPast
        )
    ]

    static let nonExpiredUsers: [LocalUser] = [
        LocalUser(
            id: 3,
            name: "Paul",
            imageUrl: nil,
            cacheInsertionDate: Date()
        ),
        LocalUser(
            id: 4,
            name: "Mary",
            imageUrl: nil,
            cacheInsertionDate: Date()
        )
    ]
}
