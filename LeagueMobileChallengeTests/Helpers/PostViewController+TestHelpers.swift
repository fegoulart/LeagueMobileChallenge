//
//  PostViewController+TestHelpers
//  LeagueMobileChallenge
//
//  Created by Fernando Luiz Goulart on 16/08/22.
//  Copyright © 2022 Kelvin Lau. All rights reserved.
//

import UIKit
import PostLoaderIOS

extension PostViewController {
	func simulateUserInitiatedFeedReload() {
		refreshControl?.simulatePullToRefresh()
	}

	@discardableResult
	func simulatePostViewVisible(at index: Int) -> PostCell? {
		return postView(at: index) as? PostCell
	}

	@discardableResult
	func simulatePostViewNotVisible(at row: Int) -> PostCell? {
		let view = simulatePostViewVisible(at: row)

		let delegate = tableView.delegate
		let index = IndexPath(row: row, section: postsSection)
		delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)

		return view
	}

	func simulatePostViewNearVisible(at row: Int) {
		let dataSource = tableView.prefetchDataSource
		let index = IndexPath(row: row, section: postsSection)
		dataSource?.tableView(tableView, prefetchRowsAt: [index])
	}

	func simulatePostViewNotNearVisible(at row: Int) {
		simulatePostViewNearVisible(at: row)

		let dataSource = tableView.prefetchDataSource
		let index = IndexPath(row: row, section: postsSection)
		dataSource?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
	}

	func renderedPostData(at index: Int) -> Data? {
		return simulatePostViewVisible(at: index)?.renderedImage
	}

	var errorMessage: String? {
		return errorView?.message
	}

	var isShowingLoadingIndicator: Bool {
		return refreshControl?.isRefreshing == true
	}

	func numberOfRenderedPostsViews() -> Int {
		return tableView.numberOfRows(inSection: postsSection)
	}

	func postView(at row: Int) -> UITableViewCell? {
		guard numberOfRenderedPostsViews() > row else {
			return nil
		}
		let dataSource = tableView.dataSource
		let index = IndexPath(row: row, section: postsSection)
		return dataSource?.tableView(tableView, cellForRowAt: index)
	}

	private var postsSection: Int {
		return 0
	}
}
