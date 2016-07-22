import WatchKit
import Foundation
import WatchConnectivity

public class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var nearestStopsTable: WKInterfaceTable!

    var nearestStops = [String: String]()

    var lat: Double = 0
    var lon: Double = 0

    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activateSession()
            }
        }
    }

    override public func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let row = table.rowControllerAtIndex(rowIndex) as! NearestStopsRow

        self.pushControllerWithName("NextDeparturesInterfaceController", context: ["stopCode": row.code])
    }
    
    override public func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()

            if(!WCSession.defaultSession().reachable) {
                NSLog("Watch connectivity session is not reachable")
            }
            if(session!.iOSDeviceNeedsUnlockAfterRebootForReachability){
                NSLog("iOS device needs unlock for reachability")
                self.presentAlert(Const.UNLOCK_IPHONE_TITLE, message: Const.UNLOCK_IPHONE_MSG)
            }

            session?.sendMessage(
                ["wakeUp": "wakeUp"],
                replyHandler: {
                    m in NSLog("iOS companion app running")
                },
                errorHandler: {
                    m in NSLog("Error waking up iOS companion app: " + m.description)
            })
        }
    }

    public func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        NSLog("Received message from iOS companion app")
        let stops: [Stop] = nearestStopsFromWatchConnectivityMessage(message)

        if(stops.count == 0) {
            self.presentAlert(Const.NO_STOPS_TITLE, message: Const.NO_STOPS_MSG)
            nearestStopsTable.setNumberOfRows(0, withRowType: "nearestStopsRow")
        } else {
            self.updateInterface(stops)
        }
    }

    @IBAction func refreshInterface() -> Void {
        NSLog("Sending refresh message to iOS companion app")
        session?.sendMessage(["refresh": true],
            replyHandler: {message in
                self.updateInterface(self.nearestStopsFromWatchConnectivityMessage(message))
            },
            errorHandler: {error in
                NSLog("Error sending refresh message to iOS companion app: " + error.description)
            }
        )
    }

    private func nearestStopsFromWatchConnectivityMessage(message: [String: AnyObject]) -> [Stop] {
        if let stopsDict = message["nearestStops"] as? [[String: AnyObject]] {
            var stops: [Stop] = []

            stopsDict.forEach({dict in
                if let name = dict["name"] as? String,
                let distance = dict["distance"] as? Int,
                let codeLong = dict["codeLong"] as? String,
                let codeShort = dict["codeShort"] as? String {
                    let stop = Stop(
                        name: name,
                        distance: distance,
                        codeLong: codeLong,
                        codeShort: codeShort
                    )
                    stops.append(stop)
                } else {
                    NSLog("Could not parse nearest stops from Watch Connectivity message")
                }
            })
            return stops
        } else {
            NSLog("No nearest stops dictionary found in Watch Connectivity message")
            return []
        }
    }

    private func updateInterface(nearestStops: [Stop]) -> Void {
        NSLog("Updating Nearest Stops interface")
        nearestStopsTable.setNumberOfRows(nearestStops.count, withRowType: "nearestStopsRow")
        var i: Int = 0
        for stop in nearestStops {
            let row: AnyObject? = nearestStopsTable.rowControllerAtIndex(i)
            let nearestStopRow = row as! NearestStopsRow

            nearestStopRow.code = stop.codeLong
            nearestStopRow.stopName.setText(stop.name)
            nearestStopRow.stopCode.setText(stop.codeShort)
            nearestStopRow.distance.setText(String(stop.distance) + " m")
            i += 1
        }
    }

    override public func willActivate() {
        session = WCSession.defaultSession()
        refreshInterface()
    }
}
