//
//  UserTokenLoader.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 14/08/22.
//

import Foundation

public protocol UserSessionTokenLoader {
    typealias Result = Swift.Result<String, Error>

    func load(completion: @escaping (Swift.Result<String, Error>) -> Void)
}
