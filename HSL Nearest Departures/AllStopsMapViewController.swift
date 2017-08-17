//
//  AllStopsMapsViewController.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 17/08/2017.
//  Copyright © 2017 Toni Suominen. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class AllStopsMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var allStopsMap: MKMapView!
    var annotations: [MKAnnotation] = []

    override func viewDidLoad() {
        allStopsMap.delegate = self
        super.viewDidLoad()

        displayStopsForCurrentRegion()
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        displayStopsForCurrentRegion()
    }

    fileprivate func displayStopsForCurrentRegion() {
        let lat = self.allStopsMap.centerCoordinate.latitude
        let lon = self.allStopsMap.centerCoordinate.longitude

        HSL.nearestStopsAndDepartures(lat, lon: lon, callback: {(stops: [Stop]) in
            let stopPins = stops.map({stop -> MKPointAnnotation in
                let lat = CLLocationDegrees(floatLiteral: stop.lat)
                let lon = CLLocationDegrees(floatLiteral: stop.lon)
                let pin = MKPointAnnotation()
                pin.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)

                return pin
            })

            DispatchQueue.main.async {
                self.allStopsMap.removeAnnotations(self.annotations)
                self.annotations = stopPins
                self.allStopsMap.addAnnotations(stopPins)
            }
        })

    }
}
