//
//  NearestStopsTableViewController.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 14/02/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import UIKit
import CoreLocation

class NearestStopsTableViewController: UITableViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager!
    var lat: Double = 0
    var lon: Double = 0

    fileprivate var nearestStops: [Stop] = []
    fileprivate var hasShortCodes: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5

        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined) {
            locationManager.requestWhenInUseAuthorization()
        }

        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.restricted || CLLocationManager.authorizationStatus() != CLAuthorizationStatus.denied) {
            locationManager.startUpdatingLocation()
        }

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(NearestStopsTableViewController.refresh), for: UIControlEvents.valueChanged)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status != CLAuthorizationStatus.restricted || status != CLAuthorizationStatus.denied) {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lat = locations.last!.coordinate.latitude
        lon = locations.last!.coordinate.longitude

        NSLog("Got new location data")
        reloadData()
    }

    @objc fileprivate func refresh() {
        reloadData()
    }

    fileprivate func reloadData() {
        let x = self.tableView.center.x
        let y = self.tableView.center.y
        self.tableView.backgroundView = LoadingIndicator(frame: CGRect(x: x-35, y: y-35, width: 70 , height: 70))
        HSL.nearestStopsAndDepartures(lat, lon: lon, callback: {(stops: [Stop]) in
            self.nearestStops = stops
            self.hasShortCodes = Tools.hasShortCodes(stops: stops)
            DispatchQueue.main.async(execute: {
                if(self.nearestStops.count == 0 ) {
                    let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
                    messageLabel.textAlignment = NSTextAlignment.center
                    messageLabel.numberOfLines = 0
                    messageLabel.text = Const.NO_STOPS_MSG
                    messageLabel.sizeToFit()

                    self.tableView.backgroundView = messageLabel
                } else {
                    self.tableView.backgroundView = nil
                }

                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            })
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nearestStops.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearestStopCell", for: indexPath) as! NearestStopsCell
        let stop = stopForIndexPath(indexPath: indexPath)

        cell.code.text = stop.codeShort
        let codeWidthConstraint = NSLayoutConstraint(item: cell.code, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        self.hasShortCodes
            ? (codeWidthConstraint.constant = 55)
            : (codeWidthConstraint.constant = 0)
        cell.code.addConstraint(codeWidthConstraint)

        cell.name.text = stop.name
        
        cell.destinations.text =
            stop.departures
                .sorted(by: { (departureA, departureB) in
                    departureA.realDepartureTime < departureB.realDepartureTime
                })
                .reduce([String](), { (destinations, departure) in
                    if let destination = departure.line.destination, destinations.contains(destination) == false {
                        return destinations + [destination]
                    } else {
                        return destinations
                    }
                })
               .joined(separator: ", ")

        cell.distance.text = String(stop.distance) + " m"

        return cell
    }

    private func stopForIndexPath(indexPath: IndexPath) -> Stop {
        return indexPath.row >= self.nearestStops.count ? Stop() : self.nearestStops[(indexPath as NSIndexPath).row]
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextDeparturesViewController = segue.destination as! NextDeparturesTableViewController
        nextDeparturesViewController.stop = self.nearestStops[(self.tableView.indexPathForSelectedRow! as NSIndexPath).row]
    }
}
