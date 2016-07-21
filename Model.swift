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
    let distance: Int
    let codeLong: String
    let codeShort: String

    public func toDict() -> [String: AnyObject] {
        return [
            "name": self.name,
            "distance": self.distance,
            "codeLong": self.codeLong,
            "codeShort": self.codeShort
        ]
    }
}

public struct Departure {
    let line: String
    let time: String
    let lineShort: String?

    public func toDict() -> [String: AnyObject] {
        return [
            "line": self.line,
            "time": self.time,
            "lineShort": (self.lineShort != nil) ? self.lineShort! : ""
        ]
    }
}