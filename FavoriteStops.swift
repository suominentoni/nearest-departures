//
//  FavoriteStops.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 08/08/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import Foundation

class FavoriteStops {
    private static let FAVORITE_STOPS_KEY = "hsl_fav_stops"

    static func all() -> [Stop] {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey(FAVORITE_STOPS_KEY) as? NSData,
        let stops = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [Stop] {
            return stops.sort {$0.name < $1.name}
        }
        return []
    }

    static func migrateToAgencyPrefixedCodeFormat() {
        NSLog("Favorite stops: Checking for entries with outdated code format")
        self.saveToUserDefaults(FavoriteStops.all().map(self.toAgencyPrefixedCodeFormat))
    }

    private static func toAgencyPrefixedCodeFormat(stop: Stop) -> Stop {
        // If the long code contains only numbers, it was stored as a favorite before updating the app
        // to work throughout the country, and therefore is an HSL code. Since that update the codes are 
        // stored with their agency prefix in place ('HSL:' or 'MATKA:').
        //
        // If numbers-only HSL codes are encountered, let's update the favorite stop entry with the full,
        // agency-prefixed code.
        if(stop.codeLong.rangeOfString("^[0-9]*$", options: .RegularExpressionSearch) != nil) {
            NSLog("Favorite stops: Migrating numbers-only stop code: \(stop.codeLong) \(stop.name)")
            stop.codeLong = "HSL:\(stop.codeLong)"
        }
        return stop
    }

    static func isFavoriteStop(stop: Stop) -> Bool {
        let stops = FavoriteStops.all()

        var isFavorite = false

        stops.forEach {favoriteStop in
            if(stop == favoriteStop) {
                isFavorite = true
            }
        }

        return isFavorite
    }

    static func tryUpdate(stop: Stop) {
        NSLog("Trying to update stop: \(stop.name) \(stop.codeLong)")
        if(self.isFavoriteStop(stop)) {
            self.remove(stop)
            var stops = FavoriteStops.all()
            stops.append(stop)
            saveToUserDefaults(stops)
        }
    }

    static func add(stop: Stop) {
        var stops = FavoriteStops.all()

        if(!self.isFavoriteStop(stop)) {
            NSLog("Saving favorite stop: \(stop.name) \(stop.codeLong)")
            stops.append(stop)
            let data = NSKeyedArchiver.archivedDataWithRootObject(stops)
            NSUserDefaults.standardUserDefaults().setObject(data, forKey: FAVORITE_STOPS_KEY)
        }
    }

    static func remove(stop: Stop) {
        NSLog("Removing favorite stop: \(stop.name) \(stop.codeLong)")
        let stops = FavoriteStops.all().filter { $0 != stop }
        saveToUserDefaults(stops)
    }

    private static func saveToUserDefaults(stops: [Stop]) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(stops)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: FAVORITE_STOPS_KEY)
    }
}