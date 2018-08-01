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
            XCTAssertEqual(stops[1].distance, "60")
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
            XCTAssertEqual(stops[0].codeShort, "1641")
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
            XCTAssertEqual(stops[0].departures.destinations(), "Neulamäki P")
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: timeout)
    }

    func test_error_on_invalid_departures_update() {
        let ex = self.expectation(description: "Returns departure information")
        let invalidStop = Stop(name: "invalid stop", lat: 0.0, lon: 0.0, distance: "0", codeLong: "invalid long code", codeShort: "invalid short code", departures: [])
        HSL.sharedInstance.updateDeparturesForStops([invalidStop], callback: {stops, error in
            XCTAssertEqual(stops, [Optional(invalidStop)])
            XCTAssertEqual(error!.localizedDescription, "The operation couldn’t be completed. (Lahimmat_Lahdot.TransitDataError error 0.)")
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: timeout)
    }

    func test_coordinates_for_stop() {
        let ex = self.expectation(description: "Returns departure information")
        let stop = Stop(name: "Hovioikeus", lat: 0.0, lon: 0.0, distance: "", codeLong: "MATKA:201312", codeShort: "10 161", departures: [])
        HSL.sharedInstance.coordinatesForStop(stop, callback: {lat, lon in
            XCTAssertEqual(lat, 62.890472)
            XCTAssertEqual(lon, 27.672057)
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: timeout)
    }

    func test_departures_for_stop() {
        let ex = self.expectation(description: "Returns departure information")
        HSL.sharedInstance.departuresForStop("MATKA:7_201834", callback: {departures in
            XCTAssertEqual(departures[0].line.destination!, "Touvitie")
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: timeout)
    }

    func test_stops_for_rect() {
        let ex = self.expectation(description: "Returns departure information")
        HSL.sharedInstance.stopsForRect(minLat: 62.913798, minLon: 27.703546, maxLat: 62.914209, maxLon: 27.704254, callback: {stops in
            XCTAssertEqual(stops.count, 2)
            XCTAssertEqual(stops[0].name, "Tuhtotie L")
            XCTAssertEqual(stops[1].name, "Tuhtotie I")
            ex.fulfill()
        })
        self.wait(for: [ex], timeout: timeout)
    }

    func test_unwrapAndStripNils() {
        let ex = self.expectation(description: "Returns departure information")
        let stop1: Stop? = Stop(name: "foo", lat: 0, lon: 0, distance: "1", codeLong: "", codeShort: "", departures: [])
        let stop2: Stop? = Stop(name: "bar", lat: 0, lon: 0, distance: "1", codeLong: "", codeShort: "", departures: [])
        let nilStop: Stop? = nil
        let stops = [stop1, stop2, nilStop]
        let expected = [stop1!, stop2!]
        XCTAssertEqual(stops.unwrapAndStripNils(), expected)
        ex.fulfill()
        self.wait(for: [ex], timeout: timeout)
    }
}
