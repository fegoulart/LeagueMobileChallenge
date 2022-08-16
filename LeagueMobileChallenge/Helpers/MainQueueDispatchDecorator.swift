//
//  MainQueueDispatchDecorator.swift
//  LeagueMobileChallenge
//
//  Created by Fernando Luiz Goulart on 16/08/22.
//  Copyright © 2022 Kelvin Lau. All rights reserved.
//

import Foundation
import PostLoader

final class MainQueueDispatchDecorator<T> {
    private let decoratee: T

    init(decoratee: T) {
        self.decoratee = decoratee
    }

    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }

        completion()
    }
}

extension MainQueueDispatchDecorator: PostLoader where T == PostLoader {
    func load(completion: @escaping (PostLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: UserLoader where T == UserLoader {
    func load(userId: Int, completion: @escaping (UserLoader.Result) -> Void) -> UserLoaderTask? {
        decoratee.load(userId: userId) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: UserImageDataLoader where T == UserImageDataLoader {
    func loadUserImageData(
        url: URL,
        userId: Int,
        completion: @escaping (UserImageDataLoader.Result) -> Void
    ) -> UserImageDataLoaderTask {
        decoratee.loadUserImageData(url: url, userId: userId) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
