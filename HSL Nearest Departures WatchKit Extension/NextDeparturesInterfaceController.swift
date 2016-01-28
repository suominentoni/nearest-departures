import WatchKit
import Foundation
import WatchConnectivity

class NextDeparturesInterfaceController: WKInterfaceController {

    var connectivitySession: WCSession?

    @IBOutlet var nextDeparturesTable: WKInterfaceTable!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        if let rootInterfaceController = WKExtension.sharedExtension().rootInterfaceController as? InterfaceController,
        let session = rootInterfaceController.session {
            connectivitySession = session
        }

        if let nextDepartures = context!["nextDepartures"] as? NSArray {
            updateView(nextDepartures)
        }
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
                if (connectivitySession != nil) {
                    connectivitySession!.sendMessage(["longCode": code],
                        replyHandler: {(message: [String: AnyObject]) -> Void in
                            if let lineInfo = message["lineInfo"] as? NSDictionary,
                            let shortCode = lineInfo["code"] as? String,
                            let name = lineInfo["name"] as? String {
                                nextDepartureRow.code.setText(shortCode)
                                nextDepartureRow.name.setText(name)
                            }
                        },
                        errorHandler: {(error: NSError) -> Void in
                            NSLog("Error sending long code message to companion app")
                        }
                    )
                }
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
