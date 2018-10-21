//
//  DataFetchErrorUITests.swift
//  HSL Nearest DeparturesUITests
//
//  Created by Toni Suominen on 21/10/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import XCTest

class DataFetchErrorUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["UITEST"]
        app.launchArguments = ["UITEST_ERRONEOUSDATA"]
        app.launch()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_FavoriteStopsWithExpiredStop_DisplaysAlert() {
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        let favoritesTab = tabBarsQuery.buttons["Favourites"]
        favoritesTab.tap()
        XCTAssert(app.alerts["Data fetch error"].waitForExistence(timeout: 1000))
    }
}
