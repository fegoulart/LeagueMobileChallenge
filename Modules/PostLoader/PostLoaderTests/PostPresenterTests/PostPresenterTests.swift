//
//  UserPresenterTests.swift
//  PostLoaderTests
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//

import XCTest
import PostLoader

class PostPresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()

        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }

    func test_didStartLoadingUser_displaysLoadingImage() {
        let (sut, view) = makeSUT()

        sut.didStartLoadingUser(for: uniquePost)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.userName, nil)
        XCTAssertEqual(message?.postTitle, uniquePost.title)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.postBody, uniquePost.body)
        XCTAssertNil(message?.userImage)
    }

    func test_didFinishLoadingUser_displaysUserName() {
        let (sut, view) = makeSUT()

        sut.didFinishLoadingUser(for: uniquePost, for: uniqueUser)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.userName, uniqueUser.name)
        XCTAssertEqual(message?.postTitle, uniquePost.title)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.postBody, uniquePost.body)
        XCTAssertNil(message?.userImage)
    }

    func test_didStartLoadingUserImageData_displaysLoadingImage() {
        let (sut, view) = makeSUT()

        sut.didStartLoadingImageData(for: uniquePost, user: uniqueUser)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.userName, uniqueUser.name)
        XCTAssertEqual(message?.postTitle, uniquePost.title)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.postBody, uniquePost.body)
        XCTAssertNil(message?.userImage)
    }

    func test_didFinishLoadingUserImageData_displaysImageOnSuccessfulTransformation() {

        let transformedData = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })

        sut.didFinishLoadingImageData(with: Data(), for: uniquePost, user: uniqueUser)

        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.userName, uniqueUser.name)
        XCTAssertEqual(message?.postTitle, uniquePost.title)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.postBody, uniquePost.body)
        XCTAssertEqual(message?.userImage, transformedData)
    }

    // MARK: - Helpers

    private func makeSUT(
        imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: PostPresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = PostPresenter(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }

    private var fail: (Data) -> AnyImage? {
        return { _ in nil }
    }

    private struct AnyImage: Equatable {}

    private class ViewSpy: PostView {
        // swiftlint:disable:next nesting
        typealias Image = AnyImage

        private(set) var messages = [PostViewModel<AnyImage>]()

        func display(_ model: PostViewModel<AnyImage>) {
            messages.append(model)
        }
    }

    private let uniquePost = Post(
        id: 69,
        userId: 7,
        userName: nil,
        userImageUrl: nil,
        title: "fugiat quod pariatur odit minima",
        body: """
            officiis error culpa consequatur modi asperiores et\ndolorum assumenda voluptas et vel qui aut vel
 rerum\nvoluptatum quisquam perspiciatis quia rerum consequatur totam quas\nsequi commodi repudiandae asperiores
 et saepe a
"""
    )
    private let uniqueUser = User(
        id: 7,
        name: "Kurtis Weissnat",
        imageUrl: URL(string: "https://i.pravatar.cc/150?u=Telly.Hoeger@billy.biz")!
    )
}
