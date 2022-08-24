//
//  UserImageDataLoaderCacheDecorator.swift
//  LeagueMobileChallenge
//
//  Created by Fernando Luiz Goulart on 23/08/22.
//  Copyright © 2022 Kelvin Lau. All rights reserved.
//

import PostLoader

public final class UserImageDataLoaderCacheDecorator: UserImageDataLoader {

    public func loadUserImageData(
        url: URL,
        userId: Int,
        completion: @escaping (
            UserImageDataLoader.Result
        ) -> Void
    ) -> UserImageDataLoaderTask {
        decoratee.loadUserImageData(
            url: url,
            userId: userId
        ) { [weak self] result in
            completion(result.map { userImageData in
                self?.cache.saveIgnoringResult(
                    data: userImageData,
                    userId: userId,
                    url: url
                )
                return userImageData
            })
        }
    }

    private let decoratee: UserImageDataLoader
    private let cache: UserImageDataCache

    public init(decoratee: UserImageDataLoader, cache: UserImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
}

private extension UserImageDataCache {
    func saveIgnoringResult(data: Data, userId: Int, url: URL) {
        save(data, userId: userId, url: url) { _ in }
    }
}
