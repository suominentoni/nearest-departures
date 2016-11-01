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

class StopMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var stopMap: MKMapView!
    var stop: Stop = Stop()
    var hasZoomedToUser = false

    override func viewDidLoad() {
        stopMap.delegate = self
        self.title = Tools.formatStopText(stop: self.stop)
        stopMap.showsUserLocation = true
        if(!stop.hasCoordinates()) {
            HSL.coordinatesForStop(stop, callback: {(lat: Double, lon: Double) -> Void in
                // If stop had no coordinates set, it is most probably a favorite stop, and saved to
                // favorite stops prior to version 2.0.0, which added coordinates to the Stop class.
                // In such case, let's update the coordinates to the favorite stop entry.
                self.stop.lat = lat
                self.stop.lon = lon
                self.showStopPinAnnotation()
                FavoriteStops.tryUpdate(self.stop)
            })
        } else {
            showStopPinAnnotation()
        }
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        zoomToPinAndUser(userCoordinate: userLocation.coordinate)
    }

    private func zoomToPinAndUser(userCoordinate: CLLocationCoordinate2D) {
        // Zoom to user only once, not after every subsequent user location update
        if(!hasZoomedToUser) {
            let stopPoint = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: self.stop.lat, longitude: self.stop.lon))
            let userPoint = MKMapPointForCoordinate(userCoordinate)

            let stopRect = MKMapRectMake(stopPoint.x, stopPoint.y, 0, 0)
            let userRect = MKMapRectMake(userPoint.x, userPoint.y, 0, 0)

            let unionRect = MKMapRectUnion(stopRect, userRect)
            let fitRect = stopMap.mapRectThatFits(unionRect)

            stopMap.setVisibleMapRect(fitRect, animated: true)
            hasZoomedToUser = true
        }
    }

    fileprivate func showStopPinAnnotation() {
        let lat = CLLocationDegrees(floatLiteral: self.stop.lat)
        let lon = CLLocationDegrees(floatLiteral: self.stop.lon)
        let pin = MKPointAnnotation()
        pin.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        stopMap.addAnnotation(pin)
        if let userCoordinate = stopMap.userLocation.location?.coordinate {
            zoomToPinAndUser(userCoordinate: userCoordinate)
        } else {
            stopMap.showAnnotations([pin], animated: true)
        }
    }
}
