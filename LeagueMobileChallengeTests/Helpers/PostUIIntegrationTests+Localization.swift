//
//  FeeeUIIntegrationTests+Localization
//  LeagueMobileChallenge
//
//  Created by Fernando Luiz Goulart on 16/08/22.
//  Copyright © 2022 Kelvin Lau. All rights reserved.
//

import Foundation
import XCTest
import PostLoader

extension PostUIIntegrationTests {
	func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
		let table = "Post"
		let bundle = Bundle(for: PostFeedPresenter.self)
		let value = bundle.localizedString(forKey: key, value: nil, table: table)
		if value == key {
			XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
		}
		return value
	}
}
