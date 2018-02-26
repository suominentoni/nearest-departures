//
//  Nearest_Departures_API_Tests.swift
//  HSL Nearest DeparturesTests
//
//  Created by Toni Suominen on 24/02/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import XCTest
@testable import Lahimmat_Lahdot

class TransitDataTests: XCTestCase {
    let lat = 62.914898
    let lon = 27.707004
    let timeout = 10.0

    override func setUp() {
        super.setUp()
        HSL.httpClient = HTTP()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_stop_count() {
        let ex = self.expectation(description: "Returns correct amount of stops")

        HSL.sharedInstance.nearestStopsAndDepartures(lat, lon: lon, callback: {stops in
            XCTAssertEqual(stops.count, 29) // Note: API sometimes seems to return 24 stops instead of 29
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: timeout)
    }

    func test_stop_name() {
        let ex = self.expectation(description: "Returns stop name")

        HSL.sharedInstance.nearestStopsAndDepartures(lat, lon: lon, callback: {stops in
            XCTAssertEqual(stops[0].name, "Ankkuritie E")
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: timeout)
    }

    func test_stop_distance() {
        let ex = self.expectation(description: "Returns stop distance")

        HSL.sharedInstance.nearestStopsAndDepartures(lat, lon: lon, callback: {stops in
            XCTAssertEqual(stops[0].distance, "<50")
            XCTAssertEqual(stops[1].distance, "61")
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: timeout)
    }

    func test_stop_coordinates() {
        let ex = self.expectation(description: "Returns stop coordinates")

        HSL.sharedInstance.nearestStopsAndDepartures(lat, lon: lon, callback: {stops in
            XCTAssertEqual(stops[0].lat, 62.914877)
            XCTAssertEqual(stops[0].lon, 27.706835)
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: timeout)
    }

    func test_stop_codes() {
        let ex = self.expectation(description: "Returns stop codes")

        HSL.sharedInstance.nearestStopsAndDepartures(lat, lon: lon, callback: {stops in
            XCTAssertEqual(stops[0].codeLong, "MATKA:7_201269")
            XCTAssertEqual(stops[0].codeShort, "-")
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: timeout)
    }

    func test_departure_count() {
        let ex = self.expectation(description: "Returns correct amount of departures")

        HSL.sharedInstance.nearestStopsAndDepartures(lat, lon: lon, callback: {stops in
            XCTAssertEqual(stops[0].departures.count, 30)
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: timeout)
    }

    func test_departure_information() {
        let ex = self.expectation(description: "Returns departure information")

        HSL.sharedInstance.nearestStopsAndDepartures(lat, lon: lon, callback: {stops in
            XCTAssertEqual(stops[0].departures[0].line.destination, "Neulamäki P")
            XCTAssertEqual(stops[0].departures[0].line.codeShort, "4")
            XCTAssertEqual(stops[0].departures.destinations(), "Neulamäki P, Microteknia E")
            ex.fulfill()
        })

        self.wait(for: [ex], timeout: timeout)
    }
}
