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
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(RemoteUserSessionTokenLoader.Error.invalidData), when: {
                let json = makeItemJSON(token: "1234")
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }

        func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
            let (sut, client) = makeSUT()

            expect(sut, toCompleteWith: failure(RemoteUserSessionTokenLoader.Error.invalidData), when: {
                let invalidJSON = Data("invalid json".utf8)
                client.complete(withStatusCode: 200, data: invalidJSON)
            })
        }

        func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSON() {
            let (sut, client) = makeSUT()

            expect(sut, toCompleteWith: failure(RemoteUserSessionTokenLoader.Error.invalidData), when: {
                let emptyListJson = makeItemJSON(token: nil)
                client.complete(withStatusCode: 200, data: emptyListJson)
            })
        }

        func test_load_deliversItemOn200HTTPResponseWithJSONItem() {
            let (sut, client) = makeSUT()

            expect(sut, toCompleteWith: "1234", when: {
                let json = makeItemJSON(token: "1234")
                client.complete(withStatusCode: 200, data: json)
            })
        }

        func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
            let url = URL(string: "http://any-url.com")!
            let client = HTTPClientSpy()
            var sut: RemoteUserSessionTokenLoader? = RemoteUserSessionTokenLoader(url: url, client: client)

            var capturedResults = [String?]()
            let result = sut?.load()
            capturedResults.append(result)

            sut = nil
            client.complete(withStatusCode: 200, data: makeItemJSON(token: "1234"))

            XCTAssertTrue(capturedResults.isEmpty)
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
