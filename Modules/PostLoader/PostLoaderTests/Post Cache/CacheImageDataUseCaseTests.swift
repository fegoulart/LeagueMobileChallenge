//
//  CacheImageDataUseCaseTests.swift
//  PostLoaderTests
//
//  Created by Fernando Luiz Goulart on 12/08/22.
//

import XCTest
import PostLoader

class CacheImageDataUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertTrue(store.receivedMessages.isEmpty)
    }

    func test_saveImageDataForURL_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let data = anyData()
        let userId = 1

        sut.save(data, userId: userId, url: url) { _ in }

        XCTAssertEqual(store.receivedMessages, [.insert(data: data, for: url)])
    }

    func test_saveImageDataFromURL_failsOnStoreInsertionError() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: failed(), when: {
            let insertionError = anyNSError()
            store.completeInsertion(with: insertionError)
        })
    }

    func test_saveImageDataFromURL_succeedsOnSuccessfulStoreInsertion() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success(()), when: {
            store.completeInsertionSuccessfully()
        })
    }

    func test_saveImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = UserImageDataStoreSpy()
        var sut: LocalUserImageDataLoader? = LocalUserImageDataLoader(store: store)
        let userId = 1

        var received = [LocalUserImageDataLoader.SaveResult]()
        sut?.save(anyData(), userId: userId, url: anyURL()) { received.append($0) }

        sut = nil
        store.completeInsertionSuccessfully()

        XCTAssertTrue(received.isEmpty, "Expected no received results after instance has been deallocated")
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: LocalUserImageDataLoader, store: UserImageDataStoreSpy) {
        let store = UserImageDataStoreSpy()
        let sut = LocalUserImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func failed() -> LocalUserImageDataLoader.SaveResult {
        return .failure(LocalUserImageDataLoader.SaveError.failed)
    }

    private func expect(
        _ sut: LocalUserImageDataLoader,
        toCompleteWith expectedResult: LocalUserImageDataLoader.SaveResult,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for save completion")
        let userId = 1

        sut.save(anyData(), userId: userId, url: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break

            case (.failure(let receivedError as LocalUserImageDataLoader.SaveError),
                  .failure(let expectedError as LocalUserImageDataLoader.SaveError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)
    }
}
