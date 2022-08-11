//
//  URLProtocolStub.swift
//  PostLoaderTests
//
//  Created by Fernando Luiz Goulart on 11/08/22.
//

import Foundation

/*
class URLProtocolStub: URLProtocol {
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        let requestObserver: ((URLRequest) -> Void)?
    }

    private static var _stub: Stub?
    private static var stub: Stub? {
        get { return queue.sync { _stub } }
        set { queue.sync { _stub = newValue } }
    }

    private static let queue = DispatchQueue(label: "URLProtocolStub.queue")

    static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub(data: data, response: response, error: error, requestObserver: nil)
    }

    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
        stub = Stub(data: nil, response: nil, error: nil, requestObserver: observer)
    }

    static func removeStub() {
        stub = nil
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let stub = URLProtocolStub.stub else { return }

        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }

        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }

        stub.requestObserver?(request)
    }

    override func stopLoading() {}
}
 */

class URLProtocolStub: URLProtocol {
    private static var stub: Stub?
    private static var requestObserver: ((URLRequest) -> Void)?

    // swiftlint:disable nesting
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: NSError?
    }
    // swiftlint:enable nesting

    static func stub(data: Data?, response: URLResponse?, error: NSError?) {
        stub = Stub(data: data, response: response, error: error)
    }

    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
        requestObserver = observer
    }

    static func startInterceptingRequests() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }

    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        stub = nil
        requestObserver = nil
    }

    override class func canInit(with request: URLRequest) -> Bool {
        requestObserver?(request)
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        if let data = URLProtocolStub.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }

        if let response = URLProtocolStub.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let error = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
