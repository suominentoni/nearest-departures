//
//  ViewController.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 24/12/15.
//  Copyright © 2015 Toni Suominen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var nearestStop: UILabel!
    @IBOutlet weak var lineNumber: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var departureTime: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateView(departureInfo: Dictionary<String, AnyObject>) {
        self.nearestStop.text = String(departureInfo["stopName"]!)
        self.departureTime.text = String(departureInfo["departureTime"]!)
        self.lineNumber.text = String(departureInfo["lineNumber"]!)
        self.destination.text = String(departureInfo["destination"]!)
    }
}

