//
//  FeedUIIntegrationTests+Assertions.swift
//  LeagueMobileChallenge
//
//  Created by Fernando Luiz Goulart on 16/08/22.
//  Copyright © 2022 Kelvin Lau. All rights reserved.
//

import XCTest
import PostLoader
import PostLoaderIOS

extension PostUIIntegrationTests {

    func assertThat(
        _ sut: PostViewController,
        isRendering feed: [Post],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        sut.view.enforceLayoutCycle()

        guard sut.numberOfRenderedPostsViews() == feed.count else {
            return XCTFail(
                "Expected \(feed.count) images, got \(sut.numberOfRenderedPostsViews()) instead.",
                file: file,
                line: line
            )
        }

        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }

    func assertThat(
        _ sut: PostViewController,
        hasViewConfiguredFor post: Post,
        at index: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let view = sut.postView(at: index)

        guard let cell = view as? PostCell else {
            return XCTFail(
                "Expected \(PostCell.self) instance, got \(String(describing: view)) instead",
                file: file,
                line: line
            )
        }

        XCTAssertEqual(
            cell.postBodyText,
            post.body,
            "Expected body text to be \(String(describing: post.body)) for post view at index (\(index))",
            file: file,
            line: line
        )

        XCTAssertEqual(
            cell.postTitleText,
            post.title,
            "Expected title text to be \(String(describing: post.title)) for post view at index (\(index))",
            file: file,
            line: line
        )
    }
}
