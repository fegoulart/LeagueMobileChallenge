//
//  RemotePost.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 14/08/22.
//

import Foundation

public struct RemotePost: Decodable {
    public var id: Int
    public var userId: Int?
    public var title: String?
    public var body: String?

    public init(
        id: Int,
        userId: Int?,
        title: String?,
        body: String?
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.body = body
    }
}
