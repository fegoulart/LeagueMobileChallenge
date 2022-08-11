//
//  URLSessionHTTPClientTests.swift
//  PostLoaderTests
//
//  Created by Fernando Luiz Goulart on 11/08/22.
//

import XCTest

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

    func get(
        from url: URL,
        parameters: [String: String],
        headers: [String: String],
        completion: @escaping (Result) -> Void
    )
}

public class URLSessionHTTPClient: HTTPClient {

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    private struct UnexpectedValuesRepresentation: Error {}
    public struct CouldNotInitializeURLRequest: Error {}

    public func get(
        from url: URL,
        parameters: [String: String] = [:],
        headers: [String: String] = [:],
        completion: @escaping (HTTPClient.Result) -> Void
    ) {

        guard
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            completion(.failure(CouldNotInitializeURLRequest()))
            return
        }
        if !parameters.isEmpty {
            components.queryItems = parameters.map { (key, value) in
                URLQueryItem(name: key, value: value)
            }
            let percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            components.percentEncodedQuery = percentEncodedQuery
        }

        guard let componentsURL = components.url else {
            completion(.failure(CouldNotInitializeURLRequest()))
            return
        }

        var request = URLRequest(url: componentsURL)

        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }

        session.dataTask(with: request) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    override func tearDown() {
        super.tearDown()

        URLProtocolStub.removeStub()
    }

    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }

        makeSUT().get(from: url) { _ in }

        wait(for: [exp], timeout: 1.0)
    }

    func test_getWithParametersAndHeader_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        let parameters = ["user": "1"]
        let headers = ["x-access-token": "872C86119EBD18178526C0A687DFE495"]
        let stringUrl: String? = "\(anyURL())?user=1"

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.allHTTPHeaderFields, headers)
            XCTAssertEqual(request.url?.absoluteString, stringUrl)
            exp.fulfill()
        }

        makeSUT().get(from: url, parameters: parameters, headers: headers) { _ in }

        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)

        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

}
