//
//  UserSessionTokenMapper.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 14/08/22.
//

import Foundation

final class UserSessionTokenMapper {

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> RemoteUserSessionToken {
        guard response.isOk, let token = try? JSONDecoder().decode(RemoteUserSessionToken.self, from: data) else {
            throw RemoteUserSessionTokenLoader.Error.invalidData
        }
        return token
    }
}
