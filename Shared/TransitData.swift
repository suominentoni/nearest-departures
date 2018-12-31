//
//  HSLGraphQL.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 14/08/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import Foundation

enum TransitDataError: Error {
    case dataFetchingError(id: String, stop: Stop?)
    case favouriteStopsFetchingError
    case unknownError
}

let TransitData = _TransitData.sharedInstance

class _TransitData {
    static let sharedInstance = _TransitData(httpClient: _TransitData.httpClient)
    static var httpClient: HTTP = HTTP()

    fileprivate init(httpClient: HTTP) {
        _TransitData.httpClient = httpClient
    }

    func updateDeparturesForStops(_ stops: [Stop], callback: @escaping (_ stopsWithDepartures: [Stop], _ error: TransitDataError?) -> Void) -> Void {
        _TransitData.httpClient.post(Digitransit.apiUrl, body: Digitransit.Query.departuresForStops(stops: stops), callback: {(obj: [String: AnyObject], httpError: String?) -> Void in
            do {
                let updatedStops = try DigitransitResponseParser.parseStopsFromData(obj: obj)
                callback(updatedStops, nil)
            } catch {
                if let transitDataError = error as? TransitDataError {
                    callback(stops, transitDataError)
                } else {
                    callback(stops, nil)
                }
            }
        })
    }

    func departuresForStop(_ gtfsId: String, callback: @escaping (_ departures: [Departure]) -> Void) -> Void {
        _TransitData.httpClient.post(Digitransit.apiUrl, body: Digitransit.Query.departuresForStop(gtfsId: gtfsId), callback: {(obj: [String: AnyObject], httpError: String?) in
            callback(DigitransitResponseParser.parseDeparturesFromData(obj: obj))
        })
    }

    func coordinatesForStop(_ stop: Stop, callback: @escaping (_ lat: Double, _ lon: Double) -> Void) -> Void {
        _TransitData.httpClient.post(Digitransit.apiUrl, body: Digitransit.Query.coordinatesForStop(stop: stop), callback: {(obj: [String: AnyObject], httpError: String?) in
            let coordinate = DigitransitResponseParser.parseCoordinatesFromData(obj: obj)
            callback(coordinate.lat, coordinate.lon)
        })
    }

    fileprivate static let DEFAULT_RADIUS = 5000
    fileprivate static let DEFAULT_STOP_COUNT = 30
    fileprivate static let DEFAULT_DEPARTURE_COUNT = 30

    func nearestStopsAndDepartures(
        _ lat: Double,
        lon: Double,
        radius: Int = DEFAULT_RADIUS,
        stopCount: Int = DEFAULT_STOP_COUNT,
        departureCount: Int = DEFAULT_DEPARTURE_COUNT,
        callback: @escaping (_ stops: [Stop]) -> Void) {
        _TransitData.httpClient.post(
            Digitransit.apiUrl,
            body: Digitransit.Query.nearestStopsAndDepartures(lat: lat, lon: lon, radius: radius, stopCount: stopCount, departureCount: departureCount),
            callback: {(obj: [String: AnyObject], httpError: String?) in
                callback(DigitransitResponseParser.parseStopsAndDeparturesFromData(obj: obj))
            }
        )
    }

    func nearestStops(_ lat: Double, lon: Double, callback: @escaping (_ stops: [Stop]) -> Void) {
        _TransitData.httpClient.post(Digitransit.apiUrl, body: Digitransit.Query.nearestStops(lat: lat, lon: lon), callback: {(obj: [String: AnyObject], httpError: String?) in
            callback(DigitransitResponseParser.parseNearestStopsFromData(obj: obj))
        })
    }

    func stopsForRect(minLat: Double, minLon: Double, maxLat: Double, maxLon: Double, callback: @escaping (_ stops: [Stop]) -> Void) {
        _TransitData.httpClient.post(Digitransit.apiUrl, body: Digitransit.Query.stopsForRect(minLat: minLat, minLon: minLon, maxLat: maxLat, maxLon: maxLon), callback: {(obj: [String: AnyObject], httpError: String?) in
            callback(DigitransitResponseParser.parseRectStopsFromData(obj: obj))
        })
    }

    func stopsByCodes(codes: [String], callback: @escaping (_ stops: [Stop], _ error: TransitDataError?) -> Void) {
        let q = Digitransit.Query.stopsByCodes(codes: codes)
        print("FAV: query \(q)")
        _TransitData.httpClient.post(
            Digitransit.apiUrl,
            body: q,
            callback: {(obj: [String: AnyObject], httpError: String?) in
                print("FAV: response \(obj.debugDescription)")
                print("FAV: response error \(String(describing: httpError))")
                do {
                    let stops = try DigitransitResponseParser.parseStopsFromData(obj: obj)
                    print("FAV: parsed stops \(stops.debugDescription)")
                    callback(stops, nil)
                } catch {
                    print("FAV: failed parsing stops \(error.localizedDescription)")
                    if let transitDataError = error as? TransitDataError {
                        callback([], transitDataError)
                    } else {
                        callback([], nil)
                    }
                }
        })
    }
}
