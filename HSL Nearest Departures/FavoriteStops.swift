//
//  FavoriteStops.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 08/08/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import Foundation

class FavoriteStops {
    fileprivate static let FAVORITE_STOPS_KEY = "hsl_fav_stops"

    static func all() throws -> [Stop] {
        if let data = UserDefaults.standard.object(forKey: FAVORITE_STOPS_KEY) as? Data,
        let stops = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Stop] {
            return stops.sorted {$0.name < $1.name}
        }
        return []
    }

    static func migrateToAgencyPrefixedCodeFormat() {
        NSLog("Favorite stops: Checking for entries with outdated code format")
        if let mappedStops = try? FavoriteStops.all().map(self.toAgencyPrefixedCodeFormat) {
            self.saveToUserDefaults(mappedStops)
        } else {
            NSLog("Error migrating favourite stops to agency prefixed code format. Failed to fetch current favourite stops.")
        }
    }

    private static func toAgencyPrefixedCodeFormat(stop: Stop) -> Stop {
        // If the long code contains only numbers, it was stored as a favorite before updating the app
        // to work throughout the country, and therefore is an HSL code. Since that update the codes are
        // stored with their agency prefix in place ('HSL:' or 'MATKA:').
        //
        // If numbers-only HSL codes are encountered, let's update the favorite stop entry with the full,
        // agency-prefixed code.
        if(stop.codeLong.range(of: "^[0-9]*$", options: .regularExpression) != nil) {
            NSLog("Favorite stops: Migrating numbers-only stop code: \(stop.codeLong) \(stop.name)")
            stop.codeLong = "HSL:\(stop.codeLong)"
        }
        return stop
    }

    static func isFavoriteStop(_ stop: Stop) -> Bool {
        return (try? FavoriteStops.all().filter({favStop in favStop == stop}).count > 0) ?? false
    }

    static func tryUpdate(_ stop: Stop) {
        NSLog("Trying to update stop: \(stop.name) \(stop.codeLong)")
        if(self.isFavoriteStop(stop)) {
            self.remove(stop)
            if var stops = try? FavoriteStops.all() {
                stops.append(stop)
                saveToUserDefaults(stops)
            } else {
                NSLog("Error updating favourite stop: \(stop.name) \(stop.codeLong). Failed to fetch current favourite stops.")
            }
        }
    }

    static func add(_ stop: Stop) {
        if(!self.isFavoriteStop(stop)) {
            if var stops = try? FavoriteStops.all() {
                NSLog("Saving favorite stop: \(stop.name) \(stop.codeLong)")
                stops.append(stop)
                let data = NSKeyedArchiver.archivedData(withRootObject: stops)
                UserDefaults.standard.set(data, forKey: FAVORITE_STOPS_KEY)
            } else {
                NSLog("Error adding favourite stop: \(stop.name) \(stop.codeLong). Failed to fetch current favourite stops.")
            }
        }
    }

    static func remove(_ stop: Stop) {
        NSLog("Removing favorite stop: \(stop.name) \(stop.codeLong)")
        if let stops = try? FavoriteStops.all().filter { $0 != stop } {
            saveToUserDefaults(stops)
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
