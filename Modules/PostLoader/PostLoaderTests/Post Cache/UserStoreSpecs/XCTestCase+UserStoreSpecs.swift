//
//  XCTestCase+UserStoreSpecs.swift
//  PostLoaderTests
//
//  Created by Fernando Luiz Goulart on 13/08/22.
//

import XCTest
import PostLoader

extension UserStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversEmptyOnEmptyCache(
        on sut: UserStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        expect(sut, toRetrieve: .success(nil), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(
        on sut: UserStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        expect(sut, toRetrieveTwice: .success(.none), file: file, line: line)
    }

    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(
        on sut: UserStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let user = uniqueLocalUser()
        let timestamp = Date()
        var cachedUser: LocalUser = user
        cachedUser.cacheInsertionDate = timestamp

        insert((user, timestamp), to: sut)
        expect(sut, toRetrieve: .success(cachedUser), file: file, line: line)
    }

    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(
        on sut: UserStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let user = uniqueLocalUser()
        let timestamp = Date()
        var cachedUser: LocalUser = user
        cachedUser.cacheInsertionDate = timestamp

        insert((user, timestamp), to: sut)

        expect(sut, toRetrieveTwice: .success(cachedUser), file: file, line: line)
    }

    func assertThatInsertDeliversNoErrorOnEmptyCache(
        on sut: UserStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let insertionError = insert((uniqueLocalUser(), Date()), to: sut)

        XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
    }

    func assertThatInsertDeliversNoErrorOnNonEmptyCache(
        on sut: UserStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        insert((uniqueLocalUser(), Date()), to: sut)

        let insertionError = insert((uniqueLocalUser(), Date()), to: sut)

        XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
    }

    func assertThatInsertOverridesPreviouslyInsertedCacheValues(
        on sut: UserStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        insert((uniqueLocalUser(), Date()), to: sut)

        let latestUser = uniqueLocalUser()
        let latestTimestamp = Date()
        insert((latestUser, latestTimestamp), to: sut)
        var expectedCachedUser = latestUser
        expectedCachedUser.cacheInsertionDate = latestTimestamp

        expect(
            sut,
            toRetrieve: .success(expectedCachedUser),
            file: file,
            line: line
        )
    }

    func assertThatDeleteDeliversNoErrorOnEmptyCache(
        on sut: UserStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
    }

    func assertThatDeleteHasNoSideEffectsOnEmptyCache(
        on sut: UserStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        deleteCache(from: sut)

        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }

    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(
        on sut: UserStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        insert((uniqueLocalUser(), Date()), to: sut)

        let deletionError = deleteCache(from: sut)

        XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
    }

    func assertThatDeleteEmptiesPreviouslyInsertedCache(
        on sut: UserStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        insert((uniqueLocalUser(), Date()), to: sut)

        deleteCache(from: sut)

        expect(sut, toRetrieve: .success(.none), file: file, line: line)
    }

    func assertThatSideEffectsRunSerially(
        on sut: UserStore,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var completedOperationsInOrder = [XCTestExpectation]()

        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueLocalUser(), timestamp: Date()) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }

        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedUser([uniqueLocalUser()]) { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }

        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueLocalUser(), timestamp: Date()) { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }

        waitForExpectations(timeout: 5.0)

        XCTAssertEqual(
            completedOperationsInOrder,
            [op1, op2, op3],
            "Expected side-effects to run serially but operations finished in the wrong order",
            file: file,
            line: line
        )
    }
}

extension UserStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(_ cache: (user: LocalUser, timestamp: Date), to sut: UserStore) -> Error? {
        let exp = expectation(description: "Wait for cache insertion")
        var insertionError: Error?
        sut.insert(cache.user, timestamp: cache.timestamp) { result in
            if case let Result.failure(error) = result { insertionError = error }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return insertionError
    }

    @discardableResult
    func deleteCache(from sut: UserStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?

        sut.deleteCachedUser([uniqueLocalUser()]) { result in
            if case let Result.failure(error) = result { deletionError = error }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }

    @discardableResult
    func cleanCache(from sut: UserStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var deletionError: Error?

        sut.cleanCache { result in
            if case let Result.failure(error) = result { deletionError = error }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }

    func expect(
        _ sut: UserStore,
        toRetrieveTwice expectedResult: UserStore.RetrievalResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut, toRetrieve: expectedResult, file: file, line: line)
    }

    func expect(
        _ sut: UserStore,
        userId: Int = 1,
        toRetrieve expectedResult: UserStore.RetrievalResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for cache retrieval")

        sut.retrieve(userWithId: userId) { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.success(.none), .success(.none)),
                (.failure, .failure):
                break

            case let (.success(.some(expected)), .success(.some(retrieved))):
                XCTAssertEqual(retrieved, expected, file: file, line: line)

            default:
                XCTFail(
                    "Expected to retrieve \(expectedResult), got \(retrievedResult) instead",
                    file: file,
                    line: line
                )
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
}
