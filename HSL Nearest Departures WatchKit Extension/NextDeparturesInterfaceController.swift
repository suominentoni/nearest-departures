import WatchKit
import Foundation

class NextDeparturesInterfaceController: WKInterfaceController {

    @IBOutlet var nextDeparturesTable: WKInterfaceTable!
    @IBOutlet var loadingIndicatorLabel: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.initLoadingIndicatorTimer()

        if let contextDict = context as? [String: AnyObject],
            let code = contextDict["stopCode"] as? String {
            showLoadingIndicator()
            TransitData.departuresForStop(code, callback: updateInterface)
        }
    }

    fileprivate func updateInterface(_ nextDepartures: [Departure]) -> Void {
        NSLog("Updating Next Departures interface")
        hideLoadingIndicator()
        nextDeparturesTable.setNumberOfRows(nextDepartures.count, withRowType: "nextDepartureRow")

        if(nextDepartures.count == 0) {
            self.presentAlert(NSLocalizedString("NO_DEPARTURES_TITLE", comment: ""), message: NSLocalizedString("NO_DEPARTURES_MSG", comment: ""))
        } else {
            var i: Int = 0
            for departure in nextDepartures {
                let row = nextDeparturesTable.rowController(at: i)
                let nextDepartureRow = row as! NextDeparturesRow
                nextDepartureRow.time.setAttributedText(departure.formattedDepartureTime())
                nextDepartureRow.code.setText(departure.line.codeShort != nil ? departure.line.codeShort : departure.line.codeLong)
                nextDepartureRow.destination.setText(departure.line.destination)
                i += 1
            }
        }
    }

    override func willDisappear() {
        invalidateTimer()
    }

    fileprivate func showLoadingIndicator() {
        loadingIndicatorLabel.setHidden(false)
    }

    fileprivate func hideLoadingIndicator() {
        self.loadingIndicatorLabel.setHidden(true)
    }

    var counter = 1
    var timer: Timer = Timer()

    func initLoadingIndicatorTimer() {
        invalidateTimer()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(NextDeparturesInterfaceController.updateLoadingIndicatorText), userInfo: nil, repeats: true)
        self.timer.fire()
    }

    func invalidateTimer() {
        self.timer.invalidate()
    }

    @objc fileprivate func updateLoadingIndicatorText() {
        self.counter == 4 ? (self.counter = 1) : (self.counter = self.counter + 1)
        let dots = (1...counter).map({_ in "."}).joined()

        self.loadingIndicatorLabel.setText(dots)
    }
}
