//
//  Tools.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 19/08/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import Foundation
import UIKit

public class Tools {

    public static func formatDepartureTime(scheduled: Int, real: Int) -> NSAttributedString {
        let scheduledTime = secondsFromMidnightToTime(scheduled)
        let realTime = secondsFromMidnightToTime(real)

        if(scheduledTime != realTime && abs(scheduled - real) >= 60) {
            let realString = NSMutableAttributedString(string: realTime)
            let space = NSAttributedString(string: " ")
            let scheduledString = NSMutableAttributedString(
                string: scheduledTime,
                attributes: [
                    NSStrikethroughStyleAttributeName: 1,
                    NSStrikethroughColorAttributeName: UIColor.lightGrayColor(),
                    NSForegroundColorAttributeName: UIColor.grayColor()])
            scheduledString.appendAttributedString(space)
            scheduledString.appendAttributedString(realString)
            return scheduledString
        }
        return NSAttributedString(string: secondsFromMidnightToTime(scheduled))
    }

    public static func secondsFromMidnightToTime(seconds: Int) -> String {
        let minutes = seconds / 60

        let hoursInt = minutes/60
        let hours = String(format: "%02d", hoursInt >= 24 ? hoursInt - 24 : hoursInt)
        let remainder = String(format: "%02d", minutes % 60)
        return "\(hours):\(remainder)"
    }

    public static func unwrapAndStripNils<T>(data: [T?]) -> [T] {
        return data.filter({$0 != nil}).map({$0!})
    }

    public static func decodedValueForKeyOrDefault<T>(coder: NSCoder, key: String, defaultValue: T) -> T? {
        if let value = coder.decodeObjectForKey(key) as? T {
            return value
        } else {
            return defaultValue
        }
    }
}