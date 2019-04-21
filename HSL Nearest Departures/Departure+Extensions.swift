//
//  Departure+Extensions.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 29/03/2019.
//  Copyright © 2019 Toni Suominen. All rights reserved.
//

import NearestDeparturesDigitransit
import UIKit

extension Departure {
    public func formattedDepartureTime() -> NSAttributedString {
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
