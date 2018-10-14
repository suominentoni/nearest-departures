import XCTest
@testable import Lahimmat_Lahdot

class MockHttp: HTTP {
    override func HTTPsendRequest(_ request: NSMutableURLRequest,
                         callback: @escaping (String, String?) -> Void) -> Void {
        callback(testData, nil)
    }
}

class TransitDataTestsMockData: XCTestCase {
    override func setUp() {
        super.setUp()
        _TransitData.httpClient = MockHttp()
        emptyUserDefaults()
    }

    fileprivate func emptyUserDefaults() {
        let appDomain = Bundle.main.bundleIdentifier
        UserDefaults.standard.removePersistentDomain(forName: appDomain!)
    }

    fileprivate let stop1 = Stop(name: "Test stop 1", lat: 1.00, lon: 2.00, distance: "10", codeLong: "12345", codeShort: "123", departures: [])
    fileprivate let stop2 = Stop(name: "Test stop 2", lat: 1.00, lon: 2.00, distance: "10", codeLong: "abcde", codeShort: "abc", departures: [])

    func test_favourite_stop_add() {
        FavoriteStops.add(stop1)
        FavoriteStops.add(stop2)
        let stops = try! FavoriteStops.all()
        XCTAssertEqual(stops.count, 2)
        XCTAssert(stops[0] == stop1)
        XCTAssert(stops[1] == stop2)
    }

    func test_favourite_stop_remove() {
        FavoriteStops.add(stop1)
        FavoriteStops.add(stop2)
        FavoriteStops.remove(stop1)
        let stops = try! FavoriteStops.all()
        XCTAssertEqual(stops.count, 1)
        XCTAssert(stops[0] == stop2)
    }

    func test_favourite_stop_get_by_code() {
        FavoriteStops.add(stop1)
        FavoriteStops.add(stop2)
        XCTAssert(FavoriteStops.getBy("invalid code") == nil)
        XCTAssert(FavoriteStops.getBy("abcde")! == stop2)
    }

    func test_favourite_stop_is_favourite() {
        FavoriteStops.add(stop1)
        XCTAssertTrue(FavoriteStops.isFavoriteStop(stop1))
        XCTAssertFalse(FavoriteStops.isFavoriteStop(stop2))
    }

    func test_favourite_stop_try_update() {
        FavoriteStops.add(stop1)
        stop1.name = "New stop name"
        FavoriteStops.tryUpdate(stop1)
        let stops = try! FavoriteStops.all()
        XCTAssertEqual(stops[0].name, "New stop name")
    }

    func test_favourite_stop_migrateToAgencyPrefixedCodeFormat() {
        FavoriteStops.add(stop1)
        FavoriteStops.migrateToAgencyPrefixedCodeFormat()
        let stops = try! FavoriteStops.all()
        XCTAssertEqual(stops[0].codeLong, "HSL:12345")
    }

    func test_stop_count() {
        let ex = self.expectation(description: "Returns correct amount of stops")

        TransitData.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops.count, 5)
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: 2.0)
    }

    func test_stop_name() {
        let ex = self.expectation(description: "Returns stop name")

        TransitData.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops[0].name, "Hovioikeus P")
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: 2.0)
    }

    func test_stop_platform() {
        let ex = self.expectation(description: "Adds platform to stop name if a platform code exists")

        TransitData.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops[1].name, "Hovioikeus, laituri 1")
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: 2.0)
    }

    func test_stop_distance() {
        let ex = self.expectation(description: "Returns stop distance")

        TransitData.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops[0].distance, "<50")
            XCTAssertEqual(stops[1].distance, "243")
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: 2.0)
    }

    func test_stop_coordinates() {
        let ex = self.expectation(description: "Returns stop coordinates")

        TransitData.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops[0].lat, 62.890498)
            XCTAssertEqual(stops[0].lon, 27.672156)
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: 2.0)
    }

    func test_stop_codes() {
        let ex = self.expectation(description: "Returns stop codes")

        TransitData.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops[0].codeLong, "MATKA:7_201312")
            XCTAssertEqual(stops[0].codeShort, "-")
            XCTAssertEqual(stops[1].codeShort, "10 161")
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: 2.0)
    }

    func test_departure_count() {
        let ex = self.expectation(description: "Returns correct amount of departures")

        TransitData.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops[0].departures.count, 5)
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: 2.0)
    }

    func test_departure_time() {
        let ex = self.expectation(description: "Returns departure time")

        TransitData.nearestStopsAndDepartures(0, lon: 0, callback: {stops in
            XCTAssertEqual(stops[0].departures[0].realDepartureTime, 31320)
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: 2.0)
    }

    func test_departure_time_format() {
        let ex = self.expectation(description: "Formats departure time correctly")

        let result1 = DepartureTime(60)
        XCTAssertEqual(result1.toTime(), "00:01")

        let result2 = DepartureTime(46860)
        XCTAssertEqual(result2.toTime(), "13:01")

        // 24h 1min
        let result3 = DepartureTime(86460)
        XCTAssertEqual(result3.toTime(), "00:01")

        ex.fulfill()

        self.wait(for: [ex], timeout: 2.0)
    }
}
