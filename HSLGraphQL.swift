//
//  HSLGraphQL.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 14/08/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import Foundation

public class HSL {

    static let url = "https://api.digitransit.fi/routing/v1/routers/hsl/index/graphql"

    static func departuresForStop(gtfsId: String, callback: (departures: [Departure]) -> Void) -> Void {
        let query = "{stop(id: \"\(gtfsId)\" ) {" +
            "gtfsId, code, platformCode, desc, name," +
            "stoptimesWithoutPatterns(numberOfDepartures: 20) {" +
                "scheduledDeparture," +
                "realtimeDeparture," +
                "departureDelay," +
                "realtime," +
                "realtimeState," +
                "serviceDay," +
                "pickupType," +
                "trip {" +
                    "tripHeadsign," +
                    "directionId," +
                    "route {" +
                        "shortName," +
                        "longName," +
                        "mode" +
                    "}}}}}"
        HTTP.post(url, body: query, callback: {(obj: [String: AnyObject], error: String?) in
            if let data = obj["data"] as? [String: AnyObject],
                let stop = data["stop"] as? [String: AnyObject],
                let nextDeparturesData = stop["stoptimesWithoutPatterns"] as? NSArray {
                callback(departures: parseDepartures(nextDeparturesData))
            }

        })
    }

    static func nearestStopsAndDepartures(lat: Double, lon: Double, callback: (stops: [Stop]) -> Void) {
        let query = "{stopsByRadius(lat:\(String(lat)), lon: \(String(lon)), agency: \"HSL\", radius: 500)" +
            "{edges {node" +
                "{distance," +
                "stop {" +
                    "gtfsId, code, platformCode, desc, name," +
                    "stoptimesWithoutPatterns(numberOfDepartures: 20) {" +
                        "scheduledDeparture," +
                        "realtimeDeparture," +
                        "departureDelay," +
                        "realtime," +
                        "realtimeState," +
                        "serviceDay," +
                        "pickupType," +
                        "trip {" +
                            "tripHeadsign," +
                            "directionId," +
                            "route {" +
                                "shortName," +
                                "longName," +
                                "mode" +
                            "}}}}}}}}"
        HTTP.post(url, body: query, callback: {(obj: [String: AnyObject], error: String?) in
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
                        let gtfsId = stop["gtfsId"] as? String,
                        let nextDeparturesData = stop["stoptimesWithoutPatterns"] as? NSArray {
                        var stopName: String = name
                        if let platformCode = stop["platformCode"] as? String {
                            stopName = formatStopName(name, platformCode: platformCode)
                        }
                        stops.append(Stop(name: stopName , distance: String(distance), codeLong: trimAgency(gtfsId), codeShort: code, departures: parseDepartures(nextDeparturesData)))
                    }
                }
            }
            callback(stops: stops)
        })
    }

    static func nearestStops(lat: Double, lon: Double, callback: (stops: [Stop]) -> Void) {
        let query = "{stopsByRadius(lat:\(String(lat)), lon: \(String(lon)), agency: \"HSL\", radius: 500)" +
            "{edges {node {distance, stop {" +
                "gtfsId, code, platformCode, desc, name," +
            "}}}}}"
        HTTP.post(url, body: query, callback: {(obj: [String: AnyObject], error: String?) in
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
                        let gtfsId = stop["gtfsId"] as? String {
                        var stopName: String = name
                        if let platformCode = stop["platformCode"] as? String {
                            stopName = formatStopName(name, platformCode: platformCode)
                        }
                        stops.append(Stop(name: stopName, distance: String(distance), codeLong: trimAgency(gtfsId), codeShort: code, departures: []))
                    }
                }
            }
            callback(stops: stops)
        })
    }

    private static func formatStopName(name: String, platformCode: String?) -> String {
        return platformCode != nil ? "\(name), laituri \(platformCode!)" : name
    }

    private static func parseDepartures(departures: NSArray) -> [Departure] {
        var deps: [Departure] = []
        for dep in departures {
            if let time = dep["scheduledDeparture"] as? Int,
                let trip = dep["trip"] as AnyObject?,
                let destination = trip["tripHeadsign"] as? String,
                let pickupType = dep["pickupType"] as? String,
                let route = trip["route"] as AnyObject?,
                let codeShort = route["shortName"] as? String {
                if(pickupType != "NONE") {
                    deps.append(
                        Departure(
                            line: Line(codeLong: codeShort, codeShort: codeShort, destination: destination),
                            time: secondsFromMidnightToTime(time)
                        ))
                }
            }
        }
        return deps
    }

    private static func secondsFromMidnightToTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let hours = String(format: "%02d", minutes/60)
        let remainder = String(format: "%02d", minutes % 60)
        return "\(hours):\(remainder)"
    }

    private static func trimAgency(gtfsId: String) -> String {
        if let index = gtfsId.characters.indexOf(":") {
            let foo = gtfsId.substringFromIndex(index.successor())
            return foo
        }
        return gtfsId
    }
}