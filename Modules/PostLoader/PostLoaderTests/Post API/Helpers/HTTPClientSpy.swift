//
//  HTTPClientSpy.swift
//  PostLoaderTests
//
//  Created by Fernando Luiz Goulart on 12/08/22.
//

import Foundation
import PostLoader

class HTTPClientSpy: HTTPClient {

    private struct Task: HTTPClientTask {
        let callback: () -> Void
        func cancel() { callback() }
    }

    private var messages = [(urlRequest: URLRequest, completion: (HTTPClient.Result) -> Void)]()
    private(set) var cancelledURLs = [URLRequest]()

    var requestedURLs: [URLRequest] {
        return messages.map { $0.urlRequest }
    }

    func get(from request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        messages.append((request, completion))
        return Task { [weak self] in
            self?.cancelledURLs.append(request)
        }
    }

    func get(from request: URLRequest) -> HTTPClient.Result {
        let completion: (HTTPClient.Result) -> Void = { _ in }
        messages.append((request, completion))
        return .success((anyData(), .init(statusCode: 200)))
    }

    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }

    func complete(withStatusCode code: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index].url!,
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
        messages[index].completion(.success((data, response)))
    }
}
