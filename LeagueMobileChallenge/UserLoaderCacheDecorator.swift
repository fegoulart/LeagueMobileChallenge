//
//  UserLoaderCacheDecorator.swift
//  LeagueMobileChallenge
//
//  Created by Fernando Luiz Goulart on 23/08/22.
//  Copyright © 2022 Kelvin Lau. All rights reserved.
//

import PostLoader

public final class UserLoaderCacheDecorator: UserLoader {
    public func load(userId: Int, completion: @escaping (UserLoader.Result) -> Void) -> UserLoaderTask? {
        decoratee.load(userId: userId) { [weak self] result in
            completion(result.map { user in
                if let user = user {
                    self?.cache.saveIgnoringResult(user)
                }
                return user
            })
        }
    }

    private let decoratee: UserLoader
    private let cache: UserCache

    public init(decoratee: UserLoader, cache: UserCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
}

private extension UserCache {
    func saveIgnoringResult(_ user: User) {
        save(user) { _ in }
    }
}
