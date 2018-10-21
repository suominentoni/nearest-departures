//
//  Stop.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 14/10/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
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

extension Array where Element == Optional<Stop> {
    public func unwrapAndStripNils() -> [Stop] {
        return self.filter({$0 != nil}).map({$0!})
    }
}
