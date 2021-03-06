//
//  NearestStopsDataSource.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 06/02/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import CoreLocation
import NearestDeparturesDigitransit

class NearestStopsDataSource: NSObject, StopsTableViewControllerDelegate, CLLocationManagerDelegate {
    var locationManager: CLLocationManager!
    var lat: Double = 0
    var lon: Double = 0
    var updateUI: (_ stops: [Stop]?) -> Void

    override init() {
        self.updateUI = {_ in }
        super.init()
    }

    func viewDidLoad() {
        setupLocationManager()
    }

    func loadData(callback: @escaping ([Stop]?, TransitDataError?) -> Void) {
        if (self.lat == 0.0 && self.lon == 0.0) {
            callback(nil, nil)
        } else {
            TransitData.nearestStopsAndDepartures(self.lat, lon: self.lon, callback: {(stops: [Stop]) in
                let stopsWithDepartures = stops.filter({ $0.departures.count > 0 })
                callback(stopsWithDepartures, nil)
            })
        }
    }

    func getTitle() -> String {
        return NSLocalizedString("NEAREST_STOPS_TITLE", comment: "")
    }

    func getNoStopsMessage() -> String {
        return NSLocalizedString("NO_STOPS_MSG", comment: "")
    }

    fileprivate func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5

        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined) {
            locationManager.requestWhenInUseAuthorization()
        }

        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.restricted || CLLocationManager.authorizationStatus() != CLAuthorizationStatus.denied) {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status != CLAuthorizationStatus.restricted || status != CLAuthorizationStatus.denied) {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lat = locations.last!.coordinate.latitude
        lon = locations.last!.coordinate.longitude

        NSLog("Got new location data")
        loadData(callback: {(stops: [Stop]?, error: TransitDataError?) in
            self.updateUI(stops)
        })
    }
}
