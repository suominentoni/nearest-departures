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

    override func viewDidAppear(animated: Bool) {
        self.favoriteStops = FavoriteStops.all()
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
