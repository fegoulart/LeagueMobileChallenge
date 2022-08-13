//
//  LocalUser.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 12/08/22.
//

import Foundation

public struct LocalUser: Identifiable, Equatable {
    public var id: Int
    public var name: String?
    public var imageUrl: URL?
    public var cacheInsertionDate: Date?

    public init(
        id: Int,
        name: String?,
        imageUrl: URL?,
        cacheInsertionDate: Date?
    ) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.cacheInsertionDate = cacheInsertionDate
    }
}
