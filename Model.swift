//
//  Model.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 14/07/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import Foundation

open class Stop: NSObject, NSCoding {
    var name: String = ""
    var lat: Double = 0.0
    var lon: Double = 0.0
    var distance: String = ""
    var codeLong: String = ""
    var codeShort: String = ""
    var departures: [Departure] = []

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

    open func hasCoordinates() -> Bool {
        return self.lat != 0.0 && self.lon != 0.0
    }
}

func == (lhs: Stop, rhs: Stop) -> Bool {
    return lhs.codeLong == rhs.codeLong && lhs.codeShort == rhs.codeShort
}

func != (lhs: Stop, rhs: Stop) -> Bool {
    return lhs.codeLong != rhs.codeLong && lhs.codeShort != rhs.codeShort
}

public struct Departure {
    let line: Line
    let scheduledDepartureTime: Int // seconds from midnight
    let realDepartureTime: Int // seconds from midnight
}

public struct Line {
    let codeLong: String
    let codeShort: String?
    let destination: String?
}

public struct Const {
    static let NO_STOPS_TITLE = "Ei pysäkkejä"
    static let NO_STOPS_MSG = "Lähistöltä ei löytynyt pysäkkejä. Sovellus etsii pysäkkejä noin 500 metrin säteellä."

    static let NO_FAVORITE_STOPS_MSG = "Ei suosikkipysäkkejä valittuna. \n \n Valitse pysäkki suosikiksi painamalla sydäntä pysäkin seuraavien lähtöjen listassa."

    static let UNLOCK_IPHONE_TITLE = "Avaa iPhonen lukitus"
    static let UNLOCK_IPHONE_MSG = "iPhonen lukitus täytyy avata uudelleenkäynnistyksen jälkeen jotta Apple Watchin ja iPhonen välinen kommunikaatio on mahdollista."

    static let NO_DEPARTURES_TITLE = "Ei lähtöjä"
    static let NO_DEPARTURES_MSG = "Lähtöjä ei löytynyt."
}
