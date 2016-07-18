//
//  NearestStopsTableViewController.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 14/02/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import UIKit

class NearestStopsTableViewController: UITableViewController {

    private  var nearestStops: [Stop] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func reloadWithNewData(nearestStops: [Stop]) {
        self.nearestStops = nearestStops

        if(self.nearestStops.count == 0 ) {
            let alert = UIAlertController(title: "Ei pysäkkejä", message: "Lähistöltä ei löytynyt pysäkkejä", preferredStyle: UIAlertControllerStyle.Alert)
            let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)

            alert.addAction(alertAction)
            self.presentViewController(alert, animated: true, completion: nil)
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
        return self.nearestStops.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NearestStopCell", forIndexPath: indexPath) as! NearestStopsCell
        let stop = self.nearestStops[indexPath.row]

        cell.code.text = stop.codeShort
        cell.name.text = stop.name
        cell.distance.text = String(stop.distance) + " m"

        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nextDeparturesViewController = segue.destinationViewController as! NextDeparturesTableViewController
        nextDeparturesViewController.stopCode = self.nearestStops[self.tableView.indexPathForSelectedRow!.row].codeLong
    }
}
