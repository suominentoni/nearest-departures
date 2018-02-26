//
//  Tools.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 19/08/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import Foundation
import UIKit

open class Tools {
    open static func unwrapAndStripNils<T>(_ data: [T?]) -> [T] {
        return data.filter({$0 != nil}).map({$0!})
    }

    open static func decodedValueForKeyOrDefault<T>(coder: NSCoder, key: String, defaultValue: T) -> T? {
        if let value = coder.decodeDouble(forKey: key) as? T {
            return value
        } else {
            return defaultValue
        }
    }

    open static func destinationsFromDepartures(departures: [Departure]) -> String {
        return departures
            .reduce([String](), { (destinations, departure) in
                if let destination = departure.line.destination, destinations.contains(destination) == false {
                    return destinations + [destination]
                } else {
                    return destinations
                }
            })
            .joined(separator: ", ")
    }
}
