//
//  Tools.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 19/08/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import Foundation

open class Tools {
    open static func decodedValueForKeyOrDefault<T>(coder: NSCoder, key: String, defaultValue: T) -> T? {
        if let value = coder.decodeDouble(forKey: key) as? T {
            return value
        } else {
            return defaultValue
        }
    }
}
