//
//  ValidateUserCacheUseCaseTests.swift
//  PostLoaderTests
//
//  Created by Fernando Luiz Goulart on 13/08/22.
//

import XCTest
import PostLoader

class ValidateUserCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()

        sut.validateCache { _ in }
        store.completeRetrievalAll(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.retrieveAll, .cleanCache])
    }

    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.validateCache { _ in }
        store.completeRetrievalAllWithEmptyCache()

        XCTAssertEqual(store.receivedMessages, [.retrieveAll])
    }

    func test_validateCache_doesNotDeleteNonExpiredCache() {
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusUserCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.validateCache { _ in }
        store.completeRetrievalAll(with: [uniqueLocalUser()], timestamp: nonExpiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieveAll])
    }

    func test_validateCache_deletesCacheOnExpiration() {
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusUserCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        var cachedUser = uniqueLocalUser()
        cachedUser.cacheInsertionDate = expirationTimestamp

        sut.validateCache { _ in }
        store.completeRetrievalAll(with: [uniqueLocalUser()], timestamp: expirationTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieveAll, .deleteCachedUser([cachedUser])])
    }

    func test_validateCache_deletesExpiredCache() {
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusUserCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        var cachedUser = uniqueLocalUser()
        cachedUser.cacheInsertionDate = expiredTimestamp

        sut.validateCache { _ in }
        store.completeRetrievalAll(with: [uniqueLocalUser()], timestamp: expiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieveAll, .deleteCachedUser([cachedUser])])
    }

    func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()

        expect(sut, toCompleteWith: .failure(deletionError), when: {
            store.completeRetrievalAll(with: anyNSError())
            store.completeCleanCache(with: deletionError)
        })
    }

    func test_validateCache_succeedsOnSuccessfulDeletionOfFailedRetrieval() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrievalAll(with: anyNSError())
            store.completeCleanCacheSuccessfully()
        })
    }

    func test_validateCache_succeedsOnEmptyCache() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrievalAllWithEmptyCache()
        })
    }

    func test_validateCache_succeedsOnNonExpiredCache() {
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusUserCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrievalAll(with: [uniqueLocalUser()], timestamp: nonExpiredTimestamp)
        })
    }

    func test_validateCache_failsOnDeletionErrorOfExpiredCache() {
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusUserCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        let deletionError = anyNSError()
        var cachedUser = uniqueLocalUser()
        cachedUser.cacheInsertionDate = expiredTimestamp

        expect(sut, toCompleteWith: .failure(deletionError), when: {
            store.completeRetrievalAll(with: [cachedUser], timestamp: expiredTimestamp)
            store.completeDeletion(with: deletionError)
        })
    }

    func test_validateCache_succeedsOnSuccessfulDeletionOfExpiredCache() {
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusUserCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })
        var cachedUser = uniqueLocalUser()
        cachedUser.cacheInsertionDate = expiredTimestamp

        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrievalAll(with: [cachedUser], timestamp: expiredTimestamp)
            store.completeDeletionSuccessfully()
        })
    }

    func test_validateCache_doesNotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = UserStoreSpy()
        var sut: LocalUserLoader? = LocalUserLoader(store: store, currentDate: Date.init)

        sut?.validateCache { _ in }

        sut = nil
        store.completeRetrievalAll(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.retrieveAll])
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
        toCompleteWith expectedResult: LocalUserLoader.ValidationResult,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")

        sut.validateCache { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break

            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
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
