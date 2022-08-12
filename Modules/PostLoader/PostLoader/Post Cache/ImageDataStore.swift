//
//  UserImageDataStore.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 12/08/22.
//

import Foundation

public protocol ImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>

    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void)
}
