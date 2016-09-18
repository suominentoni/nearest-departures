//
//  StopMapViewController.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 22/08/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class StopMapViewController: UIViewController {

    @IBOutlet var stopMap: MKMapView!
    var stop: Stop = Stop()

    override func viewDidLoad() {
        self.title = Tools.formatStopText(stop: self.stop)
        stopMap.showsUserLocation = true
        if(!stop.hasCoordinates()) {
            HSL.coordinatesForStop(stop, callback: {(lat: Double, lon: Double) -> Void in
                // If stop had no coordinates set, it is most probably saved to favorite stops prior
                // to version 2.0.0, which added coordinates to the Stop class. In such case, let's
                // update the coordinates to the favorite stop entry.
                self.stop.lat = lat
                self.stop.lon = lon
                self.showStopPinAnnotation()
                FavoriteStops.tryUpdate(self.stop)
            })
        } else {
            showStopPinAnnotation()
        }
    }

    fileprivate func showStopPinAnnotation() {
        let lat = CLLocationDegrees(floatLiteral: self.stop.lat)
        let lon = CLLocationDegrees(floatLiteral: self.stop.lon)
        let pin = MKPointAnnotation()
        pin.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        stopMap.addAnnotation(pin)
        stopMap.showAnnotations([pin], animated: true)
    }
}
