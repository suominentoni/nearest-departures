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
        nextDeparturesTable.setNumberOfRows(nextDepartures.count, withRowType: "nextDepartureRow")

        var i: Int = 0
        for departure in nextDepartures {
            let row: AnyObject? = nextDeparturesTable.rowControllerAtIndex(i)
            let nextDepartureRow = row as! NextDeparturesRow
            nextDepartureRow.time.setText(departure.time)
            nextDepartureRow.code.setText(departure.line.codeShort != nil ? departure.line.codeShort : departure.line.codeLong)
            i += 1
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
