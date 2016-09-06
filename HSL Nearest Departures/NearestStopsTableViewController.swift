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

    private var nearestStops: [Stop] = []
    private var hasShortCodes: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5

        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined) {
            locationManager.requestWhenInUseAuthorization()
        }

        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.Restricted || CLLocationManager.authorizationStatus() != CLAuthorizationStatus.Denied) {
            locationManager.startUpdatingLocation()
        }

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(NearestStopsTableViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if(status != CLAuthorizationStatus.Restricted || status != CLAuthorizationStatus.Denied) {
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lat = locations.last!.coordinate.latitude
        lon = locations.last!.coordinate.longitude

        NSLog("Got new location data")
        reloadData()
    }

    @objc private func refresh() {
        reloadData()
    }

    private func reloadData() {
        let x = self.tableView.center.x
        let y = self.tableView.center.y
        self.tableView.backgroundView = LoadingIndicator(frame: CGRect(x: x-35, y: y-35, width: 70 , height: 70))
        HSL.nearestStopsAndDepartures(lat, lon: lon, callback: {(stops: [Stop]) in
            self.nearestStops = stops
            self.hasShortCodes = Tools.hasShortCodes(stops)
            dispatch_async(dispatch_get_main_queue(), {
                if(self.nearestStops.count == 0 ) {
                    let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
                    messageLabel.textAlignment = NSTextAlignment.Center
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

    override func viewDidAppear(animated: Bool) {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nearestStops.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NearestStopCell", forIndexPath: indexPath) as! NearestStopsCell
        let stop = self.nearestStops[indexPath.row]

        cell.code.text = stop.codeShort
        let codeWidthConstraint = NSLayoutConstraint(item: cell.code, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0)
        self.hasShortCodes
            ? (codeWidthConstraint.constant = 50)
            : (codeWidthConstraint.constant = 0)
        cell.code.addConstraint(codeWidthConstraint)

        cell.name.text = stop.name
        cell.distance.text = String(stop.distance) + " m"

        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nextDeparturesViewController = segue.destinationViewController as! NextDeparturesTableViewController
        nextDeparturesViewController.stop = self.nearestStops[self.tableView.indexPathForSelectedRow!.row]
    }
}
