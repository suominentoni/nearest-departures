//
//  Model.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 14/07/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import Foundation
import UIKit

@objc(Stop)
open class Stop: NSObject, NSCoding {
    var name: String = ""
    var lat: Double = 0.0
    var lon: Double = 0.0
    var distance: String = ""
    var codeLong: String = ""
    var codeShort: String = ""
    var departures: [Departure] = []
    var nameWithCode: String {
        get {
            return codeShort == "-"
                ? "\(name)"
                : "\(name) (\(codeShort))"
        }
    }

    override init() {
       super.init()
    }

    init(name: String, lat: Double, lon: Double, distance: String, codeLong: String, codeShort: String, departures: [Departure]) {
        self.name = name
        self.lat = lat
        self.lon = lon
        self.distance = distance
        self.codeLong = codeLong
        self.codeShort = codeShort
        self.departures = departures
    }

    public required init?(coder aDecoder: NSCoder) {
        if let name = aDecoder.decodeObject(forKey: "name") as? String,
            let distance = aDecoder.decodeObject(forKey: "distance") as? String,
            let codeLong = aDecoder.decodeObject(forKey: "codeLong") as? String,
            let codeShort = aDecoder.decodeObject(forKey: "codeShort") as? String {
            var lat = 0.0
            var lon = 0.0
            do {
                try ObjC.catchException {
                    lat = aDecoder.decodeDouble(forKey: "lat")
                    lon = aDecoder.decodeDouble(forKey: "lon")
                }
            }
            catch let error {
                NSLog("Unable to decode coordinates for stop: \(error)")
            }

            self.lat = lat
            self.lon = lon
            self.name = name
            self.distance = distance
            self.codeLong = codeLong
            self.codeShort = codeShort
        }
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.lat, forKey: "lat")
        aCoder.encode(self.lon, forKey: "lon")
        aCoder.encode(self.distance, forKey: "distance")
        aCoder.encode(self.codeLong, forKey: "codeLong")
        aCoder.encode(self.codeShort, forKey: "codeShort")
    }

    public func hasCoordinates() -> Bool {
        return self.lat != 0.0 && self.lon != 0.0
    }
}

func == (lhs: Stop, rhs: Stop) -> Bool {
    return lhs.codeLong == rhs.codeLong
}

func != (lhs: Stop, rhs: Stop) -> Bool {
    return lhs.codeLong != rhs.codeLong
}

extension Array where Element:Stop {
    public func hasShortCodes() -> Bool {
        return self.filter({ $0.codeShort != "-" }).count > 0
    }
}

typealias DepartureTime = Int

extension DepartureTime {
    func toTime() -> String {
        let minutes = self / 60
        let hoursInt = minutes/60
        let hours = String(format: "%02d", hoursInt >= 24 ? hoursInt - 24 : hoursInt)
        let remainder = String(format: "%02d", minutes % 60)
        return "\(hours):\(remainder)"
    }
}

public struct Departure {
    let line: Line
    let scheduledDepartureTime: DepartureTime // seconds from midnight
    let realDepartureTime: DepartureTime // seconds from midnight

    func formattedDepartureTime() -> NSAttributedString {
        let scheduledTime = scheduledDepartureTime.toTime()
        let realTime = realDepartureTime.toTime()

        if(scheduledTime != realTime && abs(scheduledDepartureTime - realDepartureTime) >= 60) {
            let realString = NSMutableAttributedString(string: realTime)
            let space = NSAttributedString(string: " ")
            let scheduledString = NSMutableAttributedString(
                string: scheduledTime,
                attributes: [
                    NSAttributedStringKey.strikethroughStyle: 1,
                    NSAttributedStringKey.strikethroughColor: UIColor.lightGray,
                    NSAttributedStringKey.foregroundColor: UIColor.gray,
                    NSAttributedStringKey.baselineOffset: 0])
            scheduledString.append(space)
            scheduledString.append(realString)
            return scheduledString
        }
        return NSAttributedString(string: scheduledDepartureTime.toTime())
    }
}

extension Array where Element == Departure {
    public func hasShortCodes() -> Bool {
        return self.filter({ $0.line.codeShort != "-" }).count > 0
    }
}

public struct Line {
    let codeLong: String
    let codeShort: String?
    let destination: String?
}

public struct Const {
    static let NEAREST_STOPS_TITLE = "Lähimmät pysäkkisi"
    static let NO_STOPS_TITLE = "Ei pysäkkejä"
    static let NO_STOPS_MSG = "Lähistöltä ei löytynyt pysäkkejä. Sovellus etsii pysäkkejä maksimissaan 5000 metrin kävelymatkan päästä."

    static let FAVORITE_STOPS_TITLE = "Suosikkipysäkkisi"
    static let NO_FAVORITE_STOPS_MSG = "Ei suosikkipysäkkejä valittuna. \n \n Valitse pysäkki suosikiksi painamalla sydäntä pysäkin seuraavien lähtöjen listassa."

    static let UNLOCK_IPHONE_TITLE = "Avaa iPhonen lukitus"
    static let UNLOCK_IPHONE_MSG = "iPhonen lukitus täytyy avata uudelleenkäynnistyksen jälkeen jotta Apple Watchin ja iPhonen välinen kommunikaatio on mahdollista."

    static let NO_DEPARTURES_TITLE = "Ei lähtöjä"
    static let NO_DEPARTURES_MSG = "Lähtöjä ei löytynyt."

    static let LOCATION_REQUEST_FAILED_TITLE = "Virhe"
    static let LOCATION_REQUEST_FAILED_MSG = "Sijainnin selvittäminen epäonnistui. Varmista, että sijaintipalvelut on sallittu sovellukselle."

    static let STOPS = "Pysäkit"
    static let NO_STOPS = "Ei pysäkkejä"

    static let DATA_LOAD_FAILED_TITLE = "Virhe"
    static let DATA_LOAD_FAILED_UNKOWN_MESSAGE = "Virhe haettaessa pysäkkitietoja"
    static let DATA_LOAD_FAILED_DATA_FETCH_ERROR_MESSAGE = "Virhe haettaessa pysäkkitietoja. Pysäkkiä ei löytynyt: "
    static let DATA_LOAD_FAILED_FAVOURITE_STOPS_ERROR_MESSAGE = "Suosikkipysäkkien haku epäonnistui. Jos ongelma ei poistu, poista ja asenna Lähimmät Lähdöt -sovellus uudelleen. Pahoittelut vaivasta."
}
