//
//  LoadPostsFromRemoteUseCaseTests.swift
//  PostLoaderTests
//
//  Created by Fernando Luiz Goulart on 14/08/22.
//

import XCTest
import PostLoader

class LoadPostsFromRemoteUseCaseTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        // swiftlint:disable:next force_try
        let urlRequest = try! url.toURLRequest(headers: ["x-access-token": "1234"])
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [urlRequest])
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        // swiftlint:disable:next force_try
        let urlRequest = try! url.toURLRequest(headers: ["x-access-token": "1234"])
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [urlRequest, urlRequest])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(RemotePostLoader.Error.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(RemotePostLoader.Error.invalidData), when: {
                let item = makeItem()
                let json = makeItemJSON([item.json])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(RemotePostLoader.Error.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJson = makeItemJSON([])
            client.complete(withStatusCode: 200, data: emptyListJson)
        })
    }

    func test_load_deliversItemOn200HTTPResponseWithJSONItem() {
        let (sut, client) = makeSUT()

        expect(
            sut,
            toCompleteWith: .success(
                [makeItem().model, makeItem().model]
            ),
            when: {
                let json = makeItemJSON([makeItem().json, makeItem().json])
                client.complete(withStatusCode: 200, data: json)
            })
    }

    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "http://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemotePostLoader? = RemotePostLoader(url: url, client: client, tokenProvider: { return "1234" })

        var capturedResults = [RemotePostLoader.Result]()
        sut?.load { capturedResults.append($0) }

        sut = nil
        client.complete(withStatusCode: 200, data: makeItemJSON([makeItem().json]))

        XCTAssertTrue(capturedResults.isEmpty)
    }

    func test_load_failsWhenTokenProviderThrows() {
        let url = URL(string: "http://any-url.com")!
        let (sut, _) = makeSUT(url: url, tokenProvider: {
            throw RemotePostLoader.Error.notAuthorized
        })

        var receivedError: Error?
        let expectedError: Error? = RemotePostLoader.Error.notAuthorized
        sut.load { result in
            if case let Result.failure(error) = result {
                receivedError = error
                XCTAssertEqual(receivedError?.localizedDescription, expectedError?.localizedDescription)
            } else {
                XCTFail("Should fail")
            }
        }
    }

    func test_load_failsWhenInvalidToken() {
        let url = URL(string: "http://any-url.com")!
        let (sut, client) = makeSUT(url: url)
        expect(sut, toCompleteWith: .failure(RemotePostLoader.Error.notAuthorized), when: {
            client.complete(
                withStatusCode: 200,
                // swiftlint:disable:next force_try
                data: try! JSONSerialization.data(withJSONObject: ["message": "Authorization Failed: API Key invalid"]))
        })
    }

    // MARK: - Helpers

    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        tokenProvider: @escaping () throws -> (String) = { return "1234" },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: RemotePostLoader,
        client: HTTPClientSpy
    ) {
        let client = HTTPClientSpy()
        let sut = RemotePostLoader(url: url, client: client, tokenProvider: tokenProvider)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }

    private func failure(_ error: RemotePostLoader.Error) -> RemotePostLoader.Result {
        return .failure(error)
    }

    private func makeItem(
        userId: Int? = 9,
        id: Int = 84,
        title: String? = "optio ipsam molestias necessitatibus occaecati facilis veritatis dolores aut",
        body: String? = """
        ullam et saepe reiciendis voluptatem adipisci\nsit amet autem assumenda provident rerum culpa
\nquis hic commodi nesciunt rem tenetur doloremque ipsam iure\nquis sunt voluptatem rerum illo velit
"""
    ) -> (model: Post, json: [String: Any]) {
        let item = Post(id: id, userId: userId, userImageUrl: nil, title: title, body: body)

        let json = [
            "userId": userId as Any,
            "id": id,
            "title": title as Any,
            "body": body as Any
        ].compactMapValues { $0 }

        return (item, json)
    }

    private func makeItemJSON(_ json: [[String: Any]]) -> Data {
        // swiftlint:disable:next force_try
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func expect(
        _ sut: RemotePostLoader,
        toCompleteWith expectedResult: RemotePostLoader.Result,
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
                .failure(receivedError as RemotePostLoader.Error),
                .failure(expectedError as RemotePostLoader.Error)
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
