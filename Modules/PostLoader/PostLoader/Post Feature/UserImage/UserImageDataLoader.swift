//
//  UserImageDataLoader.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 12/08/22.
//

import Foundation

public protocol UserImageDataLoaderTask {
    func cancel()
}

public protocol UserImageDataLoader {
    typealias Result = Swift.Result<Data, Error>

    @discardableResult
    func loadUserImageData(
        url: URL,
        userId: Int,
        completion: @escaping (Result) -> Void
    ) -> UserImageDataLoaderTask
}
