//
//  URLSessionHTTPClient.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 12/08/22.
//

public enum URLSessionError: Error {
    case unexpectedValuesRepresentation
    case couldNotInitializeUrlRequest
}

public class URLSessionHTTPClient: HTTPClient {

    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionTask

        func cancel() {
            wrapped.cancel()
        }
    }

    public static func request(
        url: URL,
        parameters: [String: String] = [:],
        headers: [String: String] = [:]
    ) throws -> URLRequest {
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

    @discardableResult
    public func get(
        from request: URLRequest,
        completion: @escaping (HTTPClient.Result) -> Void
    ) -> HTTPClientTask {

        let task = session.dataTask(with: request) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw URLSessionError.unexpectedValuesRepresentation
                }
            })
        }
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
}
