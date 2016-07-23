//
//  Model.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 14/07/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import Foundation

public struct Stop {
    let name: String
    let distance: String
    let codeLong: String
    let codeShort: String
}

public struct Departure {
    let line: Line
    let time: String
}

public struct Line {
    let codeLong: String
    let codeShort: String?
}

public struct Const {
    static let NO_STOPS_TITLE = "Ei pysäkkejä"
    static let NO_STOPS_MSG = "Lähistöltä ei löytynyt pysäkkejä. Sovellus etsii pysäkkejä noin 500 metrin säteellä."

    static let UNLOCK_IPHONE_TITLE = "Avaa iPhonen lukitus"
    static let UNLOCK_IPHONE_MSG = "iPhonen lukitus täytyy avata uudelleenkäynnistyksen jälkeen jotta Apple Watchin ja iPhonen välinen kommunikaatio on mahdollista."
}
