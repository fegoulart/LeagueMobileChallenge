//
//  URL+Extensions.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 12/08/22.
//

import Foundation

extension String {
    public func toURLRequest(
        parameters: [String: String] = [:],
        headers: [String: String] = [:]
    ) throws -> URLRequest {
        guard let url: URL = URL(string: self) else {
            throw URLSessionError.invalidURL
        }

        guard
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw URLSessionError.couldNotInitializeUrlRequest
        }

        if !parameters.isEmpty {
            components.queryItems = parameters.map { (key, value) in
                URLQueryItem(name: key, value: value)
            }
            let percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
            components.percentEncodedQuery = percentEncodedQuery
        }

        guard let componentsURL = components.url else { throw URLSessionError.couldNotInitializeUrlRequest }

        var request = URLRequest(url: componentsURL)

        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }

        return request
    }

    public var authHeader: [String: String] {
        return ["x-access-token": self]
    }
}
