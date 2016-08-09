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
            return stops
        }
        return []
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
        print(stops)
        saveToUserDefaults(stops)
    }

    private static func saveToUserDefaults(stops: [Stop]) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(stops)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey: FAVORITE_STOPS_KEY)
    }
}