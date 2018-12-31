//
//  DepartureTime.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 14/10/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import Foundation

// seconds from midnight
typealias DepartureTime = Int

extension DepartureTime {
    func toTime() -> String {
        let minutes = self / 60
        let hoursInt = minutes/60
        let days = (self % 86400) / 60
        let hours = String(format: "%02d", hoursInt >= 24 ? hoursInt - (24 * days) : hoursInt)
        let remainder = String(format: "%02d", minutes % 60)
        let plusOneDay = self >= 86400
            ? "(+\(days)) "
            : ""
        return "\(plusOneDay)\(hours):\(remainder)"
    }
}
