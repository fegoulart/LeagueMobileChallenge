//
//  PostLoaderAPIEndToEndTests.swift
//  PostLoaderAPIEndToEndTests
//
//  Created by Fernando Luiz Goulart on 14/08/22.
//

import XCTest
import PostLoader

class UserAPIEndToEndTests: XCTestCase {

    var token: String?

    override func setUp() {
        super.setUp()

        let remoteTokenLoader = RemoteUserSessionTokenLoader(
            url: userSessionTokenTestServerURL,
            client: ephemeralClient()
        )

        let exp = expectation(description: "Wait for load completion")

        remoteTokenLoader.load { [weak self] result in
            switch result {
            case .success(let token):
                self?.token = token
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
    }

    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
        switch getUserResult(userId: 8) {
        case let .success(user)?:
            XCTAssertEqual(user, expectedUser())

        case let .failure(error)?:
            XCTFail("Expected successful feed result, got \(error) instead")

        default:
            XCTFail("Expected successful feed result, got no result instead")
        }
    }

    func test_endToEndTestServerGETUserImageDataResult_matchesFixedTestAccountData() {
        switch getUserImageDataResult() {
        case let .success(data)?:
            XCTAssertFalse(data.isEmpty, "Expected non-empty image data")

        case let .failure(error)?:
            XCTFail("Expected successful image data result, got \(error) instead")

        default:
            XCTFail("Expected successful image data result, got no result instead")
        }
    }

    // MARK: - Helpers

    private func getUserResult(userId: Int, file: StaticString = #file, line: UInt = #line) -> UserLoader.Result? {
        let loader = RemoteUserLoader(
            url: userTestServerURL,
            client: ephemeralClient(),
            tokenProvider: { [weak self] in
                guard let self = self else { return "1234" }
                return self.token ?? "1234"
            })
        trackForMemoryLeaks(loader, file: file, line: line)

        let exp = expectation(description: "Wait for load completion")

        var receivedResult: UserLoader.Result?
        loader.load(userId: userId) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)

        return receivedResult
    }

    private func getUserImageDataResult(file: StaticString = #file, line: UInt = #line) -> UserImageDataLoader.Result? {
        let loader = RemoteUserImageDataLoader(client: ephemeralClient())
        trackForMemoryLeaks(loader, file: file, line: line)

        let exp = expectation(description: "Wait for load completion")
        let url = userImageTestServerURL

        var receivedResult: UserImageDataLoader.Result?
        _ = loader.loadUserImageData(url: url, userId: 8) { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)

        return receivedResult
    }

    private var userTestServerURL: URL {
        return URL(string: "https://engineering.league.dev/challenge/api/users")!
    }

    private var userSessionTokenTestServerURL: URL {
        return URL(string: "https://engineering.league.dev/challenge/api/login")!
    }

    private var userImageTestServerURL: URL {
        return URL(string: "https://i.pravatar.cc/150?u=Sherwood@rosamond.me")!
    }

    private func ephemeralClient(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        trackForMemoryLeaks(client, file: file, line: line)
        return client
    }

    private func expectedUser() -> User {
        return User(
            id: 8,
            name: "Nicholas Runolfsdottir V",
            imageUrl: URL(string: "https://i.pravatar.cc/150?u=Sherwood@rosamond.me")!
        )
    }
}
