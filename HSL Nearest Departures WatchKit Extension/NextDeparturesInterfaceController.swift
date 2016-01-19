//
//  NextDeparturesInterfaceController.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 22/01/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import WatchKit
import Foundation


class NextDeparturesInterfaceController: WKInterfaceController {

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        NSLog("AWAKE" + (context!["foo"] as! String))
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
