//
//  PremiumTabTests.swift
//  HSL Nearest DeparturesUITests
//
//  Created by Toni Suominen on 27/11/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import XCTest

class PremiumTabTests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_HasBoughtPremium_DoesNotDisplayPremiumTab() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST"]
        app.launchArguments = ["HAS_BOUGHT_PREMIUM"]
        app.launch()
        XCTAssertEqual(app.tabBars.buttons.count, 3)
    }

    func test_HasNotBoughtPremium_DisplaysPremiumTab() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST"]
        app.launch()
        XCTAssertEqual(app.tabBars.buttons.count, 4)
    }

    func test_AttemptToBuyPremium_DisplaysErrorInSimulation() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST"]
        app.launch()
        app.tabBars.buttons["Premium"].tap()
        app.buttons["1.09€"].tap()
        // In-app purchases are not possible in simulation
        // Todo: mock the IAP API
        XCTAssert(app.staticTexts["Cannot connect to iTunes Store"].waitForExistence(timeout: 10))
    }
}
