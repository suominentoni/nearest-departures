//
//  HSLGraphQL.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 14/08/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import Foundation
import UIKit

open class HSL {

    static let APIURL = "https://api.digitransit.fi/routing/v1/routers/finland/index/graphql"

    fileprivate static let stopFields = "gtfsId, lat, lon, code, platformCode, desc, name"
    fileprivate static let departureFields = "scheduledDeparture, realtimeDeparture, departureDelay, realtime, realtimeState, serviceDay, pickupType, trip {tripHeadsign, directionId, route {shortName, longName, mode}}"

    fileprivate static func getDeparturesForStopQuery(gtfsId: String) -> String {
        return "{stop(id: \"\(gtfsId)\" ) { \(stopFields), stoptimesWithoutPatterns(numberOfDepartures: 30) {\(departureFields) }}}"
    }

    fileprivate static func getDeparturesForStopsQuery(stops: [Stop]) -> String {
        let idsCommaSeparated = stops.reduce("", {(result, stop) in
            return result + "\"" + stop.codeLong + "\","
        })
        return "{stops(ids: [\(idsCommaSeparated)] ) { \(stopFields), stoptimesWithoutPatterns(numberOfDepartures: 30) {\(departureFields) }}}"
    }

    fileprivate static func getCoordinatesForStopQuery(stop: Stop) -> String {
        return "{stop(id: \"\(stop.codeLong)\" ) {lat, lon}}"
    }

    fileprivate static func getNearestStopsAndDeparturesQuery(lat: Double, lon: Double) -> String {
        return "{stopsByRadius(lat:\(String(lat)), lon: \(String(lon)), radius: 5000, first: 30)" +
            "{edges {node {distance, stop { \(stopFields)" +
            ",stoptimesWithoutPatterns(numberOfDepartures: 30) {" +
            departureFields + "}}}}}}"
    }

    fileprivate static func getNearestStopsQuery(lat: Double, lon: Double) -> String {
        return "{stopsByRadius(lat:\(String(lat)), lon: \(String(lon)), radius: 5000, first: 30)" +
        "{edges {node {distance, stop { \(stopFields) }}}}}"
    }

    static func updateDeparturesForStops(_ stops: [Stop], callback: @escaping (_ stopsWithDepartures: [Stop]) -> Void) -> Void {
        HTTP.post(APIURL, body: getDeparturesForStopsQuery(stops: stops), callback: {(obj: [String: AnyObject], error: String?) in
            if let data = obj["data"] as? [String: AnyObject],
                let stopsData = data["stops"] as? [[String: AnyObject]] {
                let stops = stopsData.map({stop in parseStop(stop)})
                callback(Tools.unwrapAndStripNils(stops))
            }
        })
    }

    static func departuresForStop(_ gtfsId: String, callback: @escaping (_ departures: [Departure]) -> Void) -> Void {
        HTTP.post(APIURL, body: getDeparturesForStopQuery(gtfsId: gtfsId), callback: {(obj: [String: AnyObject], error: String?) in
            if let data = obj["data"] as? [String: AnyObject],
                let stop = data["stop"] as? [String: AnyObject] {
                callback(parseDepartures(stop))
            }
        })
    }

    static func coordinatesForStop(_ stop: Stop, callback: @escaping (_ lat: Double, _ lon: Double) -> Void) -> Void {
        HTTP.post(APIURL, body: getCoordinatesForStopQuery(stop: stop), callback: {(obj: [String: AnyObject], error: String?) in
            if let data = obj["data"] as? [String: AnyObject],
                let stop = data["stop"] as? [String: AnyObject],
                let lat = stop["lat"] as? Double,
                let lon = stop["lon"] as? Double {
                callback(lat, lon)
            }
        })
    }

    static func nearestStopsAndDepartures(_ lat: Double, lon: Double, callback: @escaping (_ stops: [Stop]) -> Void) {
        HTTP.post(APIURL, body: getNearestStopsAndDeparturesQuery(lat: lat, lon: lon), callback: {(obj: [String: AnyObject], error: String?) in
            var stops: [Stop?] = []
            if let data = obj["data"] as? [String: AnyObject],
                let stopsByRadius = data["stopsByRadius"] as? [String: AnyObject],
                let edges = stopsByRadius["edges"] as? NSArray {
                for edge in edges {
                    stops.append(parseStopAtDistance(edge as AnyObject))
                }
            }
            callback(Tools.unwrapAndStripNils(stops))
        })
    }

    static func nearestStops(_ lat: Double, lon: Double, callback: @escaping (_ stops: [Stop]) -> Void) {
        HTTP.post(APIURL, body: getNearestStopsQuery(lat: lat, lon: lon), callback: {(obj: [String: AnyObject], error: String?) in
            var stops: [Stop?] = []
            if let data = obj["data"] as? [String: AnyObject],
                let stopsByRadius = data["stopsByRadius"] as? [String: AnyObject],
                let edges = stopsByRadius["edges"] as? NSArray {
                for edge in edges {
                    stops.append(parseStopAtDistance(edge as AnyObject))
                }
            }
            callback(Tools.unwrapAndStripNils(stops))
        })
    }

    fileprivate static func parseStopAtDistance(_ data: AnyObject) -> Stop? {
        if let stopAtDistance = data["node"] as? [String: AnyObject],
            let distance = stopAtDistance["distance"] as? Int,
            let stop = stopAtDistance["stop"] as? [String: AnyObject],
            let name = stop["name"] as? String,
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
                    codeShort: shortCodeForStop(stopData: stop),
                    departures: departures
            )
        } else {
            return nil
        }
    }

    fileprivate static func parseStop(_ stop: [String: AnyObject]) -> Stop? {
        if let name = stop["name"] as? String,
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
                    distance: "",
                    codeLong: gtfsId,
                    codeShort: shortCodeForStop(stopData: stop),
                    departures: departures
            )
        } else {
            return nil
        }
    }

    fileprivate static func shortCodeForStop(stopData: [String: AnyObject]) -> String {
        // Some public transit operators (e.g. the one in Jyväskylä)
        // don't have a code field for their stops.
        if let shortCode = stopData["code"] as? String {
            return shortCode
        } else {
            return "-"
        }
    }

    fileprivate static func formatDistance(_ distance: Int) -> String {
        return distance <= 50 ? "<50" : String(distance)
    }

    fileprivate static func formatStopName(_ name: String, platformCode: String?) -> String {
        return platformCode != nil ? "\(name), laituri \(platformCode!)" : name
    }

    fileprivate static func trimAgency(_ gtfsId: String) -> String {
        if let index = gtfsId.characters.index(of: ":") {
            let idWithoutAgency = gtfsId.substring(from: gtfsId.index(after: index))
            return idWithoutAgency
        }
        return gtfsId
    }

    fileprivate static func parseDepartures(_ stopData: [String: AnyObject]) -> [Departure] {
        var deps: [Departure] = []
        if let nextDeparturesData = stopData["stoptimesWithoutPatterns"] as? [[String: AnyObject]] {
            for dep: [String: AnyObject] in nextDeparturesData {
                if let scheduledDepartureTime = dep["scheduledDeparture"] as? Int,
                    let realDepartureTime = dep["realtimeDeparture"] as? Int,
                    let trip = dep["trip"] as AnyObject?,
                    let destination = trip["tripHeadsign"] as? String,
                    let pickupType = dep["pickupType"] as? String,
                    let route = trip["route"] as? [String: AnyObject] {
                    if(pickupType != "NONE") {
                        let code = shortCodeForRoute(routeData: route)
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
        if let mode = routeData["mode"] as? String , mode == "SUBWAY" {
            return "Metro"
        }
        return routeData["shortName"] as? String ?? "-"
    }
}
