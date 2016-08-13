import WatchKit
import Foundation
import WatchConnectivity

class NextDeparturesInterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var nextDeparturesTable: WKInterfaceTable!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        if let code = context!["stopCode"] as? String {
            HSL.getNextDeparturesForStop(code, callback: updateInterface)
        }
    }

    private func updateInterface(nextDepartures: [Departure]) -> Void {
        NSLog("Updating Next Departures interface")
        removeLoadingIndicator()
        nextDeparturesTable.setNumberOfRows(nextDepartures.count, withRowType: "nextDepartureRow")

        if(nextDepartures.count == 0) {
            self.presentAlert(Const.NO_DEPARTURES_TITLE, message: Const.NO_DEPARTURES_MSG)
        } else {
            var i: Int = 0
            for departure in nextDepartures {
                let row: AnyObject? = nextDeparturesTable.rowControllerAtIndex(i)
                let nextDepartureRow = row as! NextDeparturesRow
                nextDepartureRow.time.setText(departure.time)
                nextDepartureRow.code.setText(departure.line.codeShort != nil ? departure.line.codeShort : departure.line.codeLong)
                nextDepartureRow.destination.setText(departure.line.destination)
                i += 1
            }
        }
    }

    override func willActivate() {
        nextDeparturesTable.insertRowsAtIndexes(NSIndexSet(index: 0), withRowType: "loadingIndicatorRow")
        super.willActivate()
    }

    override func willDisappear() {
        removeLoadingIndicator()
    }

    private func removeLoadingIndicator() {
        if let loadingIndicatorRow = nextDeparturesTable.rowControllerAtIndex(0) as? LoadingIndicatorRow {
            loadingIndicatorRow.deinitTimer() // timer not invalidated automatically on row removal
            nextDeparturesTable.removeRowsAtIndexes(NSIndexSet(index: 0))
        }
    }
}
