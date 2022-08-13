//
//  ImageDataCache.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 12/08/22.
//

import Foundation

public protocol UserImageDataCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ data: Data, userId: Int, url: URL, completion: @escaping (Result) -> Void)
}
