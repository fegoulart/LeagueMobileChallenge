//
//  LocalImageDataLoader.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 12/08/22.
//

import Foundation

public final class LocalImageDataLoader {
    private let store: ImageDataStore

    public init(store: ImageDataStore) {
        self.store = store
    }
}

extension LocalImageDataLoader: ImageDataCache {
    public typealias SaveResult = ImageDataCache.Result

    public enum SaveError: Error {
        case failed
    }

    public func save(
        _ data: Data,
        for url: URL,
        completion: @escaping (SaveResult) -> Void
    ) {
        store.insert(data, for: url) { [weak self] result in
            guard self != nil else { return }
            completion(result.mapError { _ in SaveError.failed })
        }
    }
}

extension LocalImageDataLoader: ImageDataLoader {
    public typealias LoadResult = ImageDataLoader.Result

    public enum LoadError: Error {
        case failed
        case notFound
    }

    private final class LoadImageDataTask: ImageDataLoaderTask {
        private var completion: ((ImageDataLoader.Result) -> Void)?

        init(_ completion: @escaping (ImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: ImageDataLoader.Result) {
            completion?(result)
        }

        func cancel() {
            preventFurtherCompletions()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }
    }

    public func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> ImageDataLoaderTask {
        let task = LoadImageDataTask(completion)
        store.retrieve(dataForURL: url) { [weak self] result in
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
