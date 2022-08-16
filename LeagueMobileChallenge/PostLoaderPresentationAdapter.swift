//
//  PostLoaderPresentationAdapter.swift
//  LeagueMobileChallenge
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//  Copyright © 2022 Kelvin Lau. All rights reserved.
//

import Foundation
import PostLoader
import PostLoaderIOS

final class PostFeedLoaderPresentationAdapter: PostViewControllerDelegate {
    private let postLoader: PostLoader
    var presenter: PostFeedPresenter?

    init(postLoader: PostLoader) {
        self.postLoader = postLoader
    }

    func didRequestPostRefresh() {
        presenter?.didStartLoadingPostFeed()
        self.postLoader.load { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let posts):
                self.presenter?.didFinishLoadingFeed(with: posts)
            case .failure(let error):
                self.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
