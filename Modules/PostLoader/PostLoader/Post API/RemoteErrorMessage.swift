//
//  ErrorMessage.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 14/08/22.
//

import Foundation

public struct RemoteErrorMessage: Decodable {
    public var message: String?

    public init(message: String?) {
        self.message = message
    }
}
