//
//  UserImageDataStore.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 12/08/22.
//

import Foundation

public protocol UserImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>

    func insert(_ data: Data, userId: Int, url: URL, completion: @escaping (InsertionResult) -> Void)
    func retrieve(dataForURL url: URL, userId: Int, completion: @escaping (RetrievalResult) -> Void)
}
