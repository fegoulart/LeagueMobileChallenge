//
//  PostPresenterTests.swift
//  PostLoaderTests
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//

import XCTest
import PostLoader

class PostPresenterTests: XCTestCase {

    func test_title_isLocalized() {
        XCTAssertEqual(PostFeedPresenter.title, localized("POST_VIEW_TITLE"))
    }

    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    func test_didStartLoadingPostFeed_displaysNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()

        sut.didStartLoadingPostFeed()

        XCTAssertEqual(view.messages, [
            .displayErrorMessage(.none),
            .displayIsLoading(true)
        ])
    }

    func test_didFinishLoadingPostFeed_displaysPostFeedAndStopsLoading() {
        let (sut, view) = makeSUT()
        let feed =  PostFeedStub.feed

        sut.didFinishLoadingFeed(with: feed)

        XCTAssertEqual(view.messages, [
            .displayFeed(feed),
            .displayIsLoading(false)
        ])
    }

    func test_didFinishLoadingPostFeedWithError_displaysLocalizedErrorMessageAndStopsLoading() {
        let (sut, view) = makeSUT()

        sut.didFinishLoadingFeed(with: anyNSError())

        XCTAssertEqual(view.messages, [
            .displayErrorMessage(localized("POST_VIEW_CONNECTION_ERROR")),
            .displayIsLoading(false)
        ])
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: PostFeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = PostFeedPresenter(postFeedView: view, loadingView: view, errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Post"
        let bundle = Bundle(for: PostFeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }

    private class ViewSpy: PostFeedView, PostFeedLoadingView, PostFeedErrorView {

        // swiftlint:disable:next nesting
        enum Message: Hashable {
            case displayErrorMessage(String?)
            case displayIsLoading(Bool)
            case displayFeed([Post])
        }

        private(set) var messages = Set<Message>()

        func display(_ viewModel: PostFeedErrorViewModel) {
            messages.insert(.displayErrorMessage(viewModel.message))
        }

        func display(_ viewModel: PostFeedLoadingViewModel) {
            messages.insert(.displayIsLoading(viewModel.isLoading))
        }

        func display(_ viewModel: PostFeedViewModel) {
            messages.insert(.displayFeed(viewModel.feed))
        }
    }
}
