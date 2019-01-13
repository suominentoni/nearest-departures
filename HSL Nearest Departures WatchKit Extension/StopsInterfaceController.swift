//
//  StopsInterfaceController.swift
//  HSL Nearest Departures WatchKit Extension
//
//  Created by Toni Suominen on 15/12/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import Foundation
import WatchKit
import NearestDeparturesDigitransit

open class StopsInterfaceController: WKInterfaceController, CLLocationManagerDelegate {
    var stops: [Stop] = []
    @IBOutlet var FavoriteStopsTable: WKInterfaceTable!
    @IBOutlet var FavoriteLoadingIndicator: WKInterfaceLabel!

    override open func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        FavoriteStopsTable.performSegue(forRow: rowIndex)
    }

    open override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        if let row = table.rowController(at: rowIndex) as? NearestStopsRow {
            return ["stopCode": row.code]
        }
        return nil
    }

    open override func awake(withContext context: Any?) {
        self.setTitle(NSLocalizedString("FAVORITES", comment: ""))
    }

    open override func didAppear() {
        super.didAppear()
        self.initTimer()
        let stopCodes = WatchSessionManager.sharedManager.userInfo
        print("FAV: got stop codes \(stopCodes)")
        TransitData.stopsByCodes(codes: stopCodes, callback: {stops, error in
            self.updateInterface(stops)
        })
    }

    fileprivate func updateInterface(_ stops: [Stop]) -> Void {
        FavoriteLoadingIndicator.setHidden(true)
        hideLoadingIndicator()
        self.stops = stops
        FavoriteStopsTable.setNumberOfRows(stops.count, withRowType: "nearestStopsRow")
        if(stops.count == 0) {
            self.presentAlert(NSLocalizedString("NO_STOPS_TITLE", comment: ""), message: NSLocalizedString("NO_STOPS_GENERIC", comment: ""))
        } else {
            var i: Int = 0
            for stop in stops {
                let stopRow = FavoriteStopsTable.rowController(at: i) as! NearestStopsRow
                stopRow.code = stop.codeLong
                stopRow.stopName.setText(stop.name)
                stopRow.stopCode.setText(stop.codeShort)
                i += 1
            }
        }
    }

    override open func willDisappear() {
        invalidateTimer()
    }

    fileprivate func showLoadingIndicator() {
        initTimer()
        self.FavoriteLoadingIndicator.setHidden(false)
    }

    fileprivate func hideLoadingIndicator() {
        self.FavoriteLoadingIndicator.setHidden(true)
    }

    var counter = 1
    var timer: Timer = Timer()

    func initTimer() {
        invalidateTimer()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(StopsInterfaceController.updateLoadingIndicatorText), userInfo: nil, repeats: true)
        self.timer.fire()
    }

    func invalidateTimer() {
        self.timer.invalidate()
    }

    @objc fileprivate func updateLoadingIndicatorText() {
        self.counter == 4 ? (self.counter = 1) : (self.counter = self.counter + 1)
        let dots = (1...counter).map({_ in "."}).joined()
        self.FavoriteLoadingIndicator.setText(dots)
    }
}
