//
//  LocalImageDataLoader.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 12/08/22.
//

import Foundation

public final class LocalUserImageDataLoader {
    private let store: UserImageDataStore

    public init(store: UserImageDataStore) {
        self.store = store
    }
}

extension LocalUserImageDataLoader: UserImageDataCache {

    public typealias SaveResult = UserImageDataCache.Result

    public enum SaveError: Error {
        case failed
    }

    public func save(
        _ data: Data,
        userId: Int,
        url: URL,
        completion: @escaping (SaveResult) -> Void
    ) {
        store.insert(data, userId: userId, url: url) { [weak self] result in
            guard self != nil else { return }
            completion(result.mapError { _ in SaveError.failed })
        }
    }
}

extension LocalUserImageDataLoader: UserImageDataLoader {

    public typealias LoadResult = UserImageDataLoader.Result

    public enum LoadError: Error {
        case failed
        case notFound
    }

    private final class LoadImageDataTask: UserImageDataLoaderTask {
        private var completion: ((UserImageDataLoader.Result) -> Void)?

        init(_ completion: @escaping (UserImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: UserImageDataLoader.Result) {
            completion?(result)
        }

        func cancel() {
            preventFurtherCompletions()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }
    }

    public func loadUserImageData(
        url: URL,
        userId: Int,
        completion: @escaping (LoadResult) -> Void
    ) -> UserImageDataLoaderTask {
        let task = LoadImageDataTask(completion)
        store.retrieve(dataForURL: url, userId: userId) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result
                .mapError { _ in LoadError.failed }
                .flatMap { data in
                    data.map { .success($0) } ?? .failure(LoadError.notFound)
                }
            )
        }
        return task
    }
}
