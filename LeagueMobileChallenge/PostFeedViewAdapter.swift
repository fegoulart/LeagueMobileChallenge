//
//  PostViewAdapter.swift
//  LeagueMobileChallenge
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//  Copyright © 2022 Kelvin Lau. All rights reserved.
//

import UIKit
import Foundation
import PostLoader
import PostLoaderIOS

final class PostFeedViewAdapter: PostFeedView {
    private weak var controller: PostViewController?
    private let userLoader: UserLoader
    private let userImageDataLoader: UserImageDataLoader

    init(
        controller: PostViewController,
        userLoader: UserLoader,
        userImageDataLoader: UserImageDataLoader
    ) {
        self.controller = controller
        self.userLoader = userLoader
        self.userImageDataLoader = userImageDataLoader
    }

    func display(_ viewModel: PostFeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = UserLoaderPresentationAdapter<WeakRefVirtualProxy<PostCellController>, UIImage>(
                model: model,
                userImageLoader: userImageDataLoader,
                userLoader: userLoader
            )
            let view = PostCellController(delegate: adapter)
            adapter.presenter = PostPresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init
            )
            return view
        })
    }




}
