import XCTest

class HSL_Nearest_DeparturesUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["UITEST"]
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_ClickingFavoriteButton_AddsOrRemovesStopFromFavoriteList() {
        let app = XCUIApplication()
        let tabBarsQuery = app.tabBars
        let favoritesTab = tabBarsQuery.buttons["Suosikit"]
        let nearestTab = tabBarsQuery.buttons["Lähimmät"]

        favoritesTab.tap()
        XCTAssert(app.tables.children(matching: .cell).count == 0)

        nearestTab.tap()
        app.tables.cells.element(boundBy: 0).click()
        app.images["favoriteImage"].click()
        favoritesTab.tap()
        XCTAssert(app.tables.children(matching: .cell).count == 1)

        app.tables.cells.element(boundBy: 0).click()
        app.images["favoriteImage"].click()
        app.navigationBars.buttons["Suosikkipysäkkisi"].tap()
        XCTAssert(app.tables.children(matching: .cell).count == 0)
    }

    func test_AppStartup_ShowsNearestStops() {
        let app = XCUIApplication()
        XCTAssert(app.otherElements["Lähimmät pysäkkisi"].waitForExistence(timeout: 1000))
        XCTAssert(app.staticTexts["0815"].waitForExistence(timeout: 1000))
        XCTAssert(app.staticTexts["Viiskulma"].waitForExistence(timeout: 1000))
        XCTAssert(app.tables.cells.containing(.staticText, identifier:"Viiskulma").count == 4)
        XCTAssert(app.staticTexts["<50 m"].waitForExistence(timeout: 1000))
    }

    func test_StopMap_DisplaysStopPin() {
        let app = XCUIApplication()
        app.tables.cells.element(boundBy: 0).click()
        app.navigationBars.buttons.element(boundBy: 1).click()
        XCTAssert(app.otherElements["Map pin"].waitForExistence(timeout: 1000))
    }
}

extension XCUIElement {
    // A hack to prevent a random "Failure fetching attributes for element"
    // error when using XCUIElement.tap().
    func click() {
        sleep(2)
        if (self.waitForExistence(timeout: 1000)) {
            self.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
    }
}
