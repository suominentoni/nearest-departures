//
//  DigitransitResposeParser.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 14/10/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import Foundation

struct Coordinate {
    let lat: Double
    let lon: Double
}

class DigitransitResponseParser {
    static func parseStopsFromData(obj: [String: AnyObject]) throws -> [Stop]  {
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
                NSLog(message)
                throw TransitDataError.dataFetchingError(id: String(id), stop: nil)
            } else {
                NSLog("Error updating departures for stops")
                throw TransitDataError.unknownError
            }
        } else {
            let stopsData = unwrapStopsData(obj: obj)
            let stops = stopsData.map({stop in parseStop(stop)})
            return stops.unwrapAndStripNils()
        }
    }

    static func unwrapStopsData(obj: [String: AnyObject]) -> [[String: AnyObject]] {
        if let data = obj["data"] as? [String: AnyObject],
            let stopsData = data["stops"] as? [[String: AnyObject]] {
            return stopsData
        }
        return []
    }

    static func parseDeparturesFromData(obj: [String: AnyObject]) -> [Departure] {
        return parseDepartures(unwrapSingleStopData(obj: obj))
    }

    static func parseCoordinatesFromData(obj: [String: AnyObject]) -> Coordinate {
        let stopData = unwrapSingleStopData(obj: obj)
        if let lat = stopData["lat"] as? Double,
            let lon = stopData["lon"] as? Double {
            return Coordinate(lat: lat, lon: lon)
        }
        return Coordinate(lat: 0, lon: 0)
    }

    static func unwrapSingleStopData(obj: [String: AnyObject]) -> [String: AnyObject] {
        if let data = obj["data"] as? [String: AnyObject],
            let stopData = data["stop"] as? [String: AnyObject] {
            return stopData
        }
        return [String: AnyObject]()
    }

    static func parseStop(_ stop: [String: AnyObject], distance: Int = 0) -> Stop? {
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
                    departures: departures)
        }
        return nil
    }

    static func parseStopsAndDeparturesFromData(obj: [String: AnyObject]) -> [Stop] {
        var stops: [Stop?] = []
        if let data = obj["data"] as? [String: AnyObject],
            let stopsByRadius = data["stopsByRadius"] as? [String: AnyObject],
            let edges = stopsByRadius["edges"] as? NSArray {
            for edge in edges {
                stops.append(self.parseStopAtDistance(edge as AnyObject))
            }
        }
        return stops.unwrapAndStripNils()
    }

    static func parseNearestStopsFromData(obj: [String: AnyObject]) -> [Stop] {
        var stops: [Stop?] = []
        if let data = obj["data"] as? [String: AnyObject],
            let stopsByRadius = data["stopsByRadius"] as? [String: AnyObject],
            let edges = stopsByRadius["edges"] as? NSArray {
            for edge in edges {
                stops.append(DigitransitResponseParser.parseStopAtDistance(edge as AnyObject))
            }
        }
        return stops.unwrapAndStripNils()
    }

    static func parseRectStopsFromData(obj: [String: AnyObject]) -> [Stop] {
        var stops: [Stop?] = []
        if let data = obj["data"] as? [String: AnyObject],
            let stopsByBox = data["stopsByBbox"] as? NSArray {
            for stop in stopsByBox {
                stops.append(DigitransitResponseParser.parseStop(stop as! [String : AnyObject]))
            }
        }
        return stops.unwrapAndStripNils()
    }

    fileprivate static func parseStopAtDistance(_ data: AnyObject) -> Stop? {
        if let stopAtDistance = data["node"] as? [String: AnyObject],
            let distance = stopAtDistance["distance"] as? Int,
            let stop = stopAtDistance["stop"] as? [String: AnyObject] {
            return DigitransitResponseParser.parseStop(stop, distance: distance)
        } else {
            return nil
        }
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

    fileprivate static func formatStopName(_ name: String, platformCode: String?) -> String {
        return platformCode != nil ? "\(name), laituri \(platformCode!)" : name
    }

    fileprivate static func formatDistance(_ distance: Int) -> String {
        return distance <= 50 ? "<50" : String(distance)
    }

    fileprivate static func shortCodeForRoute(routeData: [String: AnyObject]) -> String {
        if let mode = routeData["mode"] as? String , mode == "SUBWAY" {
            return "Metro"
        }
        return routeData["shortName"] as? String ?? "-"
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
}
