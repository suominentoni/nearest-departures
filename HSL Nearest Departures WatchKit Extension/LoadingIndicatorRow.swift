//
//  LoadingIndicatorRow.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 13/08/16.
//  Copyright © 2016 Toni Suominen. All rights reserved.
//

import Foundation
import WatchKit

class LoadingIndicatorRow: NSObject {

    @IBOutlet var loadingIndicatorLabel: WKInterfaceLabel! {
        didSet {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(LoadingIndicatorRow.updateLoadingIndicatorText), userInfo: nil, repeats: true)
            self.timer?.fire()
        }
    }
    var counter = 1
    var timer: NSTimer? = NSTimer()

    deinit {
        self.timer?.invalidate()
    }

    func deinitTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }

    @objc private func updateLoadingIndicatorText() {
        self.counter == 3 ? (self.counter = 1) : (self.counter = self.counter + 1)
        var dots = ""
        for _ in 1...counter {
            dots.append(Character("."))
        }
        self.loadingIndicatorLabel.setText(dots)
    }
}