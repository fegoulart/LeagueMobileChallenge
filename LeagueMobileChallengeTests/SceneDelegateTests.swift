//
//  SceneDelegateTests.swift
//  LeagueMobileChallengeTests
//
//  Created by Fernando Luiz Goulart on 16/08/22.
//  Copyright © 2022 Kelvin Lau. All rights reserved.
//

import XCTest
import PostLoaderIOS
@testable import LeagueMobileChallenge

class SceneDelegateTests: XCTestCase {

    func test_configureWindow_setsWindowAsKeyAndVisible() {
        let window = UIWindow()
        let sut = SceneDelegate()
        sut.window = window

        sut.configureWindow()

        XCTAssertTrue(window.isKeyWindow, "Expected window to be the key window")
        XCTAssertFalse(window.isHidden, "Expected window to be visible")
    }

    func test_configureWindow_configuresRootViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()

        sut.configureWindow()

        let root = sut.window?.rootViewController
        let rootNavigation = root as? UINavigationController
        let topController = rootNavigation?.topViewController

        XCTAssertNotNil(
            rootNavigation,
            "Expected a navigation controller as root, got \(String(describing: root)) instead"
        )
        XCTAssertTrue(
            topController is PostViewController,
            "Expected a feed controller as top view controller, got \(String(describing: topController)) instead")
    }

}
