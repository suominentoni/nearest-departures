import WatchKit
import Foundation
import CoreLocation
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
            session!.sendMessage(
                ["wakeUp": "wakeUp"],
                replyHandler: {m in NSLog("iOS companion app running")},
                errorHandler: {m in NSLog("Error waking up iOS companion app")})
        }
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status != .AuthorizedAlways {
            NSLog("App is not authorized to use location services")
        }
    }

    public func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        NSLog("Received departure information from iOS companion app")
        nearestStops = message["nearestStops"] as! [String: String]
        self.updateInterface(nearestStops)
    }

    @IBAction func refreshClick() {
        session!.sendMessage(["refresh": true],
            replyHandler: {message in
                self.updateInterface(message["nearestStops"] as! [String: String])
            },
            errorHandler: {error in
                NSLog("Error sending refresh message to iOS companion app: " + error.description)
            }
        )
    }

    private func updateInterface(nearestStops: [String: String]) {
        nearestStopsTable.setNumberOfRows(nearestStops.count, withRowType: "nearestStopsRow")
        var i: Int = 0
        for (code, name) in nearestStops {
            let row: AnyObject? = nearestStopsTable.rowControllerAtIndex(i)
            let nearestStopRow = row as! NearestStopsRow
            nearestStopRow.code = code
            nearestStopRow.stopName.setText(name)
            nearestStopRow.stopCode.setText(code)
            i++
        }
    }
}
