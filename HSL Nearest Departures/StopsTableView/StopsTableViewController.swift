//
//  StopsTableViewController.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 30/12/2017.
//  Copyright © 2017 Toni Suominen. All rights reserved.
//

import UIKit
import GoogleMobileAds

class StopsTableViewController: UITableViewController, GADBannerViewDelegate {
    var delegate: StopsTableViewControllerDelegate?
    var stops: [Stop] = []
    fileprivate var hasShortCodes: Bool = false
    var banner: GADBannerView?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 200
        self.refreshControl = UIRefreshControl()

        self.refreshControl?.addTarget(self, action: #selector(StopsTableViewController.loadData), for: UIControl.Event.valueChanged)

        if (self.shouldShowAddBanner()) {
            banner = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
            banner?.delegate = self
            banner?.adUnitID = "ca-app-pub-3940256099942544/2934735716" // SAMPLE
            banner?.rootViewController = self
            banner?.backgroundColor = UIColor.gray
            let request = GADRequest()
            request.testDevices = [ kGADSimulatorID ];
            banner?.load(request)
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.shouldShowAddBanner() ? banner : nil
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.shouldShowAddBanner() && banner != nil
            ? banner!.frame.height
            : 0
    }

    private func shouldShowAddBanner() -> Bool {
        return self.isNearestStopsView() && !Products.hasPurchasedPremiumVersion()
    }

    @objc fileprivate func loadData() {
        let x = self.tableView.center.x
        let y = self.tableView.center.y
        self.tableView.backgroundView = LoadingIndicator(frame: CGRect(x: x-35, y: y-35, width: 70, height: 70))

        self.delegate?.loadData(callback: {(stops: [Stop]?, error: TransitDataError?) in
            if (error != nil) {
                self.displayLoadDataFailedAlert(error: error!)
            } else {
                self.updateUI(stops: stops)
            }
        })
    }

    fileprivate func displayLoadDataFailedAlert(error: TransitDataError) {
        var alert: UIAlertController
        switch error {
        case TransitDataError.dataFetchingError(let data):
            alert = UIAlertController(
                title: NSLocalizedString("DATA_LOAD_FAILED_TITLE", comment: ""),
                message: "\(NSLocalizedString("DATA_LOAD_FAILED_DATA_FETCH_ERROR_MESSAGE", comment: ""))\(stopDescription(stop: data.stop)) \(data.id)",
                preferredStyle: UIAlertController.Style.alert)
        case TransitDataError.favouriteStopsFetchingError:
            alert = UIAlertController(
                title: NSLocalizedString("DATA_LOAD_FAILED_TITLE", comment: ""),
                message: NSLocalizedString("DATA_LOAD_FAILED_FAVOURITE_STOPS_ERROR_MESSAGE", comment: ""),
                preferredStyle: UIAlertController.Style.alert)
        default:
            alert = UIAlertController(
                title: NSLocalizedString("DATA_LOAD_FAILED_TITLE", comment: ""),
                message: NSLocalizedString("DATA_LOAD_FAILED_UNKOWN_MESSAGE", comment: ""),
                preferredStyle: UIAlertController.Style.alert)
        }
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    fileprivate func stopDescription(stop: Stop?) -> String {
        return stop != nil
            ? "\(stop!.name)  \(stop!.codeShort)"
            : ""
    }

    fileprivate func updateUI(stops: [Stop]?) {
        if (stops != nil) {
            self.stops = stops!
            self.hasShortCodes = stops!.hasShortCodes()
            DispatchQueue.main.async(execute: {
                self.tableView.backgroundView = nil
                if (self.stops.count == 0) {
                    let message = self.delegate?.getNoStopsMessage() ?? NSLocalizedString("NO_STOPS_GENERIC", comment: "")
                    self.tableView.backgroundView = NoStopsLabel(parentView: self.view, message: message)
                }
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            })
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StopsTableCell", for: indexPath) as! StopsTableCell
        let stop = stopForIndexPath(indexPath: indexPath)
        let codeWidth: CGFloat = self.hasShortCodes || self.isClusterStopsView() ? 55 : 0
        cell.displayStopData(stop: stop, codeWidth: codeWidth, displayDistance: self.isNearestStopsView())
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
