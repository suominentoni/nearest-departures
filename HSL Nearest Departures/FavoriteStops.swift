//
//  FavoriteStops.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 08/08/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import Foundation
import NearestDeparturesDigitransit

class FavoriteStops {
    fileprivate static let FAVORITE_STOPS_KEY = "hsl_fav_stops"

    static func all() throws -> [Stop] {
        if let data = UserDefaults.standard.object(forKey: FAVORITE_STOPS_KEY) as? Data,
        let stops = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Stop] {
            return stops.sorted {$0.name < $1.name}
        }
        return []
    }

    static func isFavoriteStop(_ stop: Stop) -> Bool {
        return (try? FavoriteStops.all().filter({favStop in favStop == stop}).count > 0) ?? false
    }

    static func add(_ stop: Stop) {
        if(!self.isFavoriteStop(stop)) {
            if var stops = try? FavoriteStops.all() {
                NSLog("Saving favorite stop: \(stop.name) \(stop.codeLong)")
                stops.append(stop)
                let data = NSKeyedArchiver.archivedData(withRootObject: stops)
                UserDefaults.standard.set(data, forKey: FAVORITE_STOPS_KEY)
                WatchSessionManager.sharedManager.transferFavoriteStops()
            } else {
                NSLog("Error adding favourite stop: \(stop.name) \(stop.codeLong). Failed to fetch current favourite stops.")
            }
        }
    }

    static func remove(_ stop: Stop) {
        NSLog("Removing favorite stop: \(stop.name) \(stop.codeLong)")
        if let stops = try? FavoriteStops.all().filter { $0 != stop } {
            saveToUserDefaults(stops)
            WatchSessionManager.sharedManager.transferFavoriteStops()
        } else {
            NSLog("Error removing favourite stop: \(stop.name) \(stop.codeLong). Failed to fetch current favourite stops.")
        }
    }

    static func getBy(_ code: String) -> Stop? {
        if let stop = try? FavoriteStops.all().first(where: {$0.codeLong == code || $0.codeShort == code}) {
            return stop
        }
        return nil
    }

    fileprivate static func saveToUserDefaults(_ stops: [Stop]) {
        let data = NSKeyedArchiver.archivedData(withRootObject: stops)
        UserDefaults.standard.set(data, forKey: FAVORITE_STOPS_KEY)
    }
}
