//
//  PostPresenter.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//

import Foundation

public protocol PostFeedView {
    func display(_ viewModel: PostFeedViewModel)
}

public protocol PostFeedLoadingView {
    func display(_ viewmodel: PostFeedLoadingViewModel)
}

public protocol PostFeedErrorView {
    func display(_ viewModel: PostFeedErrorViewModel)
}

public final class PostFeedPresenter {
    private let postFeedView: PostFeedView
    private let loadingView: PostFeedLoadingView
    private let errorView: PostFeedErrorView

    private var feedLoadError: String {
        return NSLocalizedString("POST_VIEW_CONNECTION_ERROR",
                                 tableName: "Post",
                                 bundle: Bundle(for: PostFeedPresenter.self),
                                 comment: "Error message displayed when we can't load the post feed from the server")
    }

    public init(
        postFeedView: PostFeedView,
        loadingView: PostFeedLoadingView,
        errorView: PostFeedErrorView
    ) {
        self.postFeedView = postFeedView
        self.loadingView = loadingView
        self.errorView = errorView
    }

    public static var title: String {
        return NSLocalizedString("POST_VIEW_TITLE",
                                 tableName: "Post",
                                 bundle: Bundle(for: PostFeedPresenter.self),
                                 comment: "Title for the post feed view")
    }

    public func didStartLoadingPostFeed() {
        errorView.display(.noError)
        loadingView.display(PostFeedLoadingViewModel(isLoading: true))
    }

    public func didFinishLoadingFeed(with feed: [Post]) {
        postFeedView.display(PostFeedViewModel(feed: feed))
        loadingView.display(PostFeedLoadingViewModel(isLoading: false))
    }

    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(PostFeedLoadingViewModel(isLoading: false))
    }
}
