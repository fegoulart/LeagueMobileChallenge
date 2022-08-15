//
//  PostUIComposer.swift
//  LeagueMobileChallenge
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//  Copyright © 2022 Kelvin Lau. All rights reserved.
//

import UIKit
import PostLoader
import PostLoaderIOS

public final class PostUIComposer {
    private init() {}

    public static func postFeedComposedWith(
        postLoader: PostLoader,
        userLoader: UserLoader,
        userImageDataLoader: UserImageDataLoader
    ) -> PostViewController {
        let presentationAdapter = PostFeedLoaderPresentationAdapter(postLoader: postLoader)

        let feedController = makeFeedViewController(
            delegate: presentationAdapter,
            title: PostFeedPresenter.title
        )

        presentationAdapter.presenter = PostFeedPresenter(
            postFeedView: PostFeedViewAdapter(
                controller: feedController,
                userLoader: userLoader,
                userImageDataLoader: userImageDataLoader
            ),
            loadingView: WeakRefVirtualProxy(feedController),
            errorView: WeakRefVirtualProxy(feedController)
        )

        return feedController
    }

    private static func makeFeedViewController(
        delegate: PostViewControllerDelegate,
        title: String
    ) -> PostViewController {
        let bundle = Bundle(for: PostViewController.self)
        let storyboard = UIStoryboard(name: "Post", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! PostViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
