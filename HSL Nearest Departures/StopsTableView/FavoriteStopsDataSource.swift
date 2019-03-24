//
//  FavoriteStopsDataSource.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 06/02/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import NearestDeparturesDigitransit

class FavoriteStopsDataSource: NSObject, StopsTableViewControllerDelegate {
    var updateUI: ([Stop]?) -> Void
    override init() {
        self.updateUI = {_ in }
        super.init()
    }
    
    func viewDidLoad() {
        self.loadData(callback: {(stops, error) in self.updateUI(stops)})
    }

    func loadData(callback: @escaping ([Stop]?, TransitDataError?) -> Void) {
        NSKeyedUnarchiver.setClass(Stop.self, forClassName: "Lahimmat_Lahdot.Stop")
        if let stops = try? FavoriteStops.all() {
            TransitData.updateDeparturesForStops(stops, callback: {(stops: [Stop], error: TransitDataError?) in
                callback(stops, self.tryGetStopFor(error: error))
            })
            self.updateUI(stops)
        } else {
            callback([], TransitDataError.dataFetchingError(id: "", stop: nil))
        }
    }

    fileprivate func tryGetStopFor(error: TransitDataError?) -> TransitDataError? {
        if error != nil {
            switch error! {
            case TransitDataError.dataFetchingError(let data):
                return TransitDataError.dataFetchingError(id: data.id, stop: FavoriteStops.getBy(data.id))
            default:
                return error
            }
        }
        return nil
    }

    func getTitle() -> String {
        return NSLocalizedString("FAVORITE_STOPS_TITLE", comment: "")
    }
    
    func getNoStopsMessage() -> String {
        return NSLocalizedString("NO_FAVORITE_STOPS_MSG", comment: "")
    }
}
