//
//  CacheUserUseCaseTests.swift
//  PostLoaderTests
//
//  Created by Fernando Luiz Goulart on 13/08/22.
//

import XCTest
import PostLoader

class CacheUserUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()

        sut.save(uniqueUser()) { _ in }

        XCTAssertEqual(store.receivedMessages, [.deleteCachedUser([uniqueLocalUser()])])
    }

    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()

        sut.save(uniqueUser()) { _ in }
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.receivedMessages, [.deleteCachedUser([uniqueLocalUser()])])
    }

    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let user = uniqueUser()
        let (sut, store) = makeSUT(currentDate: { timestamp })

        sut.save(user) { _ in }
        store.completeDeletionSuccessfully()

        XCTAssertEqual(
            store.receivedMessages,
            [.deleteCachedUser([uniqueLocalUser()]), .insert(uniqueLocalUser(), timestamp)]
        )
    }

    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()

        expect(sut, toCompleteWithError: deletionError, when: {
            store.completeDeletion(with: deletionError)
        })
    }

    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()

        expect(sut, toCompleteWithError: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }

    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }

    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = UserStoreSpy()
        var sut: LocalUserLoader? = LocalUserLoader(store: store, currentDate: Date.init)

        var receivedResults = [LocalUserLoader.SaveResult]()
        sut?.save(uniqueUser()) { receivedResults.append($0) }

        sut = nil
        store.completeDeletion(with: anyNSError())

        XCTAssertTrue(receivedResults.isEmpty)
    }

    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = UserStoreSpy()
        var sut: LocalUserLoader? = LocalUserLoader(store: store, currentDate: Date.init)

        var receivedResults = [LocalUserLoader.SaveResult]()
        sut?.save(uniqueUser()) { receivedResults.append($0) }

        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with: anyNSError())

        XCTAssertTrue(receivedResults.isEmpty)
    }

    // MARK: - Helpers

    private func makeSUT(
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: LocalUserLoader, store: UserStoreSpy) {
        let store = UserStoreSpy()
        let sut = LocalUserLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }

    private func expect(
        _ sut: LocalUserLoader,
        toCompleteWithError expectedError: NSError?,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for save completion")

        var receivedError: Error?
        sut.save(uniqueUser()) { result in
            if case let Result.failure(error) = result { receivedError = error }
            exp.fulfill()
        }

        action()
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
}
