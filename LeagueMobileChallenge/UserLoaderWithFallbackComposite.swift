//
//  UserLoaderWithFallbackComposite.swift
//  LeagueMobileChallenge
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//  Copyright © 2022 Kelvin Lau. All rights reserved.
//

import Foundation
import PostLoader

public class UserLoaderWithFallbackComposite: UserLoader {

    private let primary: UserLoader
    private let fallback: UserLoader
    private var resultTask: UserLoaderTask?

    public init(
        primary: UserLoader,
        fallback: UserLoader
    ) {
        self.primary = primary
        self.fallback = fallback
    }

    public func load(
        userId: Int,
        completion: @escaping (UserLoader.Result) -> Void
    ) -> UserLoaderTask? {
        resultTask = nil
        let primaryLoaderTask = primary.load(userId: userId) { [weak self] result in
            switch result {
            case . success:
                completion(result)
                self?.
            case .failure:
                self?.fallback.load(userId: userId, completion: completion)
            }

        }
    }
}
