//
//  HTTPURLResponse+StatusCode.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 12/08/22.
//

import Foundation

extension HTTPURLResponse {
    private static var OK200: Int { return 200 }

    var isOk: Bool {
        return statusCode == HTTPURLResponse.OK200
    }
}
