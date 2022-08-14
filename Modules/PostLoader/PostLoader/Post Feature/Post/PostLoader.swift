//
//  PostLoader.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 14/08/22.
//

import Foundation

public protocol PostLoader {
    typealias Result = Swift.Result<[Post], Error>

    func load(completion: @escaping (Result) -> Void)
}
