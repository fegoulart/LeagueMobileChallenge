//
//  UserImage.swift
//  PostLoader
//
//  Created by Fernando Luiz Goulart on 12/08/22.
//

import Foundation
import CoreLocation

public struct User: Identifiable {
    public var id: Int
    public var name: String?
    public var email: String?
    public var imageUrl: String?
    public var username: String?
    public var address: UserAddress?
    public var phone: String?
    public var website: String?
    public var company: Company?

    public init(
        id: Int,
        name: String?,
        email: String?,
        imageUrl: String?,
        username: String?,
        address: UserAddress?,
        phone: String?,
        website: String?,
        company: Company?
    ) {
        self.id = id
        self.imageUrl = imageUrl
        self.username = username
        self.address = address
        self.phone = phone
        self.website = website
        self.company = company
    }
}

public struct UserAddress {
    public var street: String?
    public var suite: String?
    public var city: String?
    public var zip: String?
    public var geo: CLLocation?

    public init(street: String?, suite: String?, city: String?, zip: String?, geo: CLLocation?) {
        self.street = street
        self.suite = suite
        self.city = city
        self.zip = zip
        self.geo = geo
    }
}

public struct Company {
    public var name: String?
    public var catchPrase: String?
    public var bsTags: String?

    public init(name: String?, catchPhrase: String?, bsTags: String?) {
        self.name = name
        self.catchPrase = catchPhrase
        self.bsTags = bsTags
    }
}
