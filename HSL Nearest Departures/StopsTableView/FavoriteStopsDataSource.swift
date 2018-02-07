//
//  FavoriteStopsDataSource.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 06/02/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

class FavoriteStopsDataSource: NSObject, StopsTableViewControllerDelegate {
    var updateUI: ([Stop]?) -> Void

    override init() {
        self.updateUI = {_ in }
        super.init()
    }
    
    func viewDidLoad() {
        self.loadData(callback: {self.updateUI($0)})
    }
    
    func loadData(callback: @escaping ([Stop]?) -> Void) {
        let stops = FavoriteStops.all()
        HSL.updateDeparturesForStops(stops, callback: {stops in
            callback(stops)
        })
        self.updateUI(stops)
    }
    
    func getTitle() -> String {
        return Const.FAVORITE_STOPS_TITLE
    }
    
    func getNoStopsMessage() -> String {
        return Const.NO_FAVORITE_STOPS_MSG
    }
}
