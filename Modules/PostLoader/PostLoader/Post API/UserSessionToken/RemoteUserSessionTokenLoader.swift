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

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public init(url: URL, client: HTTPClient, username: String, password: String) {
        fatalError("Not implemented")
    }

    public func load() -> String? {

        let urlRequest = URLRequest(url: self.url)
        let result = client.get(from: urlRequest)
        switch result {
        case .success(let (data, response)):
            guard let token = try? RemoteUserSessionTokenLoader.map(data, from: response) else {
                return nil
            }
            return token
        case .failure:
            return nil
        }
    }

    private static func map(_ data: Data, from response: HTTPURLResponse) throws -> String {
        let remoteToken = try UserSessionTokenMapper.map(data, from: response)
        guard let token = remoteToken.value else {
            throw Error.invalidData
        }
        return token
    }
}

private extension RemoteUserSessionToken {
    func toModel() -> String? {
        return self.value
    }
}
