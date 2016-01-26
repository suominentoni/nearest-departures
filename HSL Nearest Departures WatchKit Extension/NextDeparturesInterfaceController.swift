import WatchKit
import Foundation


class NextDeparturesInterfaceController: WKInterfaceController {

    @IBOutlet var nextDeparturesTable: WKInterfaceTable!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if let nextDepartures = context!["nextDepartures"] as? NSArray {
            updateView(nextDepartures)
        }

        // Configure interface objects here.
    }

    private func updateView(nextDepartures: NSArray) {
        NSLog("Update view")
        nextDeparturesTable.setNumberOfRows(nextDepartures.count, withRowType: "nextDepartureRow")

        var i: Int = 0
        for departure in nextDepartures {
            if let time = departure["time"] as? String,
            let code = departure["code"] as? String {
                let row: AnyObject? = nextDeparturesTable.rowControllerAtIndex(i)
                let nextDepartureRow = row as! NextDeparturesRow
                nextDepartureRow.time.setText(time)
                nextDepartureRow.code.setText(code)
                i++
            }
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
