//
//  FavoriteStopsTests.swift
//  HSL Nearest DeparturesTests
//
//  Created by Toni Suominen on 21/10/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import XCTest
@testable import Lahimmat_Lahdot

fileprivate class MockHttp: HTTP {
    override func HTTPsendRequest(_ request: NSMutableURLRequest,
                                  callback: @escaping (String, String?) -> Void) -> Void {
        callback(testData, nil)
    }
}

class FavoriteStopsTests: XCTestCase {
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
}
