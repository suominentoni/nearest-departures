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

open class HSL {
    static let sharedInstance = HSL(httpClient: HSL.httpClient)
    static var httpClient: HTTP = HTTP()

    fileprivate init(httpClient: HTTP) {
        HSL.httpClient = httpClient
    }

    func updateDeparturesForStops(_ stops: [Stop], callback: @escaping (_ stopsWithDepartures: [Stop], _ error: TransitDataError?) -> Void) -> Void {
        HSL.httpClient.post(Digitransit.apiUrl, body: Digitransit.Query.departuresForStops(stops: stops), callback: {(obj: [String: AnyObject], error: String?) in
            if let errors = obj["errors"] as? NSArray {
                if let dataFetchingException = errors.first(where: {e in
                    if let errorType = (e as AnyObject)["errorType"] as? String {
                        return errorType == "DataFetchingException"
                    }
                    return false
                }) as? AnyObject,
                let message = dataFetchingException["message"] as? String,
                let range = message.range(of: "invalid agency-and-id: ") {
                    let id = message[range.upperBound...]
                    callback(stops, TransitDataError.dataFetchingError(id: String(id), stop: nil))
                    NSLog(message)
                } else {
                    NSLog("Error updating departures for stops")
                    callback(stops, TransitDataError.unknownError)
                }
            } else if let data = obj["data"] as? [String: AnyObject],
                let stopsData = data["stops"] as? [[String: AnyObject]] {
                let stops = stopsData.map({stop in self.parseStop(stop)})
                callback(stops.unwrapAndStripNils(), nil)
            } else {
                callback(stops, nil)
            }
        })
    }

    func departuresForStop(_ gtfsId: String, callback: @escaping (_ departures: [Departure]) -> Void) -> Void {
        HSL.httpClient.post(Digitransit.apiUrl, body: Digitransit.Query.departuresForStop(gtfsId: gtfsId), callback: {(obj: [String: AnyObject], error: String?) in
            if let data = obj["data"] as? [String: AnyObject],
                let stop = data["stop"] as? [String: AnyObject] {
                callback(self.parseDepartures(stop))
            } else {
                callback([])
            }
        })
    }

    func coordinatesForStop(_ stop: Stop, callback: @escaping (_ lat: Double, _ lon: Double) -> Void) -> Void {
        HSL.httpClient.post(Digitransit.apiUrl, body: Digitransit.Query.coordinatesForStop(stop: stop), callback: {(obj: [String: AnyObject], error: String?) in
            if let data = obj["data"] as? [String: AnyObject],
                let stop = data["stop"] as? [String: AnyObject],
                let lat = stop["lat"] as? Double,
                let lon = stop["lon"] as? Double {
                callback(lat, lon)
            }
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
        HSL.httpClient.post(Digitransit.apiUrl, body: Digitransit.Query.nearestStopsAndDepartures(lat: lat, lon: lon, radius: radius, stopCount: stopCount, departureCount: departureCount), callback: {(obj: [String: AnyObject], error: String?) in
            var stops: [Stop?] = []
            if let data = obj["data"] as? [String: AnyObject],
                let stopsByRadius = data["stopsByRadius"] as? [String: AnyObject],
                let edges = stopsByRadius["edges"] as? NSArray {
                for edge in edges {
                    stops.append(self.parseStopAtDistance(edge as AnyObject))
                }
            }
            callback(stops.unwrapAndStripNils())
        })
    }

    func nearestStops(_ lat: Double, lon: Double, callback: @escaping (_ stops: [Stop]) -> Void) {
        HSL.httpClient.post(Digitransit.apiUrl, body: Digitransit.Query.nearestStops(lat: lat, lon: lon), callback: {(obj: [String: AnyObject], error: String?) in
            var stops: [Stop?] = []
            if let data = obj["data"] as? [String: AnyObject],
                let stopsByRadius = data["stopsByRadius"] as? [String: AnyObject],
                let edges = stopsByRadius["edges"] as? NSArray {
                for edge in edges {
                    stops.append(self.parseStopAtDistance(edge as AnyObject))
                }
            }
            callback(stops.unwrapAndStripNils())
        })
    }

    func stopsForRect(minLat: Double, minLon: Double, maxLat: Double, maxLon: Double, callback: @escaping (_ stops: [Stop]) -> Void) {
        HSL.httpClient.post(Digitransit.apiUrl, body: Digitransit.Query.stopsForRect(minLat: minLat, minLon: minLon, maxLat: maxLat, maxLon: maxLon), callback: {(obj: [String: AnyObject], error: String?) in
            var stops: [Stop?] = []
            if let data = obj["data"] as? [String: AnyObject],
                let stopsByBox = data["stopsByBbox"] as? NSArray {
                for stop in stopsByBox {
                    stops.append(self.parseStop(stop as! [String : AnyObject]))
                }
            }
            callback(stops.unwrapAndStripNils())
        })
    }

    fileprivate func parseStopAtDistance(_ data: AnyObject) -> Stop? {
        if let stopAtDistance = data["node"] as? [String: AnyObject],
        let distance = stopAtDistance["distance"] as? Int,
        let stop = stopAtDistance["stop"] as? [String: AnyObject] {
            return parseStop(stop, distance: distance)
        } else {
            return nil
        }
    }

    fileprivate func parseStop(_ stop: [String: AnyObject], distance: Int = 0) -> Stop? {
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
                    distance: formatDistance(distance),
                    codeLong: gtfsId,
                    codeShort: shortCodeForStop(stopData: stop),
                    departures: departures
            )


        } else {
            return nil
        }
    }

    fileprivate func shortCodeForStop(stopData: [String: AnyObject]) -> String {
        // Some public transit operators (e.g. the one in Jyväskylä)
        // don't have a code field for their stops.
        if let shortCode = stopData["code"] as? String {
            return shortCode
        } else {
            return "-"
        }
    }

    fileprivate func formatDistance(_ distance: Int) -> String {
        return distance <= 50 ? "<50" : String(distance)
    }

    fileprivate func formatStopName(_ name: String, platformCode: String?) -> String {
        return platformCode != nil ? "\(name), laituri \(platformCode!)" : name
    }

    fileprivate func parseDepartures(_ stopData: [String: AnyObject]) -> [Departure] {
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

    fileprivate func shortCodeForRoute(routeData: [String: AnyObject]) -> String {
        if let mode = routeData["mode"] as? String , mode == "SUBWAY" {
            return "Metro"
        }
        return routeData["shortName"] as? String ?? "-"
    }
}
