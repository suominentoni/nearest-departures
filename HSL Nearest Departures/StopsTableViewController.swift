//
//  StopsTableViewController.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 30/12/2017.
//  Copyright © 2017 Toni Suominen. All rights reserved.
//

import UIKit
import CoreLocation

class StopsTableViewController: UITableViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager!
    var lat: Double = 0
    var lon: Double = 0

    var stops: [Stop] = []
    fileprivate var hasShortCodes: Bool = false

    override func viewDidAppear(_ animated: Bool) {
        loadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200

        setTitle()

        if (self.isFavoritesStopsView()) {
            loadData()
        } else if(self.isNearestStopsView()) {
            setupLocationManager()
        }
    }

    fileprivate func setTitle() {
        var title = "Pysäkit"

        if (self.isFavoritesStopsView()){
            title = "Suosikkipysäkkisi"
        } else if (self.isNearestStopsView()) {
            title = "Lähimmät pysäkkisi"
        }

        self.navigationItem.title = title;
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
        loadData()
    }

    fileprivate func loadData() {
        let x = self.tableView.center.x
        let y = self.tableView.center.y
        self.tableView.backgroundView = LoadingIndicator(frame: CGRect(x: x-35, y: y-35, width: 70 , height: 70))

        if (self.isFavoritesStopsView()) {
            self.stops = FavoriteStops.all()

            HSL.updateDeparturesForStops(self.stops, callback: {stops in
                DispatchQueue.main.async {
                    self.stops = stops
                    self.tableView.reloadData()
                }
            })

            self.hasShortCodes = Tools.hasShortCodes(stops: self.stops)
            if (self.stops.count == 0 ) {
                let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
                messageLabel.textAlignment = NSTextAlignment.center
                messageLabel.numberOfLines = 0
                messageLabel.text = Const.NO_FAVORITE_STOPS_MSG
                messageLabel.sizeToFit()

                self.tableView.backgroundView = messageLabel
            } else {
                self.tableView.backgroundView = nil
            }
            self.tableView.reloadData()
        } else if (self.isNearestStopsView()) {
            HSL.nearestStopsAndDepartures(lat, lon: lon, callback: {(stops: [Stop]) in
                self.stops = stops
                self.hasShortCodes = Tools.hasShortCodes(stops: stops)
                DispatchQueue.main.async(execute: {
                    if(self.stops.count == 0 ) {
                        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
                        messageLabel.textAlignment = NSTextAlignment.center
                        messageLabel.numberOfLines = 0
                        messageLabel.text = self.isFavoritesStopsView()
                            ? Const.NO_FAVORITE_STOPS_MSG
                            : Const.NO_STOPS_MSG
                        messageLabel.sizeToFit()

                        self.tableView.backgroundView = messageLabel
                    } else {
                        self.tableView.backgroundView = nil
                    }

                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                })
            })
        } else { // stops in MKClusterAnnotation in AllStopsMap
            self.tableView.backgroundView = nil
            self.hasShortCodes = Tools.hasShortCodes(stops: stops)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearestStopCell", for: indexPath) as! NearestStopsCell
        let stop = stopForIndexPath(indexPath: indexPath)

        cell.code.text = stop.codeShort

        if let constraint = cell.codeWidthConstraint {
            cell.code.removeConstraint(constraint)
        }

        let codeWidthConstraint = NSLayoutConstraint(item: cell.code, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        self.hasShortCodes || self.isClusterStopsView()
            ? (codeWidthConstraint.constant = 55)
            : (codeWidthConstraint.constant = 0)

        cell.code.addConstraint(codeWidthConstraint)

        cell.name.text = stop.name
        cell.destinations.text = Tools.destinationsFromDepartures(departures: stop.departures)
        cell.distance.text = self.isNearestStopsView()
            ? String(stop.distance) + " m"
            : ""

        return cell
    }

    fileprivate func stopForIndexPath(indexPath: IndexPath) -> Stop {
        return indexPath.row >= self.stops.count ? Stop() : self.stops[(indexPath as NSIndexPath).row]
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextDeparturesViewController = segue.destination as! NextDeparturesTableViewController
        nextDeparturesViewController.stop = self.stops[(self.tableView.indexPathForSelectedRow! as NSIndexPath).row]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stops.count
    }
}

fileprivate enum SelectedStopView: Int {
    case Nearest
    case Favorites
}

extension StopsTableViewController {
    fileprivate func getSelectedStopView() -> SelectedStopView? {
        if let selectedIndex = self.tabBarController?.selectedIndex,
            let selectedStopView = SelectedStopView(rawValue: selectedIndex) {
            return selectedStopView
        }

        return nil
    }

    fileprivate func isNearestStopsView() -> Bool {
        return getSelectedStopView() == SelectedStopView.Nearest
    }

    fileprivate func isFavoritesStopsView() -> Bool {
        return getSelectedStopView() == SelectedStopView.Favorites
    }

    fileprivate func isClusterStopsView() -> Bool {
        return !self.isFavoritesStopsView() && !self.isNearestStopsView()
    }
}
