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

    static let APIURL = "https://api.digitransit.fi/routing/v1/routers/hsl/index/graphql"

    private static let stopFields = "gtfsId, lat, lon, code, platformCode, desc, name"
    private static let departureFields = "scheduledDeparture, realtimeDeparture, departureDelay, realtime, realtimeState, serviceDay, pickupType, trip {tripHeadsign, directionId, route {shortName, longName, mode}}"

    static func departuresForStop(gtfsId: String, callback: (departures: [Departure]) -> Void) -> Void {
        let query = "{stop(id: \"\(gtfsId)\" ) { \(stopFields)" +
            ",stoptimesWithoutPatterns(numberOfDepartures: 30) {\(departureFields) }}}"
        HTTP.post(APIURL, body: query, callback: {(obj: [String: AnyObject], error: String?) in
            if let data = obj["data"] as? [String: AnyObject],
                let stop = data["stop"] as? [String: AnyObject],
                let nextDeparturesData = stop["stoptimesWithoutPatterns"] as? NSArray {
                callback(departures: parseDepartures(nextDeparturesData))
            }
        })
    }

    static func coordinatesForStop(stop: Stop, callback: (lat: Double, lon: Double) -> Void) -> Void {
        let query = "{stop(id: \"HSL:\(stop.codeLong)\" ) {lat, lon}}"
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
        let query = "{stopsByRadius(lat:\(String(lat)), lon: \(String(lon)), agency: \"HSL\", radius: 500)" +
            "{edges {node {distance, stop { \(stopFields)" +
                    ",stoptimesWithoutPatterns(numberOfDepartures: 30) {" +
                        departureFields +
                    "}}}}}}"
        HTTP.post(APIURL, body: query, callback: {(obj: [String: AnyObject], error: String?) in
            var stops: [Stop] = []
            if let data = obj["data"] as? [String: AnyObject],
                let stopsByRadius = data["stopsByRadius"] as? [String: AnyObject],
                let edges = stopsByRadius["edges"] as? NSArray {
                for edge in edges {
                    if let stopAtDistance = edge["node"] as? [String: AnyObject],
                        let distance = stopAtDistance["distance"] as? Int,
                        let stop = stopAtDistance["stop"] as? [String: AnyObject],
                        let name = stop["name"] as? String,
                        let code = stop["code"] as? String,
                        let lat = stop["lat"] as? Double,
                        let lon = stop["lon"] as? Double,
                        let gtfsId = stop["gtfsId"] as? String,
                        let nextDeparturesData = stop["stoptimesWithoutPatterns"] as? NSArray {
                        var stopName: String = name
                        if let platformCode = stop["platformCode"] as? String {
                            stopName = formatStopName(name, platformCode: platformCode)
                        }
                        stops.append(Stop(name: stopName, lat: lat, lon: lon, distance: formatDistance(distance), codeLong: trimAgency(gtfsId), codeShort: code, departures: parseDepartures(nextDeparturesData)))
                    }
                }
            }
            callback(stops: stops)
        })
    }

    static func nearestStops(lat: Double, lon: Double, callback: (stops: [Stop]) -> Void) {
        let query = "{stopsByRadius(lat:\(String(lat)), lon: \(String(lon)), agency: \"HSL\", radius: 500)" +
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
            let code = stop["code"] as? String,
            let lat = stop["lat"] as? Double,
            let lon = stop["lon"] as? Double,
            let gtfsId = stop["gtfsId"] as? String {
            var stopName: String = name
            if let platformCode = stop["platformCode"] as? String {
                stopName = formatStopName(name, platformCode: platformCode)
            }
            return Stop(name: stopName, lat: lat, lon: lon, distance: formatDistance(distance), codeLong: trimAgency(gtfsId), codeShort: code, departures: [])
        } else {
            return nil
        }
    }

    private static func formatDistance(distance: Int) -> String {
        return distance <= 50 ? "<50" : String(distance)
    }

    private static func formatStopName(name: String, platformCode: String?) -> String {
        return platformCode != nil ? "\(name), laituri \(platformCode!)" : name
    }

    private static func parseDepartures(departures: NSArray) -> [Departure] {
        var deps: [Departure] = []
        for dep in departures {
            if let scheduledDepartureTime = dep["scheduledDeparture"] as? Int,
                let realDepartureTime = dep["realtimeDeparture"] as? Int,
                let trip = dep["trip"] as AnyObject?,
                let destination = trip["tripHeadsign"] as? String,
                let pickupType = dep["pickupType"] as? String,
                let route = trip["route"] as AnyObject?,
                let codeShort = route["shortName"] as? String {
                if(pickupType != "NONE") {
                    deps.append(
                        Departure(
                            line: Line(codeLong: codeShort, codeShort: codeShort, destination: destination),
                            scheduledDepartureTime: scheduledDepartureTime,
                            realDepartureTime: realDepartureTime
                        )
                    )
                }
            }
        }
        return deps
    }

    private static func trimAgency(gtfsId: String) -> String {
        if let index = gtfsId.characters.indexOf(":") {
            let foo = gtfsId.substringFromIndex(index.successor())
            return foo
        }
        return gtfsId
    }
}