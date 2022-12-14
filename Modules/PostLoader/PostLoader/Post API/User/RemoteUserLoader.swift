//
//  RemoteUserLoader.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 14/08/22.
//

import Foundation

public final class RemoteUserLoader: UserLoader {
    private let url: URL
    private let client: HTTPClient
    public let tokenProvider: () throws -> (String)

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case notAuthorized
        case invalidUrl
    }

    public typealias Result = UserLoader.Result

    public init(url: URL, client: HTTPClient, tokenProvider: @escaping () throws -> String ) {
        self.url = url
        self.client = client
        self.tokenProvider = tokenProvider
    }

    private final class HTTPClientTaskWrapper: UserLoaderTask {
        private var completion: ((UserLoader.Result) -> Void)?

        var wrapped: HTTPClientTask?

        init(_ completion: @escaping (UserLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: UserLoader.Result) {
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

    @discardableResult
    public func load(userId: Int, completion: @escaping (Result) -> Void) -> UserLoaderTask? {

        guard let header: [String: String] = try? tokenProvider().authHeader else {
            completion(.failure(RemoteUserLoader.Error.notAuthorized))
            return nil
        }
        guard let urlRequest = try? url.toURLRequest(headers: header) else {
            completion(.failure(RemoteUserLoader.Error.invalidUrl))
            return nil
        }

        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: urlRequest) { [weak self] result in
            guard self != nil else { return }

            switch result {
            case let .success((data, response)):
                completion(RemoteUserLoader.map(data, userId: userId, from: response))

            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
        return task
    }

    private static func map(_ data: Data, userId: Int, from response: HTTPURLResponse) -> Result {
        do {
            let remoteUsers = try UserMapper.map(data, from: response)
            if let remoteUser: RemoteUser = remoteUsers.first(where: { $0.id == userId }) {
                return .success(remoteUser.toModel())
            }
            return .success(nil)
        } catch {
            guard let errorMessage = try? RemoteBackendMapper.errorMessage.map(
                data,
                response,
                RemoteUserLoader.Error.invalidData
            ),
                  errorMessage.lowercased() == "authorization failed: api key invalid" else {
                return .failure(error)
            }
            return .failure(RemoteUserLoader.Error.notAuthorized)
        }
    }
}

private extension RemoteUser {
    func toModel() -> User {
        let imageUrl: URL? = (self.avatar != nil) ? URL(string: self.avatar!) : nil
        return User(id: self.id, name: self.name, imageUrl: imageUrl)
    }
}
