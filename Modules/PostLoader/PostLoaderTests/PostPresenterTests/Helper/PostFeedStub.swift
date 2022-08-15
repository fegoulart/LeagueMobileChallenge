//
//  PostFeedStub.swift
//  PostLoaderTests
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//

import Foundation
import PostLoader

public struct PostFeedStub {
    static let feed: [Post] = [
        Post(
            id: 73,
            userId: 8,
            userName: nil,
            userImageUrl: nil,
            title: "consequuntur deleniti eos quia temporibus ab aliquid at",
            body: """
            voluptatem cumque tenetur consequatur expedita ipsum nemo quia
explicabo\naut eum minima consequatur\ntempore cumque quae est et\net in consequuntur voluptatem voluptates aut
"""
        ),
        Post(
            id: 11,
            userId: 2,
            userName: nil,
            userImageUrl: nil,
            title: "et ea vero quia laudantium autem",
            body: """
delectus reiciendis molestiae occaecati non minima eveniet qui
voluptatibus\naccusamus in eum beatae sit\nvel qui neque voluptates ut commodi qui incidunt\nut animi commodi
"""
        ),
        Post(
            id: 7,
            userId: 69,
            userName: nil,
            userImageUrl: nil,
            title: "fugiat quod pariatur odit minima",
            body: """
officiis error culpa consequatur modi asperiores et\ndolorum assumenda voluptas
et vel qui aut vel rerum\nvoluptatum quisquam perspiciatis quia rerum consequatur
totam quas\nsequi commodi repudiandae asperiores et saepe a
"""
        )
    ]
}
