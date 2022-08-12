//
//  HTTPClient.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 12/08/22.
//

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func get(
        from request: URLRequest,
        completion: @escaping (Result) -> Void
    ) -> HTTPClientTask
}
