//
//  Departure.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 14/10/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import Foundation
import UIKit

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
                    NSAttributedString.Key.strikethroughStyle: 1,
                    NSAttributedString.Key.strikethroughColor: UIColor.lightGray,
                    NSAttributedString.Key.foregroundColor: UIColor.gray,
                    NSAttributedString.Key.baselineOffset: 0])
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

    public func destinations() -> String {
        let destinations = self
            .reduce([String](), { (destinations, departure) in
                if let destination = departure.line.destination, destinations.contains(destination) == false {
                    return destinations + [destination]
                } else {
                    return destinations
                }
            })
            .joined(separator: ", ")
        return destinations.count == 0 ? "-" : destinations
    }
}
