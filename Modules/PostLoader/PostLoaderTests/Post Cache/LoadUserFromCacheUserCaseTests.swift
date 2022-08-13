//
//  LoadUserFromCacheUserCaseTests.swift
//  PostLoaderTests
//
//  Created by Fernando Luiz Goulart on 13/08/22.
//

import XCTest
import PostLoader

class LoadUserFromCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()

        sut.load(userId: 1) { _ in }

        XCTAssertEqual(store.receivedMessages, [.retrieve(1)])
    }

    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()

        expect(sut, toCompleteWith: .failure(retrievalError), when: {
            store.completeRetrieval(with: retrievalError)
        })
    }

    func test_load_deliversNoUserOnEmptyCache() {
        let (sut, store) = makeSUT()

        expect(sut, toCompleteWith: .success(nil), when: {
            store.completeRetrievalWithEmptyCache()
        })
    }

    func test_load_deliversCachedUserOnNonExpiredCache() {
        let user = uniqueUser()
        let localUser = uniqueLocalUser()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusUserCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success(user), when: {
            store.completeRetrieval(with: localUser, timestamp: nonExpiredTimestamp)
        })
    }

    func test_load_deliversNoUserOnCacheExpiration() {
        let localUser = uniqueLocalUser()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusUserCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success(nil), when: {
            store.completeRetrieval(with: localUser, timestamp: expirationTimestamp)
        })
    }

    func test_load_deliversNoUserOnExpiredCache() {
        let localUser = uniqueLocalUser()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusUserCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        expect(sut, toCompleteWith: .success(nil), when: {
            store.completeRetrieval(with: localUser, timestamp: expiredTimestamp)
        })
    }

    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()

        sut.load(userId: 1) { _ in }
        store.completeRetrieval(with: anyNSError())

        XCTAssertEqual(store.receivedMessages, [.retrieve(1)])
    }

    func test_load_hasNoSideEffectsOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.load(userId: 1) { _ in }
        store.completeRetrievalWithEmptyCache()

        XCTAssertEqual(store.receivedMessages, [.retrieve(1)])
    }

    func test_load_hasNoSideEffectsOnNonExpiredCache() {
        let localUser = uniqueLocalUser()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusUserCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.load(userId: 1) { _ in }
        store.completeRetrieval(with: localUser, timestamp: nonExpiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve(1)])
    }

    func test_load_hasNoSideEffectsOnCacheExpiration() {
        let localUser = uniqueLocalUser()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusUserCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.load(userId: 1) { _ in }
        store.completeRetrieval(with: localUser, timestamp: expirationTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve(1)])
    }

    func test_load_hasNoSideEffectsOnExpiredCache() {
        let localUser = uniqueLocalUser()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusUserCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: { fixedCurrentDate })

        sut.load(userId: 1) { _ in }
        store.completeRetrieval(with: localUser, timestamp: expiredTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve(1)])
    }

    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = UserStoreSpy()
        var sut: LocalUserLoader? = LocalUserLoader(store: store, currentDate: Date.init)

        var receivedResults = [LocalUserLoader.LoadResult]()
        sut?.load(userId: 1) { receivedResults.append($0) }

        sut = nil
        store.completeRetrievalWithEmptyCache()

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
        toCompleteWith expectedResult: LocalUserLoader.LoadResult,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")

        sut.load(userId: 1) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedUser), .success(expectedUser)):
                XCTAssertEqual(receivedUser, expectedUser, file: file, line: line)

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
