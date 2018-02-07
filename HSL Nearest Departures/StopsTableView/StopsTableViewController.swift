//
//  StopsTableViewController.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 30/12/2017.
//  Copyright © 2017 Toni Suominen. All rights reserved.
//

import UIKit

class StopsTableViewController: UITableViewController {
    var delegate: StopsTableViewControllerDelegate?

    var stops: [Stop] = []
    fileprivate var hasShortCodes: Bool = false

    override func viewDidAppear(_ animated: Bool) {
        loadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if (self.isNearestStopsView()) {
            self.delegate = NearestStopsDataSource()
        } else if (self.isFavoritesStopsView()) {
            self.delegate = FavoriteStopsDataSource()
        } else if (self.isClusterStopsView()) {
            self.delegate = ClusterStopsDataSource(stops: self.stops)
        }

        self.delegate?.updateUI = updateUI
        self.delegate?.viewDidLoad()
        self.navigationItem.title = self.delegate?.getTitle();
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(StopsTableViewController.loadData), for: UIControlEvents.valueChanged)
    }

    @objc fileprivate func loadData() {
        let x = self.tableView.center.x
        let y = self.tableView.center.y
        self.tableView.backgroundView = LoadingIndicator(frame: CGRect(x: x-35, y: y-35, width: 70 , height: 70))

        self.delegate?.loadData(callback: {(stops: [Stop]?) in
            self.updateUI(stops: stops)
        })
    }

    fileprivate func updateUI(stops: [Stop]?) {
        if (stops != nil) {
            DispatchQueue.main.async(execute: {
                self.stops = stops!
                self.hasShortCodes = Tools.hasShortCodes(stops: stops!)
                self.tableView.backgroundView = nil
                if (self.stops.count == 0) {
                    let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
                    messageLabel.textAlignment = NSTextAlignment.center
                    messageLabel.numberOfLines = 0
                    messageLabel.text = self.delegate?.getNoStopsMessage()
                    messageLabel.sizeToFit()
                    self.tableView.backgroundView = messageLabel
                }
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            })
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