//
//  FeedImageCell+TestHelpers.swift
//  LeagueMobileChallenge
//
//  Created by Fernando Luiz Goulart on 16/08/22.
//  Copyright © 2022 Kelvin Lau. All rights reserved.
//

import UIKit
import PostLoaderIOS

extension PostCell {
	var isShowingImageLoadingIndicator: Bool {
        return userImageView.isShimmering
	}

	var userNameText: String? {
		return userNameLabel.text
	}

	var postTitleText: String? {
        return postTitleLabel.text
	}

    var postBodyText: String? {
        return postBodyLabel.text
    }

	var renderedImage: Data? {
		return userImageView.image?.pngData()
	}
}
