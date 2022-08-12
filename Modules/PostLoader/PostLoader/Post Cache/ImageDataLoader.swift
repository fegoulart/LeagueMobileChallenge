//
//  ImageDataLoader.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 12/08/22.
//

import Foundation

public protocol ImageDataLoaderTask {
    func cancel()
}

public protocol ImageDataLoader {
    typealias Result = Swift.Result<Data, Error>

    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> ImageDataLoaderTask
}
