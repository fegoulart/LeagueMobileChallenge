//
//  URL+Extensions.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 14/08/22.
//

import Foundation

extension URL {
    public func toURLRequest(
        headers: [String: String] = [:]
    ) throws -> URLRequest {

        var request = URLRequest(url: self)

        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }

        return request
    }
}
