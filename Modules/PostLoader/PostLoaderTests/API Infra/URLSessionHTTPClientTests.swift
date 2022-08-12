//
//  URLSessionHTTPClientTests.swift
//  PostLoaderTests
//
//  Created by Fernando Luiz Goulart on 11/08/22.
//

import XCTest
import PostLoader

final class URLSessionHTTPClientTests: XCTestCase {

    override func setUp() {
        super.setUp()

    }

    override func tearDown() {
        super.tearDown()

        URLProtocolStub.removeStub()
    }

    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()

        // swiftlint:disable:next force_try
        let urlRequest = try! URLSessionHTTPClient.request(url: anyURL())
        let exp = expectation(description: "Wait for request")

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }

        makeSUT().get(from: urlRequest) { _ in }
        wait(for: [exp], timeout: 1.0)
    }

    func test_getWithParametersAndHeader_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for request")
        let parameters = ["user": "1"]
        let headers = ["x-access-token": "872C86119EBD18178526C0A687DFE495"]
        let stringUrl: String? = "\(anyURL())?user=1"
        // swiftlint:disable:next force_try
        let urlRequest = try! URLSessionHTTPClient.request(url: url, parameters: parameters, headers: headers)

        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.allHTTPHeaderFields, headers)
            XCTAssertEqual(request.url?.absoluteString, stringUrl)
            exp.fulfill()
        }

        makeSUT().get(from: urlRequest) { _ in }

        wait(for: [exp], timeout: 1.0)
    }

    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError()

        let receivedError = resultErrorFor(data: nil, parameters: nil, headers: nil, response: nil, error: requestError)

        XCTAssertEqual((receivedError as NSError?)?.domain, requestError.domain)
    }

    // swiftlint:disable:next function_body_length
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor(
            data: nil,
            parameters: nil,
            headers: nil,
            response: nil,
            error: nil)
        )
        XCTAssertNotNil(resultErrorFor(
            data: nil,
            parameters: nil,
            headers: nil,
            response: nonHTTPURLResponse(),
            error: nil)
        )
        XCTAssertNotNil(resultErrorFor(
            data: anyData(),
            parameters: nil,
            headers: nil,
            response: nil, error: nil)
        )
        XCTAssertNotNil(resultErrorFor(
            data: anyData(),
            parameters: nil,
            headers: nil,
            response: nil,
            error: anyNSError())
        )
        XCTAssertNotNil(resultErrorFor(
            data: nil,
            parameters: nil,
            headers: nil,
            response: nonHTTPURLResponse(),
            error: anyNSError())
        )
        XCTAssertNotNil(resultErrorFor(
            data: nil,
            parameters: nil,
            headers: nil,
            response: anyHTTPURLResponse(),
            error: anyNSError())
        )
        XCTAssertNotNil(resultErrorFor(
            data: anyData(),
            parameters: nil,
            headers: nil,
            response: nonHTTPURLResponse(),
            error: anyNSError())
        )
        XCTAssertNotNil(resultErrorFor(
            data: anyData(),
            parameters: nil,
            headers: nil,
            response: anyHTTPURLResponse(),
            error: anyNSError())
        )
        XCTAssertNotNil(resultErrorFor(
            data: anyData(),
            parameters: nil,
            headers: nil,
            response: nonHTTPURLResponse(),
            error: nil)
        )
    }

    func test_cancelGetFromURLTask_cancelsURLRequest() {

        let receivedError = resultErrorFor(
            data: nil,
            parameters: nil,
            headers: nil,
            response: nil,
            error: nil) {
                $0?.cancel()
            } as NSError?

        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }

    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()

        let receivedValues = resultValuesFor(
            data: data,
            parameters: nil,
            headers: nil,
            response: response,
            error: nil
        )

        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }

    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()

        let receivedValues = resultValuesFor(
            data: nil,
            parameters: nil,
            headers: nil,
            response: response,
            error: nil
        )
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }

    //    // MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)

        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func resultValuesFor(
        data: Data?,
        parameters: [String: String]?,
        headers: [String: String]?,
        response: URLResponse?,
        error: NSError?,
        file: StaticString = #file,
        line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
            let result = resultFor(data: data,
                                   parameters: parameters,
                                   headers: headers,
                                   response: response,
                                   error: error,
                                   file: file,
                                   line: line)

            switch result {
            case let .success((data, response)):
                return (data, response)
            default:
                XCTFail("Expected success, got \(result) instead", file: file, line: line)
                return nil
            }
        }

    private func resultErrorFor(
        data: Data?,
        parameters: [String: String]?,
        headers: [String: String]?,
        response: URLResponse?,
        error: NSError?,
        taskHandler: (HTTPClientTask?) -> Void = { _ in },
        file: StaticString = #file,
        line: UInt = #line) -> Error? {
            let result = resultFor(data: data,
                                   parameters: parameters,
                                   headers: headers,
                                   response: response,
                                   error: error,
                                   taskHandler: taskHandler,
                                   file: file,
                                   line: line)

            switch result {
            case let .failure(error):
                return error as NSError
            default:
                XCTFail("Expected failure, got \(result) instead", file: file, line: line)
                return nil
            }
        }

    private func resultFor(data: Data?,
                           parameters: [String: String]?,
                           headers: [String: String]?,
                           response: URLResponse?,
                           error: NSError?,
                           taskHandler: (HTTPClientTask?) -> Void = { _ in },
                           file: StaticString = #file,
                           line: UInt = #line) -> HTTPClient.Result {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")

        // swiftlint:disable:next force_try
        let urlRequest = try! URLSessionHTTPClient.request(
            url: anyURL(),
            parameters: parameters ?? [:],
            headers: headers ?? [:]
        )

        var receivedResult: HTTPClient.Result!
        taskHandler(sut.get(from: urlRequest) { result in
            receivedResult = result
            exp.fulfill()
        })

        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }

    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
}
