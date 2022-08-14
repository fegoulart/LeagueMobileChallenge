//
//  UserMapper.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 14/08/22.
//

import Foundation

final class UserMapper {
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteUser] {
        guard response.isOk, let users = try? JSONDecoder().decode([RemoteUser].self, from: data) else {
            throw RemoteUserLoader.Error.invalidData
        }
        return users
    }
}
