//
//  PostMapper.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 14/08/22.
//

import Foundation

final class PostMapper {
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemotePost] {
        guard response.isOk, let posts = try? JSONDecoder().decode([RemotePost].self, from: data) else {
            throw RemotePostLoader.Error.invalidData
        }
        return posts
    }
}
