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

private class StopAnnotation: MKPointAnnotation {
    let stop: Stop

    init(stop: Stop) {
        self.stop = stop
    }
}

class AllStopsMapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var allStopsMap: MKMapView!
    var hasZoomedToUser = false

    override func viewDidLoad() {
        allStopsMap.delegate = self
        allStopsMap.showsUserLocation = true
        allStopsMap.showsScale = true
        allStopsMap.showsCompass = true
        allStopsMap.showsBuildings = true
        super.viewDidLoad()

        displayStopsForCurrentRegion()
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        displayStopsForCurrentRegion()
    }

    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if(!hasZoomedToUser) {
            zoomToUser(userCoordinate: userLocation.coordinate)
            hasZoomedToUser = true
        }

    }

    private func zoomToUser(userCoordinate: CLLocationCoordinate2D) {
        let location = allStopsMap.userLocation

        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

        allStopsMap.setRegion(region, animated: true)
    }

    private func displayStopsForCurrentRegion() {
        let lat = self.allStopsMap.centerCoordinate.latitude
        let lon = self.allStopsMap.centerCoordinate.longitude

        HSL.nearestStopsAndDepartures(lat, lon: lon, radius: getSearchRadius(), stopCount: 100, callback: {(stops: [Stop]) in
            let stopPins = stops.map({stop -> MKPointAnnotation in
                let lat = CLLocationDegrees(floatLiteral: stop.lat)
                let lon = CLLocationDegrees(floatLiteral: stop.lon)
                let pin = StopAnnotation(stop: stop)
                pin.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)

                return pin
            })

            DispatchQueue.main.async {
                if(stopPins.count > 0) {
                    self.allStopsMap.removeAnnotations(self.allStopsMap.annotations)
                    self.allStopsMap.addAnnotations(stopPins)
                }
            }
        })
    }

    private func getSearchRadius() -> Int {
        let heightMeters = abs(allStopsMap.region.span.latitudeDelta) * 111111

        return Int(heightMeters)
    }

    let SHOW_NEXT_DEPARTURES_SEGUE = "showNextDepartures"

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.performSegue(withIdentifier: SHOW_NEXT_DEPARTURES_SEGUE, sender: view)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == SHOW_NEXT_DEPARTURES_SEGUE) {
            if let destination = segue.destination as? NextDeparturesTableViewController,
                let stopPin = (sender as? MKAnnotationView)?.annotation as? StopAnnotation {
                destination.stop = stopPin.stop
            }
        }
    }
}
