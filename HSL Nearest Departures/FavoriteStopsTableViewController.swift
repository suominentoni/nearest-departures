//
//  FavoriteStopsTableViewController.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 07/08/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import UIKit

class FavoriteStopsTableViewController: UITableViewController {

    private var favoriteStops: [Stop] = []

    override func viewDidLoad() {
        self.navigationItem.title = "Suosikkipysäkkisi"
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200


        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(FavoriteStopsTableViewController.reloadData), forControlEvents: UIControlEvents.ValueChanged)
    }

    @objc private func reloadData() {

        self.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        let x = self.tableView.center.x
        let y = self.tableView.center.y
        self.tableView.backgroundView = LoadingIndicator(frame: CGRect(x: x-35, y: y-35, width: 70 , height: 70))

        self.favoriteStops = FavoriteStops.all()
        if(self.favoriteStops.count == 0 ) {
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
            messageLabel.textAlignment = NSTextAlignment.Center
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favoriteStops.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NearestStopCell", forIndexPath: indexPath) as! NearestStopsCell
        let stop = self.favoriteStops[indexPath.row]

        cell.code.text = stop.codeShort
        cell.name.text = stop.name

        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nextDeparturesViewController = segue.destinationViewController as! NextDeparturesTableViewController
        nextDeparturesViewController.stop = self.favoriteStops[self.tableView.indexPathForSelectedRow!.row]
    }
}