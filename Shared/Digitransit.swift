//
//  Query.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 14/10/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import Foundation

struct Digitransit {
    static let apiUrl = "https://api.digitransit.fi/routing/v1/routers/finland/index/graphql"

    struct Query {
        static fileprivate let stopFields = "gtfsId, lat, lon, code, platformCode, desc, name"
        static fileprivate let departureFields = "scheduledDeparture, realtimeDeparture, departureDelay, realtime, realtimeState, serviceDay, pickupType, trip {tripHeadsign, directionId, route {shortName, longName, mode}}"

        static func departuresForStop(gtfsId: String) -> String {
            return "{stop(id: \"\(gtfsId)\" ) { \(stopFields), stoptimesWithoutPatterns(numberOfDepartures: 30) {\(departureFields) }}}"
        }

        static func departuresForStops(stops: [Stop]) -> String {
            let idsCommaSeparated = stops.reduce("", {(result, stop) in
                return result + "\"" + stop.codeLong + "\","
            })
            return "{stops(ids: [\(idsCommaSeparated)] ) { \(stopFields), stoptimesWithoutPatterns(numberOfDepartures: 30) {\(departureFields) }}}"
        }

        static func coordinatesForStop(stop: Stop) -> String {
            return "{stop(id: \"\(stop.codeLong)\" ) {lat, lon}}"
        }

        static func nearestStopsAndDepartures(
            lat: Double,
            lon: Double,
            radius: Int,
            stopCount: Int,
            departureCount: Int) -> String {
            return "{stopsByRadius(lat:\(String(lat)), lon: \(String(lon)), radius: \(radius), first: \(stopCount))" +
                "{edges {node {distance, stop { \(stopFields)" +
                ",stoptimesWithoutPatterns(numberOfDepartures: \(departureCount)) {" +
                departureFields + "}}}}}}"
        }

        static func nearestStops(lat: Double, lon: Double) -> String {
            return "{stopsByRadius(lat:\(String(lat)), lon: \(String(lon)), radius: 5000, first: 30)" +
            "{edges {node {distance, stop { \(stopFields) }}}}}"
        }

        static func stopsForRect(minLat: Double, minLon: Double, maxLat: Double, maxLon: Double) -> String {
            return "{stopsByBbox(minLat:\(minLat), minLon:\(minLon), maxLat:\(maxLat), maxLon:\(maxLon)) { \(stopFields), stoptimesWithoutPatterns(numberOfDepartures: 1) { \(departureFields) }}}"
        }

        static func stopsByCodes(codes: [String]) -> String {
            return "{stops(ids: \(codes)){" +
                    "gtfsId, lat, lon, code, platformCode, desc, name," +
                    "stoptimesWithoutPatterns(numberOfDepartures: 30) {" +
                        "scheduledDeparture, realtimeDeparture, departureDelay, realtime, realtimeState, serviceDay, pickupType," +
                "trip {tripHeadsign, directionId, route {shortName, longName, mode}}}}}"
        }
    }
}
