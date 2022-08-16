//
//  PostUIIntegrationTests.swift
//  LeagueMobileChallengeTests
//
//  Created by Fernando Luiz Goulart on 16/08/22.
//  Copyright © 2022 Kelvin Lau. All rights reserved.
//

import XCTest
import UIKit
import LeagueMobileChallenge
import PostLoader
import PostLoaderIOS

final class PostUIIntegrationTests: XCTestCase {

    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.title, localized("POST_VIEW_TITLE"))
    }

    func test_loadPostActions_requestPostFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadPostCallCount, 0, "Expected no loading requests before view is loaded")

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadPostCallCount, 1, "Expected a loading request once view is loaded")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadPostCallCount, 2, "Expected another loading request once user initiates a reload")

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(
            loader.loadPostCallCount,
            3,
            "Expected yet another loading request once user initiates another reload"
        )
    }

    func test_loadingPostIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(
            sut.isShowingLoadingIndicator,
            "Expected no loading indicator once loading completes successfully"
        )

        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(
            sut.isShowingLoadingIndicator,
            "Expected loading indicator once user initiates a reload"
        )

        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(
            sut.isShowingLoadingIndicator,
            "Expected no loading indicator once user initiated loading completes with error"
        )
    }

    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let post0 = makePost(
            postId: 0,
            userId: 1,
            userName: "a name",
            userImageUrl: nil,
            title: "a title",
            body: "a body"
        )
        let post1 = makePost(
            postId: 1,
            userId: 2,
            userName: "a name",
            userImageUrl: nil,
            title: "a title",
            body: "a body"
        )
        let post2 = makePost(
            postId: 2,
            userId: 3,
            userName: "a name",
            userImageUrl: nil,
            title: "a title",
            body: "a body"
        )
        let post3 = makePost(
            postId: 3,
            userId: 4,
            userName: "a name",
            userImageUrl: nil,
            title: "a title",
            body: "a body"
        )
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])

        loader.completeFeedLoading(with: [post0], at: 0)
        assertThat(sut, isRendering: [post0])

        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [post0, post1, post2, post3], at: 1)
        assertThat(sut, isRendering: [post0, post1, post2, post3])
    }

    // MARK: - Helpers

    private func makeSUT(
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: PostViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = PostUIComposer.postFeedComposedWith(
            postLoader: loader,
            userLoader: loader,
            userImageDataLoader: loader
        )
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }

    // swiftlint:disable:next function_parameter_count
    private func makePost(
        postId: Int,
        userId: Int,
        userName: String?,
        userImageUrl: URL?,
        title: String,
        body: String
    ) -> Post {
        return Post(
            id: postId,
            userId: userId,
            userName: userName,
            userImageUrl: userImageUrl,
            title: title,
            body: body
        )
    }

    private func anyImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
}
