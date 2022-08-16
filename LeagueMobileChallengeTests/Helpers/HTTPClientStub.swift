//
//  HTTPClientStub
//  LeagueMobileChallenge
//
//  Created by Fernando Luiz Goulart on 16/08/22.
//  Copyright © 2022 Kelvin Lau. All rights reserved.
//

import Foundation
import PostLoader

class HTTPClientStub: HTTPClient {

	private class Task: HTTPClientTask {
		func cancel() {}
	}

	private let stub: (URLRequest) -> HTTPClient.Result

	init(stub: @escaping (URLRequest) -> HTTPClient.Result) {
		self.stub = stub
	}

    func get(from request: URLRequest, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        completion(stub(request))
        return Task()
    }

    func get(from request: URLRequest) -> HTTPClient.Result {
        return stub(request)
    }

}

extension HTTPClientStub {
	static var offline: HTTPClientStub {
		HTTPClientStub(stub: { _ in .failure(NSError(domain: "offline", code: 0)) })
	}

	static func online(_ stub: @escaping (URLRequest) -> (Data, HTTPURLResponse)) -> HTTPClientStub {
		HTTPClientStub { urlRequest in .success(stub(urlRequest)) }
	}
}
