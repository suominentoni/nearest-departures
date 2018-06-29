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
        self.loadData(callback: {(stops, error) in self.updateUI(stops)})
    }
    
    func loadData(callback: @escaping ([Stop]?, DigitransitError?) -> Void) {
        let stops = FavoriteStops.all()
        HSL.updateDeparturesForStops(stops, callback: {(stops: [Stop], error: DigitransitError?) in
            callback(stops, self.tryGetStopFor(error: error))
        })
        self.updateUI(stops)
    }

    fileprivate func tryGetStopFor(error: DigitransitError?) -> DigitransitError? {
        if error != nil {
            switch error! {
            case DigitransitError.dataFetchingError(let data):
                return DigitransitError.dataFetchingError(id: data.id, stop: FavoriteStops.getBy(data.id))
            default:
                return error
            }
        }
        return nil
    }

    func getTitle() -> String {
        return Const.FAVORITE_STOPS_TITLE
    }
    
    func getNoStopsMessage() -> String {
        return Const.NO_FAVORITE_STOPS_MSG
    }
}
