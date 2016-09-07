//
//  HSLGraphQL.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 14/08/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import Foundation
import UIKit

public class HSL {

//    static let APIURL = "https://api.digitransit.fi/routing/v1/routers/hsl/index/graphql"
    static let APIURL = "https://api.digitransit.fi/routing/v1/routers/finland/index/graphql"
//    static let APIURL = "https://api.digitransit.fi/routing/v1/routers/waltti/index/graphql"

    private static let stopFields = "gtfsId, lat, lon, code, platformCode, desc, name"
    private static let departureFields = "scheduledDeparture, realtimeDeparture, departureDelay, realtime, realtimeState, serviceDay, pickupType, trip {tripHeadsign, directionId, route {shortName, longName, mode}}"

    static func departuresForStop(gtfsId: String, callback: (departures: [Departure]) -> Void) -> Void {
        let query = "{stop(id: \"\(gtfsId)\" ) { \(stopFields)" +
            ",stoptimesWithoutPatterns(numberOfDepartures: 30) {\(departureFields) }}}"
        HTTP.post(APIURL, body: query, callback: {(obj: [String: AnyObject], error: String?) in
            if let data = obj["data"] as? [String: AnyObject],
                let stop = data["stop"] as? [String: AnyObject] {
                callback(departures: parseDepartures(stop))
            }
        })
    }

    static func coordinatesForStop(stop: Stop, callback: (lat: Double, lon: Double) -> Void) -> Void {
        let query = "{stop(id: \"\(stop.codeLong)\" ) {lat, lon}}"
        HTTP.post(APIURL, body: query, callback: {(obj: [String: AnyObject], error: String?) in
            if let data = obj["data"] as? [String: AnyObject],
                let stop = data["stop"] as? [String: AnyObject],
                let lat = stop["lat"] as? Double,
                let lon = stop["lon"] as? Double {
                callback(lat: lat, lon: lon)
            }
        })
    }

    static func nearestStopsAndDepartures(lat: Double, lon: Double, callback: (stops: [Stop]) -> Void) {
//        let query = "{stopsByRadius(lat:\(String(lat)), lon: \(String(lon)), agency: \"HSL\", radius: 500)" +
        let query = "{stopsByRadius(lat:\(String(lat)), lon: \(String(lon)), radius: 500)" +
            "{edges {node {distance, stop { \(stopFields)" +
                    ",stoptimesWithoutPatterns(numberOfDepartures: 30) {" +
                        departureFields +
                    "}}}}}}"
        HTTP.post(APIURL, body: query, callback: {(obj: [String: AnyObject], error: String?) in
            var stops: [Stop?] = []
            if let data = obj["data"] as? [String: AnyObject],
                let stopsByRadius = data["stopsByRadius"] as? [String: AnyObject],
                let edges = stopsByRadius["edges"] as? NSArray {
                for edge in edges {
                    stops.append(parseStopAtDistance(edge))
                }
            }
            callback(stops: Tools.unwrapAndStripNils(stops))
        })
    }


    static func nearestStops(lat: Double, lon: Double, callback: (stops: [Stop]) -> Void) {
//        let query = "{stopsByRadius(lat:\(String(lat)), lon: \(String(lon)), agency: \"HSL\", radius: 500)" +
        let query = "{stopsByRadius(lat:\(String(lat)), lon: \(String(lon)), radius: 500)" +
            "{edges {node {distance, stop { \(stopFields) }}}}}"
        HTTP.post(APIURL, body: query, callback: {(obj: [String: AnyObject], error: String?) in
            var stops: [Stop?] = []
            if let data = obj["data"] as? [String: AnyObject],
                let stopsByRadius = data["stopsByRadius"] as? [String: AnyObject],
                let edges = stopsByRadius["edges"] as? NSArray {
                for edge in edges {
                    stops.append(parseStopAtDistance(edge))
                }
            }
            callback(stops: Tools.unwrapAndStripNils(stops))
        })
    }

    private static func parseStopAtDistance(data: AnyObject) -> Stop? {
        if let stopAtDistance = data["node"] as? [String: AnyObject],
            let distance = stopAtDistance["distance"] as? Int,
            let stop = stopAtDistance["stop"] as? [String: AnyObject],
            let name = stop["name"] as? String,
//            let code = stop["code"] as? String,
            let lat = stop["lat"] as? Double,
            let lon = stop["lon"] as? Double,
            let gtfsId = stop["gtfsId"] as? String {
            var stopName: String = name
            if let platformCode = stop["platformCode"] as? String {
                stopName = formatStopName(name, platformCode: platformCode)
            }
            let departures = parseDepartures(stop)

            return departures.count == 0
                ? nil
                : Stop(
                    name: stopName,
                    lat: lat,
                    lon: lon,
                    distance: formatDistance(distance),
                    codeLong: gtfsId,
                    codeShort: shortCodeForStop(stop),
                    departures: departures
            )
        } else {
            return nil
        }
    }

    private static func shortCodeForStop(stopData: [String: AnyObject]) -> String {
        // Some public transit operators (e.g. the one in Jyväskylä)
        // don't have a code field for their stops.
        if let shortCode = stopData["code"] as? String {
            return shortCode
        } else {
            return "-"
        }
    }

    private static func formatDistance(distance: Int) -> String {
        return distance <= 50 ? "<50" : String(distance)
    }

    private static func formatStopName(name: String, platformCode: String?) -> String {
        return platformCode != nil ? "\(name), laituri \(platformCode!)" : name
    }

    private static func trimAgency(gtfsId: String) -> String {
        if let index = gtfsId.characters.indexOf(":") {
            let foo = gtfsId.substringFromIndex(index.successor())
            return foo
        }
        return gtfsId
    }

    private static func parseDepartures(stopData: [String: AnyObject]) -> [Departure] {
        var deps: [Departure] = []
        if let nextDeparturesData = stopData["stoptimesWithoutPatterns"] as? NSArray {
            for dep in nextDeparturesData {
                if let scheduledDepartureTime = dep["scheduledDeparture"] as? Int,
                    let realDepartureTime = dep["realtimeDeparture"] as? Int,
                    let trip = dep["trip"] as AnyObject?,
                    let destination = trip["tripHeadsign"] as? String,
                    let pickupType = dep["pickupType"] as? String,
                    let route = trip["route"] as? [String: AnyObject] {
                    if(pickupType != "NONE") {
                        let code = shortCodeForRoute(route)
                        deps.append(
                            Departure(
                                line: Line(
                                    codeLong: code,
                                    codeShort: code,
                                    destination: destination
                                ),
                                scheduledDepartureTime: scheduledDepartureTime,
                                realDepartureTime: realDepartureTime
                            )
                        )
                    }
                }
            }
        }
        return deps
    }

    private static func shortCodeForRoute(routeData: [String: AnyObject]) -> String {
        if let mode = routeData["mode"] as? String where mode == "SUBWAY" {
            return "Metro"
        }
        return routeData["shortName"] as? String ?? "-"
    }
}