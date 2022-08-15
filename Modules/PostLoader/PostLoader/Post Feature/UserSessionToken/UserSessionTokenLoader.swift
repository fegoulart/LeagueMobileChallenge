//
//  UserTokenLoader.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 14/08/22.
//

import Foundation

public protocol UserSessionTokenLoader {

    func load() -> String?
}
