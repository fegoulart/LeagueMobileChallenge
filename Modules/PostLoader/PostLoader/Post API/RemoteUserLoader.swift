//
//  RemoteUserLoader.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 14/08/22.
//

import Foundation

// public final class RemoteUserLoader: UserLoader {
//    private let url: URL
//    private let client: HTTPClient
//
//    public enum Error: Swift.Error {
//        case connectivity
//        case invalidData
//    }
//
//    public typealias Result = UserLoader.Result
//
//    public init(url: URL, client: HTTPClient) {
//        self.url = url
//        self.client = client
//    }
//
//    public func load(userId: Int, completion: @escaping (Result) -> Void) {
//        let urlRequest = URLRequest
//        client.get(from: url) { [weak self] result in
//            guard self != nil else { return }
//
//            switch result {
//            case let .success((data, response)):
//                completion(RemoteFeedLoader.map(data, from: response))
//
//            case .failure:
//                completion(.failure(Error.connectivity))
//            }
//        }
//    }
// }
