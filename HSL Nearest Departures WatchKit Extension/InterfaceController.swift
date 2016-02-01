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

        session!.sendMessage(
            ["stopCode": row.code],
            replyHandler: {message in
                let nextDepartures = message["nextDepartures"] as! NSArray
                self.pushControllerWithName("NextDeparturesInterfaceController", context: ["nextDepartures": nextDepartures])
            },
            errorHandler: {m in NSLog("Error getting next departures from companion app")})

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
            }


            session!.sendMessage(
                ["wakeUp": "wakeUp"],
                replyHandler: {
                    m in NSLog("iOS companion app running")
                },
                errorHandler: {
                    m in NSLog("Error waking up iOS companion app: " + m.description)
            })
        }
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status != .AuthorizedAlways {
            NSLog("App is not authorized to use location services")
        }
    }

    public func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        NSLog("Received departure information from iOS companion app")
        if let nearestStops = message["nearestStops"] as? [NSDictionary] {
            self.updateInterface(nearestStops)
        }
    }

    @IBAction func refreshInterface() {
        session!.sendMessage(["refresh": true],
            replyHandler: {message in
                self.updateInterface(message["nearestStops"] as! [NSDictionary])
            },
            errorHandler: {error in
                NSLog("Error sending refresh message to iOS companion app: " + error.description)
            }
        )
    }

    private func updateInterface(nearestStops: [NSDictionary]) {
        nearestStopsTable.setNumberOfRows(nearestStops.count, withRowType: "nearestStopsRow")
        var i: Int = 0
        for info in nearestStops {
            let row: AnyObject? = nearestStopsTable.rowControllerAtIndex(i)
            let nearestStopRow = row as! NearestStopsRow

            if let name = info["name"] as? String,
            let code = info["code"] as? String,
            let codeShort = info["codeShort"] as? String,
            let distance = info["distance"] as? String {
                nearestStopRow.code = code
                nearestStopRow.stopName.setText(name)
                nearestStopRow.stopCode.setText(codeShort)
                nearestStopRow.distance.setText(distance + " m")
                i++
            }
        }
    }

    override public func willActivate() {
        refreshInterface()
    }
}
