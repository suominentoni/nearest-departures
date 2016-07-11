//
//  NearestStopsTableViewController.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 14/02/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import UIKit

class NearestStopsTableViewController: UITableViewController {

    private  var nearestStops: [NSDictionary] = [NSDictionary()]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func reloadWithNewData(nearestStops: [NSDictionary]) {
        self.nearestStops = nearestStops

        if(self.nearestStops.count == 0 ) {
            let alert = UIAlertController(title: "Ei pysäkkejä", message: "Ei pysäkkejä lähistöllä", preferredStyle: UIAlertControllerStyle.Alert)
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

        if let code = stop["codeShort"] as? String,
           let name = stop["name"] as? String,
           let distance = stop["distance"] as? String {
            cell.code.text = code
            cell.name.text = name
            cell.distance.text = distance + " m"
        }

        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if let stopCode = self.nearestStops[self.tableView.indexPathForSelectedRow!.row]["code"] as? String {
            let nextDeparturesViewController = segue.destinationViewController as! NextDeparturesTableViewController
            nextDeparturesViewController.stopCode = stopCode
        }

    }
}
