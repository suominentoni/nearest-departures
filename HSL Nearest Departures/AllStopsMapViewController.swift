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

class StopAnnotation: MKPointAnnotation {
    var stop: Stop?
}

class AllStopsMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var allStopsMap: MKMapView!

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
                let pin = StopAnnotation()
                pin.stop = stop
                pin.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)

                return pin
            })

            DispatchQueue.main.async {
                self.allStopsMap.removeAnnotations(self.allStopsMap.annotations)
                self.allStopsMap.addAnnotations(stopPins)
            }
        })
    }

    let SHOW_NEXT_DEPARTURES_SEGUE = "showNextDepartures"

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.performSegue(withIdentifier: SHOW_NEXT_DEPARTURES_SEGUE, sender: view)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == SHOW_NEXT_DEPARTURES_SEGUE) {
            if let destination = segue.destination as? NextDeparturesTableViewController,
                let stopPin = (sender as? MKAnnotationView)?.annotation as? StopAnnotation,
                let stop = stopPin.stop {
                destination.stop = stop
            }
        }
    }
}
