//
//  LoadUserImageDataFromRemoteUseCaseTests.swift
//  PostLoaderTests
//
//  Created by Fernando Luiz Goulart on 12/08/22.
//

import XCTest
import PostLoader

class LoadFeedImageDataFromRemoteUseCaseTests: XCTestCase {
    func test_init_doesNotPerformAnyURLRequest() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_loadUserImageDataFromURL_requestsDataFromURL() {
        // swiftlint:disable:next force_try
        let urlRequest = try! "https://a-given-url.com".toURLRequest()
        let (sut, client) = makeSUT(urlRequest: urlRequest)

        _ = sut.loadUserImageData(from: urlRequest) { _ in }

        XCTAssertEqual(client.requestedURLs, [urlRequest])
    }

    func test_loadUserImageDataFromURLTwice_requestsDataFromURLTwice() {
        // swiftlint:disable:next force_try
        let urlRequest = try! "https://a-given-url.com".toURLRequest()
        let (sut, client) = makeSUT(urlRequest: urlRequest)

        _ = sut.loadUserImageData(from: urlRequest) { _ in }
        _ = sut.loadUserImageData(from: urlRequest) { _ in }

        XCTAssertEqual(client.requestedURLs, [urlRequest, urlRequest])
    }

    func test_loadUserImageDataFromURL_deliversConnectivityErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = NSError(domain: "a client error", code: 0)

        expect(sut, toCompleteWith: failure(.connectivity), when: {
            client.complete(with: clientError)
        })
    }

    func test_loadUserImageDataFromURL_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199, 201, 300, 400, 500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: anyData(), at: index)
            })
        }
    }

    func test_loadUserImageDataFromURL_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.invalidData), when: {
            let emptyData = Data()
            client.complete(withStatusCode: 200, data: emptyData)
        })
    }

    func test_loadUserImageDataFromURL_deliversReceivedNonEmptyDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)

        expect(sut, toCompleteWith: .success(nonEmptyData), when: {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        })
    }

    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
        let (sut, client) = makeSUT()
        // swiftlint:disable:next force_try
        let urlRequest = try! "https://a-given-url.com".toURLRequest()

        let task = sut.loadUserImageData(from: urlRequest) { _ in }
        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")

        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [urlRequest], "Expected cancelled URL request after task is cancelled")
    }

    func test_loadUserImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)
        // swiftlint:disable:next force_try
        let urlRequest = try! "https://a-given-url.com".toURLRequest()

        var received = [UserImageDataLoader.Result]()
        let task = sut.loadUserImageData(from: urlRequest) { received.append($0) }
        task.cancel()

        client.complete(withStatusCode: 404, data: anyData())
        client.complete(withStatusCode: 200, data: nonEmptyData)
        client.complete(with: anyNSError())

        XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
    }

    func test_loadUserImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        var sut: RemoteUserImageDataLoader? = RemoteUserImageDataLoader(client: client)
        // swiftlint:disable:next force_try
        let urlRequest = try! "https://a-given-url.com".toURLRequest()

        var capturedResults = [UserImageDataLoader.Result]()
        _ = sut?.loadUserImageData(from: urlRequest) { capturedResults.append($0) }

        sut = nil
        client.complete(withStatusCode: 200, data: anyData())

        XCTAssertTrue(capturedResults.isEmpty)
    }

    private func makeSUT(
        urlRequest: URLRequest = URLRequest(url: anyURL()),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (
        sut: RemoteUserImageDataLoader,
        client: HTTPClientSpy
    ) {
        let client = HTTPClientSpy()
        let sut = RemoteUserImageDataLoader(client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }

    private func failure(_ error: RemoteUserImageDataLoader.Error) -> UserImageDataLoader.Result {
        return .failure(error)
    }

    private func expect(
        _ sut: RemoteUserImageDataLoader,
        toCompleteWith expectedResult: RemoteUserImageDataLoader.Result,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        // swiftlint:disable:next force_try
        let urlRequest = try! "https://a-given-url.com".toURLRequest()
        let exp = expectation(description: "Wait for load completion")

        _ = sut.loadUserImageData(from: urlRequest) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)

            case let (
                .failure(receivedError as RemoteUserImageDataLoader.Error),
                .failure(expectedError as RemoteUserImageDataLoader.Error)
            ):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
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
