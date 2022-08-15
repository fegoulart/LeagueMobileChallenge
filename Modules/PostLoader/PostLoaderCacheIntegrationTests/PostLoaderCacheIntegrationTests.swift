//
//  PostLoaderCacheIntegrationTests.swift
//  PostLoaderCacheIntegrationTests
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//

import XCTest
import PostLoader

class PostLoaderCacheIntegrationTests: XCTestCase {

    override func setUp() {
        super.setUp()

        setupEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()

        undoStoreSideEffects()
    }

    // MARK: - LocalUserLoader Tests

    func test_loadUser_deliversNoItemsOnEmptyCache() {
        let userLoader = makeUserLoader()

        expect(userLoader, userId: 8, toLoad: nil)
    }

    func test_loadUser_deliversItemsSavedOnASeparateInstance() {
        let userLoaderToPerformSave = makeUserLoader()
        let userLoaderToPerformLoad = makeUserLoader()
        let user = User(
            id: 8,
            name: "Nicholas Runolfsdottir V",
            imageUrl: URL(string: "https://i.pravatar.cc/150?u=Sherwood@rosamond.me")!
        )
        save(user, with: userLoaderToPerformSave)

        expect(userLoaderToPerformLoad, userId: 8, toLoad: user)
    }

    func test_saveUser_overridesItemsSavedOnASeparateInstance() {
        let userLoaderToPerformFirstSave = makeUserLoader()
        let userLoaderToPerformLastSave = makeUserLoader()
        let userLoaderToPerformLoad = makeUserLoader()
        let firstUser = User(
            id: 8,
            name: "Nicholas Runolfsdottir IV",
            imageUrl: URL(string: "https://i.pravatar.cc/150?u=Sherwood@rosamond.me")!
        )
        let latestUser = User(
            id: 8,
            name: "Nicholas Runolfsdottir V",
            imageUrl: URL(string: "https://i.pravatar.cc/150?u=Sherwood@rosamond.me")!
        )

        save(firstUser, with: userLoaderToPerformFirstSave)
        save(latestUser, with: userLoaderToPerformLastSave)

        expect(userLoaderToPerformLoad, userId: 8, toLoad: latestUser)
    }

    func test_validateUserCache_doesNotDeleteRecentlySavedUser() {
        let userLoaderToPerformSave = makeUserLoader()
        let userLoaderToPerformValidation = makeUserLoader()
        let user = User(
            id: 8,
            name: "Nicholas Runolfsdottir V",
            imageUrl: URL(string: "https://i.pravatar.cc/150?u=Sherwood@rosamond.me")!
        )

        save(user, with: userLoaderToPerformSave)
        validateCache(with: userLoaderToPerformValidation)

        expect(userLoaderToPerformSave, userId: 8, toLoad: user)
    }

    func test_validateUserCache_deletesUserSavedInADistantPast() {
        let userLoaderToPerformSave = makeUserLoader(currentDate: .distantPast)
        let userLoaderToPerformValidation = makeUserLoader(currentDate: Date())
        let user = User(
            id: 8,
            name: "Nicholas Runolfsdottir V",
            imageUrl: URL(string: "https://i.pravatar.cc/150?u=Sherwood@rosamond.me")!
        )

        save(user, with: userLoaderToPerformSave)
        validateCache(with: userLoaderToPerformValidation)

        expect(userLoaderToPerformSave, userId: 8, toLoad: nil)
    }

    // MARK: - LocalUserImageDataLoader Tests

    func test_loadImageData_deliversSavedDataOnASeparateInstance() {
        let imageLoaderToPerformSave = makeImageLoader()
        let imageLoaderToPerformLoad = makeImageLoader()
        let userLoader = makeUserLoader()
        let dataToSave = Data("any data".utf8)
        let url = URL(string: "https://i.pravatar.cc/150?u=Sherwood@rosamond.me")!
        let user = User(
            id: 8,
            name: "Nicholas Runolfsdottir V",
            imageUrl: URL(string: "https://i.pravatar.cc/150?u=Sherwood@rosamond.me")!
        )

        save(user, with: userLoader)
        save(dataToSave, for: url, userId: 8, with: imageLoaderToPerformSave)

        expect(imageLoaderToPerformLoad, userId: 8, toLoad: dataToSave, for: url)
    }

    func test_saveImageData_overridesSavedImageDataOnASeparateInstance() {
        let imageLoaderToPerformFirstSave = makeImageLoader()
        let imageLoaderToPerformLastSave = makeImageLoader()
        let imageLoaderToPerformLoad = makeImageLoader()
        let userLoader = makeUserLoader()
        let user = User(
            id: 8,
            name: "Nicholas Runolfsdottir V",
            imageUrl: URL(string: "https://i.pravatar.cc/150?u=Sherwood@rosamond.me")!
        )
        let firstImageData = Data("first".utf8)
        let lastImageData = Data("last".utf8)
        let url = URL(string: "https://i.pravatar.cc/150?u=Sherwood@rosamond.me")!

        save(user, with: userLoader)
        save(firstImageData, for: url, userId: 8, with: imageLoaderToPerformFirstSave)
        save(lastImageData, for: url, userId: 8, with: imageLoaderToPerformLastSave)

        expect(imageLoaderToPerformLoad, userId: 8, toLoad: lastImageData, for: url)
    }

    // MARK: - Helpers

    private func makeUserLoader(
        currentDate: Date = Date(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> LocalUserLoader {
        let storeURL = specificTestStoreURL()
        // swiftlint:disable:next force_try
        let store = try! CoreDataPostStore(storeURL: storeURL)
        let sut = LocalUserLoader(store: store, currentDate: { currentDate })
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func makeImageLoader(file: StaticString = #file, line: UInt = #line) -> LocalUserImageDataLoader {
        let storeURL = specificTestStoreURL()
        // swiftlint:disable:next force_try
        let store = try! CoreDataPostStore(storeURL: storeURL)
        let sut = LocalUserImageDataLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func save(
        _ user: User,
        with loader: LocalUserLoader,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let saveExp = expectation(description: "Wait for save completion")
        loader.save(user) { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to save user successfully, got error: \(error)", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }

    private func validateCache(with loader: LocalUserLoader, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        loader.validateCache { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to validate user successfully, got error: \(error)", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }

    private func expect(
        _ sut: LocalUserLoader,
        userId: Int,
        toLoad expectedUser: User?,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        sut.load(userId: userId) { result in
            switch result {
            case let .success(loadedUser):
                XCTAssertEqual(loadedUser, expectedUser, file: file, line: line)

            case let .failure(error):
                XCTFail("Expected successful user result, got \(error) instead", file: file, line: line)
            }

            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    private func save(
        _ data: Data,
        for url: URL,
        userId: Int,
        with loader: LocalUserImageDataLoader,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let saveExp = expectation(description: "Wait for save completion")
        loader.save(data, userId: userId, url: url) { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to save image data successfully, got error: \(error)", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }

    private func expect(
        _ sut: LocalUserImageDataLoader,
        userId: Int,
        toLoad expectedData: Data,
        for url: URL,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        _ = sut.loadUserImageData(url: url, userId: userId) { result in
            switch result {
            case let .success(loadedData):
                XCTAssertEqual(loadedData, expectedData, file: file, line: line)

            case let .failure(error):
                XCTFail("Expected successful image data result, got \(error) instead", file: file, line: line)
            }

            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }

    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: specificTestStoreURL())
    }

    private func specificTestStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }

    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

}
