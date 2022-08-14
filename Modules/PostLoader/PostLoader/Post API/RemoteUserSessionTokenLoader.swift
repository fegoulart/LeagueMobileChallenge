//
//  RemoteUserSessionTokenLoader.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 14/08/22.
//

import Foundation

public final class RemoteUserSessionTokenLoader: UserSessionTokenLoader {

    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public typealias Result = UserSessionTokenLoader.Result

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public init(url: URL, client: HTTPClient, username: String, password: String) {
        fatalError("Not implemented")
    }

    public func load(completion: @escaping (Result) -> Void) {
        let urlRequest = URLRequest(url: self.url)

        _ = client.get(
            from: urlRequest
        ) { [weak self] result in
            guard self != nil else { return }

            switch result {
            case let .success((data, response)):
                completion(RemoteUserSessionTokenLoader.map(data, from: response))
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }

    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let remoteToken = try UserSessionTokenMapper.map(data, from: response)
            guard let token = remoteToken.value else {
                return .failure(Error.invalidData)
            }
            return .success(token)
        } catch {
            return .failure(error)
        }
    }
}

private extension RemoteUserSessionToken {
    func toModel() -> String? {
        return self.value
    }
}
