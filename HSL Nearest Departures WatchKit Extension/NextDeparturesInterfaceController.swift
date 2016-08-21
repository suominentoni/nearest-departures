import WatchKit
import Foundation
import WatchConnectivity

class NextDeparturesInterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var nextDeparturesTable: WKInterfaceTable!
    @IBOutlet var loadingIndicatorLabel: WKInterfaceLabel!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.initLoadingIndicatorTimer()

        if let code = context!["stopCode"] as? String {
            showLoadingIndicator()
            HSL.departuresForStop("HSL:" + code, callback: updateInterface)
        }
//        if let departures = context!["departures"] as? [Departure] {
//            showLoadingIndicator()
//            updateInterface(departures)
//        }
    }

    private func updateInterface(nextDepartures: [Departure]) -> Void {
        NSLog("Updating Next Departures interface")
        hideLoadingIndicator()
        nextDeparturesTable.setNumberOfRows(nextDepartures.count, withRowType: "nextDepartureRow")

        if(nextDepartures.count == 0) {
            self.presentAlert(Const.NO_DEPARTURES_TITLE, message: Const.NO_DEPARTURES_MSG)
        } else {
            var i: Int = 0
            for departure in nextDepartures {
                let row: AnyObject? = nextDeparturesTable.rowControllerAtIndex(i)
                let nextDepartureRow = row as! NextDeparturesRow
                nextDepartureRow.time.setAttributedText(Tools.formatDepartureTime(departure.scheduledDepartureTime, real: departure.realDepartureTime))
                nextDepartureRow.code.setText(departure.line.codeShort != nil ? departure.line.codeShort : departure.line.codeLong)
                nextDepartureRow.destination.setText(departure.line.destination)
                i += 1
            }
        }
    }

    override func willDisappear() {
        invalidateTimer()
    }

    private func showLoadingIndicator() {
        loadingIndicatorLabel.setHidden(false)
    }

    private func hideLoadingIndicator() {
        self.loadingIndicatorLabel.setHidden(true)
    }

    var counter = 1
    var timer: NSTimer? = NSTimer()

    func initLoadingIndicatorTimer() {
        invalidateTimer()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(NextDeparturesInterfaceController.updateLoadingIndicatorText), userInfo: nil, repeats: true)
        self.timer?.fire()
    }

    func invalidateTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }

    @objc private func updateLoadingIndicatorText() {
        self.counter == 4 ? (self.counter = 1) : (self.counter = self.counter + 1)
        var dots = ""
        for _ in 1...counter {
            dots.append(Character("."))
        }
        self.loadingIndicatorLabel.setText(dots)
    }
}
