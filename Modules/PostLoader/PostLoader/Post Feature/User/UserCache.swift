//
//  UserCache.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 13/08/22.
//

import Foundation

public protocol UserCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ user: User, completion: @escaping (Result) -> Void)
}
