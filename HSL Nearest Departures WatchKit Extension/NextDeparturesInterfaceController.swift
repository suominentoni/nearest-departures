import WatchKit
import Foundation
import WatchConnectivity

class NextDeparturesInterfaceController: WKInterfaceController, WCSessionDelegate {

    var connectivitySession: WCSession?

    @IBOutlet var nextDeparturesTable: WKInterfaceTable!

    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activateSession()
            }
        }
    }

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        session = WCSession.defaultSession()
        if let rootInterfaceController = WKExtension.sharedExtension().rootInterfaceController as? InterfaceController,
        let session = rootInterfaceController.session {
            connectivitySession = session
        }

        if let code = context!["stopCode"] as? String {
            NSLog("Sending Stop Code message to iOS companion app")
            session?.sendMessage(
                ["stopCode": code],
                replyHandler: {message in
                    self.updateInterface(self.nextDeparturesFromWatchConnectivityMessage(message))
                },
                errorHandler: {m in NSLog("Error getting next departures from companion app")})
        }
    }

    private func nextDeparturesFromWatchConnectivityMessage(message: [String: AnyObject]) -> [Departure] {
        if let depsDict = message["nextDepartures"] as? [[String: AnyObject]] {
            var deps: [Departure] = []

            depsDict.forEach({dict in
                if let line = dict["line"] as? [String: AnyObject],
                let lineCodeLong = line["codeLong"] as? String,
                let lineCodeShort = line["codeShort"] as? String,
                let time = dict["time"] as? String {
                    let dep = Departure(
                        line: Line(codeLong: lineCodeLong, codeShort: lineCodeShort),
                        time: time
                    )
                    deps.append(dep)
                } else {
                    NSLog("Could not next departures from Watch Connectivity message")
                }
            })
            return deps
        } else {
            NSLog("No next departures dictionary found in Watch Connectivity message")
            return []
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
