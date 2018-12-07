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

    func test_PremiumVersionPurchase_HidesPremiumTabAndAd() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST", "MOCKIAP"]
        app.launch()
        XCTAssert(app.otherElements["nearest stops ad banner"].waitForExistence(timeout: 10))
        app.tabBars.buttons["Premium"].tap()
        app.buttons["1.09€"].tap()
        XCTAssert(app.otherElements["Nearest stops"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.tabBars.buttons.count, 3)
        XCTAssertFalse(app.otherElements["nearest stops ad banner"].waitForExistence(timeout: 5))
    }

    func test_PremiumVersionRestore_HidesPremiumTabAndAd() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST", "MOCKIAP"]
        app.launch()
        XCTAssert(app.otherElements["nearest stops ad banner"].waitForExistence(timeout: 10))
        app.tabBars.buttons["Premium"].tap()
        app.buttons["Restore Premium version"].tap()
        XCTAssert(app.otherElements["Nearest stops"].waitForExistence(timeout: 10))
        XCTAssertEqual(app.tabBars.buttons.count, 3)
        XCTAssertFalse(app.otherElements["nearest stops ad banner"].waitForExistence(timeout: 5))
    }

    func test_PremiumVersionPurchaseFails_DisplaysErrorAlert() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST", "MOCKIAP_TRANSACTION_FAILS"]
        app.launch()
        XCTAssert(app.otherElements["nearest stops ad banner"].waitForExistence(timeout: 1000))
        app.tabBars.buttons["Premium"].tap()
        app.buttons["Restore Premium version"].tap()
        XCTAssert(app.otherElements["premium loading indicator"].waitForExistence(timeout: 10))
        XCTAssert(app.alerts["Error"].waitForExistence(timeout: 10))
        XCTAssert(app.staticTexts["Transaction failed"].waitForExistence(timeout: 10))
        app.buttons["OK"].tap()
        XCTAssertFalse(app.otherElements["premium loading indicator"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.tabBars.buttons.count, 4)
    }

    func test_PremiumVersionRestoreFails_DisplaysErrorAlert() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST", "MOCKIAP_TRANSACTION_FAILS"]
        app.launch()
        XCTAssert(app.otherElements["nearest stops ad banner"].waitForExistence(timeout: 1000))
        app.tabBars.buttons["Premium"].tap()
        app.buttons["1.09€"].tap()
        XCTAssert(app.otherElements["premium loading indicator"].waitForExistence(timeout: 10))
        XCTAssert(app.alerts["Error"].waitForExistence(timeout: 10))
        XCTAssert(app.staticTexts["Transaction failed"].waitForExistence(timeout: 10))
        app.buttons["OK"].tap()
        XCTAssertFalse(app.otherElements["premium loading indicator"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.tabBars.buttons.count, 4)
    }

    func test_PremiumVersionProductRequestFails_DisplaysErrorAlert() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST", "MOCKIAP_PRODUCT_REQUEST_FAILS"]
        app.launch()
        app.tabBars.buttons["Premium"].tap()
        app.buttons["1.09€"].tap()
        XCTAssert(app.alerts["Error"].waitForExistence(timeout: 10))
        XCTAssert(app.staticTexts["Purchase failed. Please try again later."].waitForExistence(timeout: 10))
        app.buttons["OK"].tap()
        XCTAssertEqual(app.tabBars.buttons.count, 4)
    }

    func test_PremiumVersionProductRequestFails_RestoreDisplaysErrorAlert() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST", "MOCKIAP_PRODUCT_REQUEST_FAILS"]
        app.launch()
        app.tabBars.buttons["Premium"].tap()
        app.buttons["Restore Premium version"].tap()
        XCTAssert(app.alerts["Error"].waitForExistence(timeout: 10))
        XCTAssert(app.staticTexts["Restore failed. Please try again later."].waitForExistence(timeout: 10))
        app.buttons["OK"].tap()
        XCTAssertEqual(app.tabBars.buttons.count, 4)
    }
}
