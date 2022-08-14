//
//  UserLoader.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 13/08/22.
//

import Foundation

public protocol UserLoader {
    typealias Result = Swift.Result<User?, Error>

    func load(userId: Int, completion: @escaping (Result) -> Void)
}
