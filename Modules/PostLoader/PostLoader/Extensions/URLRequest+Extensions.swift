//
//  URLRequest+Extensions.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 15/08/22.
//

extension URLSession {

    func syncRequest(with url: URL) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        let dispatchGroup = DispatchGroup()
        let task = dataTask(with: url) {
            data = $0
            response = $1
            error = $2
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        task.resume()
        dispatchGroup.wait()

        return (data, response, error)
    }

    func syncRequest(with request: URLRequest) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        let dispatchGroup = DispatchGroup()
        let task = dataTask(with: request) {
            data = $0
            response = $1
            error = $2
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        task.resume()
        dispatchGroup.wait()

        return (data, response, error)
    }
}
