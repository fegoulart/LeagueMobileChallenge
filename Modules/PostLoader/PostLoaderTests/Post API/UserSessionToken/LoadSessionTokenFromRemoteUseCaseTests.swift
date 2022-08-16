//
//  LoadUserSessionTokenFromRemoteUseCaseTests.swift
//  PostLoaderTests
//
//  Created by Fernando Luiz Goulart on 14/08/22.
//

import XCTest
import PostLoader

class LoadUserTokenFromRemoteUseCaseTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let urlRequest = URLRequest(url: url)
        let (sut, client) = makeSUT(url: url)

        _ = sut.load()

        XCTAssertEqual(client.requestedURLs, [urlRequest])
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let urlRequest = URLRequest(url: url)
        let (sut, client) = makeSUT(url: url)

        _ = sut.load()
        _ = sut.load()

        XCTAssertEqual(client.requestedURLs, [urlRequest, urlRequest])
    }

    func test_load_deliversErrorOnClientError() {
        let clientError = NSError(domain: "Test", code: 0)

        let client = SyncHTTPSpy(forcedResult: .failure(clientError))
        let sut = RemoteUserSessionTokenLoader(url: anyURL(), client: client)
        let result = sut.load()

        XCTAssertEqual(result, failure(.invalidData))
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {

        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { _, code in
            let httpResponse: HTTPURLResponse = HTTPURLResponse(statusCode: code)
            let data = anyTokenData()
            let forcedResult: HTTPClient.Result = .success((data, httpResponse))
            let client = SyncHTTPSpy(forcedResult: forcedResult)
            let sut = RemoteUserSessionTokenLoader(url: anyURL(), client: client)
            let result = sut.load()
            XCTAssertEqual(result, nil)
        }
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let httpResponse: HTTPURLResponse = HTTPURLResponse(statusCode: 200)
        let data = Data("invalid json".utf8)
        let forcedResult: HTTPClient.Result = .success((data, httpResponse))
        let client = SyncHTTPSpy(forcedResult: forcedResult)
        let sut = RemoteUserSessionTokenLoader(url: anyURL(), client: client)
        let result = sut.load()
        XCTAssertEqual(result, nil)
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSON() {
        let httpResponse: HTTPURLResponse = HTTPURLResponse(statusCode: 200)
        let data = makeItemJSON(token: nil)
        let forcedResult: HTTPClient.Result = .success((data, httpResponse))
        let client = SyncHTTPSpy(forcedResult: forcedResult)
        let sut = RemoteUserSessionTokenLoader(url: anyURL(), client: client)
        let result = sut.load()
        XCTAssertEqual(result, nil)
    }

    func test_load_deliversItemOn200HTTPResponseWithJSONItem() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: "1234", when: {
            let json = makeItemJSON(token: "1234")
            client.complete(withStatusCode: 200, data: json)
        })
    }

    // MARK: - Helpers

    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: RemoteUserSessionTokenLoader,
        client: HTTPClientSpy
    ) {
        let client = HTTPClientSpy()
        let sut = RemoteUserSessionTokenLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }

    private func failure(_ error: RemoteUserSessionTokenLoader.Error) -> String? {
        return nil
    }

    private func makeItem(token: String?) -> (model: String?, json: [String: Any]) {
        let item = token

        let json = [
            "api_key": token
        ]

        return (item, json as [String: Any])
    }

    private func makeItemJSON(token: String?) -> Data {
        let json = ["api_key": token]
        // swiftlint:disable:next force_try
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func expect(
        _ sut: RemoteUserSessionTokenLoader,
        toCompleteWith expectedResult: String?,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {

        let receivedResult = sut.load()
        action()

        XCTAssertEqual(receivedResult, expectedResult, file: file, line: line)
    }

}

class SyncHTTPSpy: HTTPClient {
    typealias Result = HTTPClient.Result
    let forcedResult: Result

    init(forcedResult: Result) {
        self.forcedResult = forcedResult
    }

    func get(from request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask {
        fatalError("not implemented")
    }

    func get(from request: URLRequest) -> Result {
        return forcedResult
    }
}
