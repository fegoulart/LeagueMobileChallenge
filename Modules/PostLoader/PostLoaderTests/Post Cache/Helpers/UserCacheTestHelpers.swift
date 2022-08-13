//
//  UserCacheTestHelpers.swift
//  PostLoaderTests
//
//  Created by Fernando Luiz Goulart on 13/08/22.
//

import Foundation
import PostLoader

func uniqueUser() -> User {
    return User(id: 1, name: "John", imageUrl: anyURL())
}

func uniqueLocalUser() -> LocalUser {
    return LocalUser(id: 1, name: "John", imageUrl: anyURL(), cacheInsertionDate: nil)
}

extension Date {
    func minusUserCacheMaxAge() -> Date {
        return adding(days: -userCacheMaxAgeInDays)
    }

    private var userCacheMaxAgeInDays: Int {
        return 7
    }
}
