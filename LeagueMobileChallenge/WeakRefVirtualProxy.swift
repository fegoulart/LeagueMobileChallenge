//
//  WeakRefVirtualProxy.swift
//  LeagueMobileChallenge
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//  Copyright © 2022 Kelvin Lau. All rights reserved.
//

import UIKit
import PostLoader

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?

    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: PostFeedErrorView where T: PostFeedErrorView {
    func display(_ viewModel: PostFeedErrorViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: PostFeedLoadingView where T: PostFeedLoadingView {
    func display(_ viewModel: PostFeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: PostView where T: PostView, T.Image == UIImage {
    func display(_ model: PostViewModel<UIImage>) {
        object?.display(model)
    }
}
