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

    public enum LoadError: Error {
        case failed
        case notFound
    }

    private final class LoadUserTask: UserLoaderTask {
        private var completion: ((UserLoader.Result) -> Void)?

        init(_ completion: @escaping (UserLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: UserLoader.Result) {
            completion?(result)
        }

        func cancel() {
            preventFurtherCompletions()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }
    }

    @discardableResult
    public func load(userId: Int, completion: @escaping (LoadResult) -> Void) -> UserLoaderTask? {

        let task: LoadUserTask = LoadUserTask(completion)

        store.retrieve(userWithId: userId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                task.complete(with: .failure(LoadError.failed))
            case let .success(.some(user)):
                guard let cacheCreationDate = user.cacheInsertionDate,
                      UserCachePolicy.validate(cacheCreationDate, against: self.currentDate()) else {
                    task.complete(with: .failure(LoadError.notFound))
                    return
                }
                task.complete(with: .success(user.toModel()))

            case .success:
                task.complete(with: .failure(LoadError.notFound))
            }
        }
        return task
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
