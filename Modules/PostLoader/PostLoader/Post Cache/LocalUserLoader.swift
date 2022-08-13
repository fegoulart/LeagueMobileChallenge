//
//  LocalUserLoader.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 13/08/22.
//

import Foundation

public final class LocalUserLoader {
    private let store: UserStore
    private let currentDate: () -> Date

    public init(store: UserStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
}

extension LocalUserLoader: UserCache {
    public typealias SaveResult = UserCache.Result

    public func save(_ user: User, completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedUser([user.toLocal()]) { [weak self] deletionResult in
            guard let self = self else { return }

            switch deletionResult {
            case .success:
                self.cache(user, with: completion)

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    private func cache(_ user: User, with completion: @escaping (SaveResult) -> Void) {
        store.insert(user.toLocal(), timestamp: currentDate()) { [weak self] insertionResult in
            guard self != nil else { return }

            completion(insertionResult)
        }
    }
}

extension LocalUserLoader: UserLoader {
    public typealias LoadResult = UserLoader.Result

    public func load(userId: Int, completion: @escaping (LoadResult) -> Void) {
        store.retrieve(userWithId: userId) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .failure(error):
                completion(.failure(error))

            case let .success(.some(user)):

                guard let cacheCreationDate = user.cacheInsertionDate,
                        UserCachePolicy.validate(cacheCreationDate, against: self.currentDate()) else {
                    completion(.success(nil))
                    return
                }
                completion(.success(user.toModel()))

            case .success:
                completion(.success(nil))
            }
        }
    }
}

extension LocalUserLoader {
    public typealias ValidationResult = Result<Void, Error>

    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        store.retrieveAll { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure:
                self.store.cleanCache(completion: completion)

            case let .success(users):
                let expiredUsers: [LocalUser] = users.filter { cachedUser in
                    guard let timestamp = cachedUser.cacheInsertionDate else {
                        return false
                    }
                    return !UserCachePolicy.validate(timestamp, against: self.currentDate())
                }
                guard !expiredUsers.isEmpty else {
                    completion(.success(()))
                    return
                }
                self.store.deleteCachedUser(expiredUsers, completion: completion)
            }
        }
    }
}

private extension User {
    func toLocal() -> LocalUser {
        return LocalUser(id: self.id, name: self.name, imageUrl: self.imageUrl, cacheInsertionDate: nil)
    }
}

private extension LocalUser {
    func toModel() -> User {
        return User(id: self.id, name: self.name, imageUrl: self.imageUrl)
    }
}
