//
//  RemoteUser.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 14/08/22.
//

import Foundation

public struct RemoteUser: Decodable {
    public var id: Int
    public var avatar: String?
    public var name: String?

    public init(
        id: Int,
        avatar: String?,
        name: String?
    ) {
        self.id = id
        self.avatar = avatar
        self.name = name
    }
}
