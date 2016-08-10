//
//  Model.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 14/07/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import Foundation

public class Stop: NSObject, NSCoding {
    var name: String = ""
    var distance: String = ""
    var codeLong: String = ""
    var codeShort: String = ""

    init(name: String, distance: String, codeLong: String, codeShort: String) {
        self.name = name
        self.distance = distance
        self.codeLong = codeLong
        self.codeShort = codeShort
    }

    public required init?(coder aDecoder: NSCoder) {
        if let name = aDecoder.decodeObjectForKey("name") as? String,
            let distance = aDecoder.decodeObjectForKey("distance") as? String,
            let codeLong = aDecoder.decodeObjectForKey("codeLong") as? String,
            let codeShort = aDecoder.decodeObjectForKey("codeShort") as? String {
            self.name = name
            self.distance = distance
            self.codeLong = codeLong
            self.codeShort = codeShort
        }
    }

    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.name, forKey: "name")
        aCoder.encodeObject(self.distance, forKey: "distance")
        aCoder.encodeObject(self.codeLong, forKey: "codeLong")
        aCoder.encodeObject(self.codeShort, forKey: "codeShort")
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
    let time: String
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
    static let NO_DEPARTURES_MSG = "Ei lähtöjä seuraavan kuuden tunnin aikana."
}
