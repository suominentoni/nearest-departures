//
//  NearestStopsRow.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 21/01/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import UIKit
import WatchKit

class NearestStopsRow: NSObject {
    @IBOutlet var stopCode: WKInterfaceLabel!
    @IBOutlet var stopName: WKInterfaceLabel!
    var code = ""
}
