import XCTest
@testable import Lahimmat_Lahdot

class MockHttp: HTTP {
    override func HTTPsendRequest(_ request: NSMutableURLRequest,
                         callback: @escaping (String, String?) -> Void) -> Void {
        callback(testData, nil)
    }
}

class HSL_Nearest_DeparturesTests: XCTestCase {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()
        HSL.httpClient = MockHttp()
    }

    // Put teardown code here. This method is called after the invocation of each test method in the class.
    override func tearDown() {
        super.tearDown()
    }

    func test_stop_count() {
        let ex = self.expectation(description: "Returns correct amount of stops")

        HSL.sharedInstance.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops.count, 5)
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: 2.0)
    }

    func test_stop_name() {
        let ex = self.expectation(description: "Returns stop name")

        HSL.sharedInstance.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops[0].name, "Hovioikeus P")
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: 2.0)
    }

    func test_stop_platform() {
        let ex = self.expectation(description: "Adds platform to stop name if a platform code exists")

        HSL.sharedInstance.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops[1].name, "Hovioikeus, laituri 1")
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: 2.0)
    }

    func test_stop_distance() {
        let ex = self.expectation(description: "Returns stop distance")

        HSL.sharedInstance.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops[0].distance, "<50")
            XCTAssertEqual(stops[1].distance, "243")
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: 2.0)
    }

    func test_stop_coordinates() {
        let ex = self.expectation(description: "Returns stop coordinates")

        HSL.sharedInstance.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops[0].lat, 62.890498)
            XCTAssertEqual(stops[0].lon, 27.672156)
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: 2.0)
    }

    func test_stop_codes() {
        let ex = self.expectation(description: "Returns stop codes")

        HSL.sharedInstance.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops[0].codeLong, "MATKA:7_201312")
            XCTAssertEqual(stops[0].codeShort, "-")
            XCTAssertEqual(stops[1].codeShort, "10 161")
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: 2.0)
    }

    func test_departure_count() {
        let ex = self.expectation(description: "Returns correct amount of departures")

        HSL.sharedInstance.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops[0].departures.count, 5)
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: 2.0)
    }

    func test_departure_time() {
        let ex = self.expectation(description: "Returns departure time")

        HSL.sharedInstance.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops[0].departures[0].realDepartureTime, 31320)
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: 2.0)
    }

    func test_departure_time_format() {
        let ex = self.expectation(description: "Formats departure time correctly")

        let result1 = Tools.secondsFromMidnightToTime(60)
        XCTAssertEqual(result1, "00:01")

        let result2 = Tools.secondsFromMidnightToTime(46860)
        XCTAssertEqual(result2, "13:01")

        // 24h 1min
        let result3 = Tools.secondsFromMidnightToTime(86460)
        XCTAssertEqual(result3, "00:01")

        ex.fulfill()

        self.wait(for: [ex], timeout: 2.0)
    }
}
