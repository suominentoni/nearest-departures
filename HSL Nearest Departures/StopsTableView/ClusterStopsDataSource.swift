//
//  ClusterStopsDataSource.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 06/02/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import Foundation

class ClusterStopsDataSource: NSObject, StopsTableViewControllerDelegate {
    var updateUI: ([Stop]?) -> Void
    let stops: [Stop]

    init(stops: [Stop]) {
        self.updateUI = {_ in }
        self.stops = stops
        super.init()
    }
    
    func viewDidLoad() {
        self.updateUI(self.stops)
    }

    func loadData(callback: @escaping ([Stop]?, TransitDataError?) -> Void) {
        callback(self.stops, nil)
    }

    func getTitle() -> String {
        return NSLocalizedString("STOPS", comment: "")
    }

    func getNoStopsMessage() -> String {
        return NSLocalizedString("NO_STOPS", comment: "")
    }
}
