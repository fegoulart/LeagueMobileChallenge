//
//  UserImage.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 12/08/22.
//

 import Foundation

 public struct User: Identifiable, Equatable {
    public var id: Int
    public var name: String?
    public var imageUrl: URL?

    public init(
        id: Int,
        name: String?,
        imageUrl: URL?
    ) {
        self.id = id
        self.imageUrl = imageUrl
        self.name = name
    }
}
