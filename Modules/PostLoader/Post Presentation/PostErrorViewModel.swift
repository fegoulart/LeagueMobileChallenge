//
//  PostErrorViewModel.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//

import Foundation

public struct PostFeedErrorViewModel {
    public let message: String?

    static var noError: PostFeedErrorViewModel {
        return PostFeedErrorViewModel(message: nil)
    }

    static func error(message: String) -> PostFeedErrorViewModel {
        return PostFeedErrorViewModel(message: message)
    }
}
