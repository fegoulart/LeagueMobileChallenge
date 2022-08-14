//
//  LoadUserFromRemoteUseCaseTests.swift
//  PostLoaderTests
//
//  Created by Fernando Luiz Goulart on 14/08/22.
//

import XCTest
import PostLoader

class LoadUserFromRemoteUseCaseTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        // swiftlint:disable:next force_try
        let urlRequest = try! url.toURLRequest(headers: ["x-access-token": "1234"])
        let (sut, client) = makeSUT(url: url)

        sut.load(userId: 1) { _ in }

        XCTAssertEqual(client.requestedURLs, [urlRequest])
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        // swiftlint:disable:next force_try
        let urlRequest = try! url.toURLRequest(headers: ["x-access-token": "1234"])
        let (sut, client) = makeSUT(url: url)

        sut.load(userId: 1) { _ in }
        sut.load(userId: 1) { _ in }

        XCTAssertEqual(client.requestedURLs, [urlRequest, urlRequest])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(RemoteUserLoader.Error.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(RemoteUserLoader.Error.invalidData), when: {
                let item = makeItem(userId: 1)
                let json = makeItemJSON([item.json])
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(RemoteUserLoader.Error.invalidData), when: {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }

    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .success(nil), when: {
            let emptyListJson = makeItemJSON([])
            client.complete(withStatusCode: 200, data: emptyListJson)
        })
    }

    func test_load_deliversItemOn200HTTPResponseWithJSONItem() {
        let (sut, client) = makeSUT()

        expect(
            sut,
            toCompleteWith: .success(
                User(
                    id: 1,
                    name: "Leanne Graham",
                    imageUrl: URL(
                        string: "https://i.pravatar.cc/150?u=Sincere@april.biz"
                    )
                )
            ),
            when: {
                let json = makeItemJSON([makeItem(userId: 1).json])
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
        client.complete(withStatusCode: 200, data: makeItemJSON([makeItem(userId: 1).json]))

        XCTAssertTrue(capturedResults.isEmpty)
    }

    func test_load_failsWhenTokenProviderThrows() {
        let url = URL(string: "http://any-url.com")!
        let (sut, _) = makeSUT(url: url, tokenProvider: {
            throw RemoteUserLoader.Error.notAuthorized
        })

        var receivedError: Error?
        let expectedError: Error? = RemoteUserLoader.Error.notAuthorized
        sut.load(userId: 1) { result in
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
        expect(sut, userId: 1, toCompleteWith: .failure(RemoteUserLoader.Error.notAuthorized), when: {
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
        sut: RemoteUserLoader,
        client: HTTPClientSpy
    ) {
        let client = HTTPClientSpy()
        let sut = RemoteUserLoader(url: url, client: client, tokenProvider: tokenProvider)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }

    private func failure(_ error: RemoteUserLoader.Error) -> RemoteUserLoader.Result {
        return .failure(error)
    }

    private func makeItem(
        userId: Int,
        avatar: String? = "https://i.pravatar.cc/150?u=Sincere@april.biz",
        name: String? = "Leanne Graham"
    ) -> (model: RemoteUser, json: [String: Any]) {
        let item = RemoteUser(id: userId, avatar: avatar, name: name)

        let json = [
            "id": userId,
            "avatar": avatar as Any,
            "name": name as Any
        ].compactMapValues { $0 }

        return (item, json)
    }

    private func makeItemJSON(_ json: [[String: Any]]) -> Data {
        // swiftlint:disable:next force_try
        return try! JSONSerialization.data(withJSONObject: json)
    }

    private func expect(
        _ sut: RemoteUserLoader,
        userId: Int = 1,
        toCompleteWith expectedResult: RemoteUserLoader.Result,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")

        sut.load(userId: userId) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)

            case let (
                .failure(receivedError as RemoteUserLoader.Error),
                .failure(expectedError as RemoteUserLoader.Error)
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
