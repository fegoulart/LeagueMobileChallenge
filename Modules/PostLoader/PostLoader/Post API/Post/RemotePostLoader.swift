//
//  RemotePostLoader.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 14/08/22.
//

import Foundation

public final class RemotePostLoader: PostLoader {
    private let url: URL
    private let client: HTTPClient
    public let tokenProvider: () throws -> (String)

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
        case notAuthorized
        case invalidUrl
    }

    public typealias Result = PostLoader.Result

    public init(url: URL, client: HTTPClient, tokenProvider: @escaping () throws -> String ) {
        self.url = url
        self.client = client
        self.tokenProvider = tokenProvider
    }

    public func load(completion: @escaping (Result) -> Void) {

        guard let header: [String: String] = try? tokenProvider().authHeader else {
            completion(.failure(RemotePostLoader.Error.notAuthorized))
            return
        }
        guard let urlRequest = try? url.toURLRequest(headers: header) else {
            completion(.failure(RemotePostLoader.Error.invalidUrl))
            return
        }
        _ = client.get(from: urlRequest) { [weak self] result in
            guard self != nil else { return }

            switch result {
            case let .success((data, response)):
                completion(RemotePostLoader.map(data, from: response))

            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }

    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let remotePosts: [RemotePost] = try PostMapper.map(data, from: response)
            return .success(remotePosts.toModels())
        } catch {
            guard let errorMessage = try? RemoteBackendMapper.errorMessage.map(
                data,
                response,
                RemotePostLoader.Error.invalidData
            ),
                  errorMessage.lowercased() == "authorization failed: api key invalid" else {
                return .failure(error)
            }
            return .failure(RemotePostLoader.Error.notAuthorized)
        }
    }
}

private extension Array where Element == RemotePost {
    func toModels() -> [Post] {
        return map { Post(id: $0.id, userId: $0.userId, userImageUrl: nil, title: $0.title, body: $0.body) }
    }
}
