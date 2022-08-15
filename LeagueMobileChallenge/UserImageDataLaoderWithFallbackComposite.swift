//
//  UserImageDataLaoderWithFallbackComposite.swift
//  LeagueMobileChallenge
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//  Copyright © 2022 Kelvin Lau. All rights reserved.
//

import Foundation
import PostLoader

public class UserImageDataLoaderWithFallbackComposite: UserImageDataLoader {

    private let primary: UserImageDataLoader
    private let fallback: UserImageDataLoader

    public init(
        primary: UserImageDataLoader,
        fallback: UserImageDataLoader
    ) {
        self.primary = primary
        self.fallback = fallback
    }

    public func loadUserImageData(
        url: URL,
        userId: Int,
        completion: @escaping (UserImageDataLoader.Result) -> Void
    ) -> UserImageDataLoaderTask {

        return primary.loadUserImageData(
            url: url,
            userId: userId) { [weak self] result in
                switch result {
                case . success:
                    completion(result)
                case .failure:
                    self?.fallback.loadUserImageData(
                        url: url,
                        userId: userId,
                        completion: completion
                    )
                }
            }
    }
}
