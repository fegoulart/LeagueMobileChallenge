//
//  RemoteUserSessionToken.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 14/08/22.
//

import Foundation

struct RemoteUserSessionToken {
    let value: String?
}

extension RemoteUserSessionToken: Decodable {
    enum CodingKeys: String, CodingKey {
        case value = "api_key"
    }
}
