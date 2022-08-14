//
//  RemoteBackendMapper.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 14/08/22.
//

import Foundation

public struct RemoteBackendMapper {
    public var map: (Data, HTTPURLResponse, Error) throws -> String

    public static var errorMessage = Self(
        map: { data, response, fallbackError in
            guard response.isOk,
                    let backendMessage = try? JSONDecoder().decode(RemoteErrorMessage.self, from: data) else {
                throw fallbackError
            }
            guard let message = backendMessage.message else {
                throw fallbackError
            }
            return message
        })
}
