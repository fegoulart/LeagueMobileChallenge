//
//  Post.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 13/08/22.
//

import Foundation

public struct Post: Identifiable, Equatable, Hashable {
    public var id: Int
    public var userId: Int?
    public var userName: String?
    public var userImageUrl: URL?
    public var title: String?
    public var body: String?

    public init (
        id: Int,
        userId: Int?,
        userName: String?,
        userImageUrl: URL?,
        title: String?,
        body: String?
    ) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.userImageUrl = userImageUrl
        self.title = title
        self.body = body
    }
}
