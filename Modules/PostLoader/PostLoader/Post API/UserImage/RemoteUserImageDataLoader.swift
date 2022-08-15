//
//  RemoteUserImageDataLoader.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 12/08/22.
//

import Foundation

public final class RemoteUserImageDataLoader: UserImageDataLoader {

    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    private final class HTTPClientTaskWrapper: UserImageDataLoaderTask {
        private var completion: ((UserImageDataLoader.Result) -> Void)?

        var wrapped: HTTPClientTask?

        init(_ completion: @escaping (UserImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: UserImageDataLoader.Result) {
            completion?(result)
        }

        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }
    }

    public func loadUserImageData(
        url: URL,
        userId: Int,
        completion: @escaping (UserImageDataLoader.Result) -> Void
    ) -> UserImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        let urlRequest = URLRequest(url: url)
        task.wrapped = client.get(from: urlRequest) { [weak self] result in
            guard self != nil else { return }

            task.complete(with: result
                .mapError { _ in Error.connectivity }
                .flatMap { (data, response) in
                    let isValidResponse = response.isOk && !data.isEmpty
                    return isValidResponse ? .success(data) : .failure(Error.invalidData)
                }
            )
        }
        return task
    }
}
