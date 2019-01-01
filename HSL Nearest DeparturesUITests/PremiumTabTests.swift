//
//  PremiumTabTests.swift
//  HSL Nearest DeparturesUITests
//
//  Created by Toni Suominen on 27/11/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import XCTest

class PremiumTabTests: XCTestCase {
    let TIMEOUT = 2.0
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_ShowsAdBanners() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST", "MOCKIAP"]
        app.launch()
        XCTAssert(app.otherElements["nearest stops ad banner"].waitForExistence(timeout: TIMEOUT))
        app.tables.cells.element(boundBy: 0).click()
        XCTAssert(app.otherElements["next departures ad banner"].waitForExistence(timeout: TIMEOUT))
        app.images["favoriteImage"].click()
        app.tabBars.buttons["Favourites"].tap()
        app.tables.cells.element(boundBy: 0).click()
        XCTAssert(app.otherElements["next departures ad banner"].waitForExistence(timeout: TIMEOUT))
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

    func test_PremiumVersionPurchase_HidesPremiumTabAndAds() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST", "MOCKIAP"]
        app.launch()
        XCTAssert(app.otherElements["nearest stops ad banner"].waitForExistence(timeout: TIMEOUT))
        app.tabBars.buttons["Premium"].tap()
        app.buttons["1.09€"].tap()
        checkAdsAreHidden(app: app)
    }

    func test_PremiumVersionRestore_HidesPremiumTabAndAds() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST", "MOCKIAP"]
        app.launch()
        XCTAssert(app.otherElements["nearest stops ad banner"].waitForExistence(timeout: TIMEOUT))
        app.tabBars.buttons["Premium"].tap()
        app.buttons["Restore Premium version"].tap()
        checkAdsAreHidden(app: app)
    }

    fileprivate func checkAdsAreHidden(app: XCUIApplication) {
        XCTAssert(app.otherElements["Nearest stops"].waitForExistence(timeout: TIMEOUT))
        XCTAssertEqual(app.tabBars.buttons.count, 3)
        XCTAssertFalse(app.otherElements["nearest stops ad banner"].waitForExistence(timeout: TIMEOUT))
        app.tables.cells.element(boundBy: 0).click()
        XCTAssertFalse(app.otherElements["next departures ad banner"].waitForExistence(timeout: TIMEOUT))
        app.images["favoriteImage"].click()
        app.tabBars.buttons["Favourites"].tap()
        app.tables.cells.element(boundBy: 0).click()
        XCTAssertFalse(app.otherElements["next departures ad banner"].waitForExistence(timeout: TIMEOUT))
    }

    func test_PremiumVersionPurchaseFails_DisplaysErrorAlert() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST", "MOCKIAP_TRANSACTION_FAILS"]
        app.launch()
        XCTAssert(app.otherElements["nearest stops ad banner"].waitForExistence(timeout: TIMEOUT))
        app.tabBars.buttons["Premium"].tap()
        app.buttons["Restore Premium version"].tap()
        checkTransactionFailed(app: app)
    }

    func test_PremiumVersionRestoreFails_DisplaysErrorAlert() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST", "MOCKIAP_TRANSACTION_FAILS"]
        app.launch()
        XCTAssert(app.otherElements["nearest stops ad banner"].waitForExistence(timeout: TIMEOUT))
        app.tabBars.buttons["Premium"].tap()
        app.buttons["1.09€"].tap()
        checkTransactionFailed(app: app)
    }

    fileprivate func checkTransactionFailed(app: XCUIApplication) {
        XCTAssert(app.otherElements["premium loading indicator"].waitForExistence(timeout: TIMEOUT))
        XCTAssert(app.alerts["Error"].waitForExistence(timeout: TIMEOUT))
        XCTAssert(app.staticTexts["Transaction failed"].waitForExistence(timeout: TIMEOUT))
        app.buttons["OK"].tap()
        XCTAssertFalse(app.otherElements["premium loading indicator"].waitForExistence(timeout: TIMEOUT))
        XCTAssertEqual(app.tabBars.buttons.count, 4)
    }

    func test_PremiumVersionProductRequestFails_DisplaysErrorAlert() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST", "MOCKIAP_PRODUCT_REQUEST_FAILS"]
        app.launch()
        app.tabBars.buttons["Premium"].tap()
        app.buttons["1.09€"].tap()
        XCTAssert(app.alerts["Error"].waitForExistence(timeout: TIMEOUT))
        XCTAssert(app.staticTexts["Purchase failed. Please try again later."].waitForExistence(timeout: TIMEOUT))
        app.buttons["OK"].tap()
        XCTAssertEqual(app.tabBars.buttons.count, 4)
    }

    func test_PremiumVersionProductRequestFails_RestoreDisplaysErrorAlert() {
        let app = XCUIApplication()
        app.launchArguments = ["UITEST", "MOCKIAP_PRODUCT_REQUEST_FAILS"]
        app.launch()
        app.tabBars.buttons["Premium"].tap()
        app.buttons["Restore Premium version"].tap()
        XCTAssert(app.alerts["Error"].waitForExistence(timeout: TIMEOUT))
        XCTAssert(app.staticTexts["Restore failed. Please try again later."].waitForExistence(timeout: TIMEOUT))
        app.buttons["OK"].tap()
        XCTAssertEqual(app.tabBars.buttons.count, 4)
    }
}
