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

        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [urlRequest])
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let urlRequest = URLRequest(url: url)
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [urlRequest, urlRequest])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemJSON(token: "1234")
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }

        func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
            let (sut, client) = makeSUT()

            expect(sut, toCompleteWith: failure(.invalidData), when: {
                let invalidJSON = Data("invalid json".utf8)
                client.complete(withStatusCode: 200, data: invalidJSON)
            })
        }

        func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSON() {
            let (sut, client) = makeSUT()

            expect(sut, toCompleteWith: .failure(RemoteUserSessionTokenLoader.Error.invalidData), when: {
                let emptyListJson = makeItemJSON(token: nil)
                client.complete(withStatusCode: 200, data: emptyListJson)
            })
        }

        func test_load_deliversItemOn200HTTPResponseWithJSONItem() {
            let (sut, client) = makeSUT()

            expect(sut, toCompleteWith: .success("1234"), when: {
                let json = makeItemJSON(token: "1234")
                client.complete(withStatusCode: 200, data: json)
            })
        }

        func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
            let url = URL(string: "http://any-url.com")!
            let client = HTTPClientSpy()
            var sut: RemoteUserSessionTokenLoader? = RemoteUserSessionTokenLoader(url: url, client: client)

            var capturedResults = [RemoteUserSessionTokenLoader.Result]()
            sut?.load { capturedResults.append($0) }

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

    private func failure(_ error: RemoteUserSessionTokenLoader.Error) -> RemoteUserSessionTokenLoader.Result {
        return .failure(error)
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
        toCompleteWith expectedResult: RemoteUserSessionTokenLoader.Result,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)

            case let (
                .failure(receivedError as RemoteUserSessionTokenLoader.Error),
                .failure(expectedError as RemoteUserSessionTokenLoader.Error)
            ):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }

}
