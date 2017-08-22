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

    open static func formatDepartureTime(_ scheduled: Int, real: Int) -> NSAttributedString {
        let scheduledTime = secondsFromMidnightToTime(scheduled)
        let realTime = secondsFromMidnightToTime(real)

        if(scheduledTime != realTime && abs(scheduled - real) >= 60) {
            let realString = NSMutableAttributedString(string: realTime)
            let space = NSAttributedString(string: " ")
            let scheduledString = NSMutableAttributedString(
                string: scheduledTime,
                attributes: [
                    NSStrikethroughStyleAttributeName: 1,
                    NSStrikethroughColorAttributeName: UIColor.lightGray,
                    NSForegroundColorAttributeName: UIColor.gray,
                    NSBaselineOffsetAttributeName: 0])
            scheduledString.append(space)
            scheduledString.append(realString)
            return scheduledString
        }
        return NSAttributedString(string: secondsFromMidnightToTime(scheduled))
    }

    open static func secondsFromMidnightToTime(_ seconds: Int) -> String {
        let minutes = seconds / 60

        let hoursInt = minutes/60
        let hours = String(format: "%02d", hoursInt >= 24 ? hoursInt - 24 : hoursInt)
        let remainder = String(format: "%02d", minutes % 60)
        return "\(hours):\(remainder)"
    }

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

    open static func formatStopText(stop: Stop) -> String {
        return stop.codeShort == "-"
            ? "\(stop.name)"
            : "\(stop.name) (\(stop.codeShort))"
    }

    open static func hasShortCodes(stops: [Stop]) -> Bool {
        return stops.filter({ $0.codeShort != "-" }).count > 0
    }

    open static func hasShortCodes(departures: [Departure]) -> Bool {
        return departures.filter({ $0.line.codeShort != "-" }).count > 0
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
