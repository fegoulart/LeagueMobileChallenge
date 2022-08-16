//
//  PostAcceptanceTests.swift
//  LeagueMobileChallengeTests
//
//  Created by Fernando Luiz Goulart on 16/08/22.
//  Copyright © 2022 Kelvin Lau. All rights reserved.
//

import XCTest
import PostLoader
import PostLoaderIOS
@testable import LeagueMobileChallenge

class PostAcceptanceTests: XCTestCase {

    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let feed = launch(httpClient: .online(response), store: .empty)

        XCTAssertEqual(feed.numberOfRenderedPostsViews(), 2)
    }

        func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
            let feed = launch(httpClient: .offline, store: .empty)

            XCTAssertEqual(feed.numberOfRenderedPostsViews(), 0)
        }

        func test_onEnteringBackground_deletesExpiredFeedCache() {
            let store = InMemoryUserStore.withExpiredUserCache

            enterBackground(with: store)

            XCTAssert(store.userCache.isEmpty, "Expected to delete expired cache")
        }

        func test_onEnteringBackground_keepsNonExpiredFeedCache() {
            let store = InMemoryUserStore.withNonExpiredUserCache

            enterBackground(with: store)

            XCTAssert(!store.userCache.isEmpty, "Expected to keep non-expired cache")
        }

    // MARK: - Helpers

    private func launch(
        httpClient: HTTPClientStub = .offline,
        store: InMemoryUserStore = .empty
    ) -> PostViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()

        let nav = sut.window?.rootViewController as? UINavigationController
        // swiftlint:disable:next force_cast
        return nav?.topViewController as! PostViewController
    }

    private func enterBackground(with store: InMemoryUserStore) {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
    }

    private func response(for urlRequest: URLRequest) -> (Data, HTTPURLResponse) {
        let url = urlRequest.url!
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }

    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "http://image.com":
            return makeImageData()

        default:
            return makePostData()
        }
    }

    private func makeImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }

    private func makeUserData() -> Data {
        // swiftlint:disable:next force_try
        return try! JSONSerialization.data(withJSONObject: [
            "id": 1,
            "name": "Jose",
            "imageUrl": "http://image.com",
            "cacheInsertionDate": "2020-08-01 01:00:00"
        ]
        )
    }

    private func makePostData() -> Data {
        // swiftlint:disable:next force_try
        return try! JSONSerialization.data(withJSONObject: [
            [
                "id": 1,
                "userId": 1,
                "title": "Post Title",
                "body": "Post body"
            ],
            [ "id": 2,
              "userId": 1,
              "title": "Second title",
              "body": "Second body"
            ]
        ]
        )
    }
}
