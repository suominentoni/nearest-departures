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

extension MKCoordinateRegion {
    var northWestCorner: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: center.latitude + span.latitudeDelta  / 2,
                                      longitude: center.longitude - span.longitudeDelta / 2)
    }
    var northEastCorner: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: center.latitude + span.latitudeDelta  / 2,
                                      longitude: center.longitude + span.longitudeDelta / 2)
    }
    var southWestCorner: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: center.latitude - span.latitudeDelta  / 2,
                                      longitude: center.longitude - span.longitudeDelta / 2)
    }
    var southEastCorner: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: center.latitude - span.latitudeDelta  / 2,
                                      longitude: center.longitude + span.longitudeDelta / 2)
    }
}

class AllStopsMapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var allStopsMap: MKMapView!
    @IBOutlet weak var infoLabel: UILabel!
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

    override func viewDidLayoutSubviews() {
        infoLabel.layer.borderWidth = 1
        infoLabel.layer.borderColor = UIColor.lightGray.cgColor
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
        let region = self.allStopsMap.region
        let minLat = region.southWestCorner.latitude
        let minLon = region.southWestCorner.longitude
        let maxLat = region.northEastCorner.latitude
        let Maxlon = region.northEastCorner.longitude

        let rectSmallEnoughForFetchingStops = region.span.latitudeDelta < 0.03 || region.span.longitudeDelta < 0.03

        if(rectSmallEnoughForFetchingStops) {
            if(!infoLabel.isHidden) {
                hideShowInfoLabel(hide: true)
            }

            HSL.stopsForRect(minLat: minLat, minLon: minLon, maxLat: maxLat, maxLon: Maxlon, callback: {(stops: [Stop]) in
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
        } else {
            if(infoLabel.isHidden) {
                hideShowInfoLabel(hide: false)
            }
        }
    }

    private func hideShowInfoLabel(hide: Bool) {
        allStopsMap.showsScale = hide
        UIView.transition(with: infoLabel,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: {
                              self.infoLabel.isHidden = hide
                          },
                          completion: nil)
    }

    let SHOW_NEXT_DEPARTURES_SEGUE = "showNextDepartures"

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        UIView.transition(
            with: view,
            duration: 0.07,
            options: .curveEaseIn,
            animations: {
                view.frame.origin.y -= 7
            }, completion: { completed in
                UIView.transition(
                    with: view,
                    duration: 0.07,
                    options: .curveEaseIn,
                    animations: {
                        view.frame.origin.y += 7
                }, completion: { completed in
                    self.performSegue(withIdentifier: self.SHOW_NEXT_DEPARTURES_SEGUE, sender: view)
                    self.allStopsMap.deselectAnnotation(view.annotation, animated: false)
                })
            })

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
