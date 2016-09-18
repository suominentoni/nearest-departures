//
//  FavoriteStopsTableViewController.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 07/08/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import UIKit

class FavoriteStopsTableViewController: UITableViewController {

    fileprivate var favoriteStops: [Stop] = []
    fileprivate var hasShortCodes: Bool = false

    override func viewDidLoad() {
        self.navigationItem.title = "Suosikkipysäkkisi"
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200


        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(FavoriteStopsTableViewController.reloadData), for: UIControlEvents.valueChanged)
    }

    @objc fileprivate func reloadData() {

        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        let x = self.tableView.center.x
        let y = self.tableView.center.y
        self.tableView.backgroundView = LoadingIndicator(frame: CGRect(x: x-35, y: y-35, width: 70 , height: 70))

        self.favoriteStops = FavoriteStops.all()
        self.hasShortCodes = Tools.hasShortCodes(stops: self.favoriteStops)
        if(self.favoriteStops.count == 0 ) {
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoriteStops.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearestStopCell", for: indexPath) as! NearestStopsCell
        let stop = self.favoriteStops[(indexPath as NSIndexPath).row]

        cell.code.text = stop.codeShort

        let codeWidthConstraint = NSLayoutConstraint(item: cell.code, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        self.hasShortCodes
            ? (codeWidthConstraint.constant = 55)
            : (codeWidthConstraint.constant = 0)
        cell.code.addConstraint(codeWidthConstraint)

        cell.name.text = stop.name

        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextDeparturesViewController = segue.destination as! NextDeparturesTableViewController
        nextDeparturesViewController.stop = self.favoriteStops[(self.tableView.indexPathForSelectedRow! as NSIndexPath).row]
    }
}
