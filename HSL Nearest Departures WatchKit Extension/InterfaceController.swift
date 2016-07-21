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

            if(!WCSession.defaultSession().reachable) {
                NSLog("Watch connectivity session is not reachable")
            }
            if(session!.iOSDeviceNeedsUnlockAfterRebootForReachability){
                NSLog("iOS device needs unlock for reachability")
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

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status != .AuthorizedAlways {
            NSLog("App is not authorized to use location services")
        }
    }

    public func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        NSLog("Received departure information from iOS companion app")
        self.updateInterface(nearestStopsFromWatchConnectivityMessage(message))
    }

    @IBAction func refreshInterface() -> Void {
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
                }
            })
            return stops
        } else {
            return []
        }
    }

    private func updateInterface(nearestStops: [Stop]) -> Void {
        if(nearestStops.count == 0) {
            let alertAction = WKAlertAction(title: "OK", style: WKAlertActionStyle.Default, handler: {() in })
            self.presentAlertControllerWithTitle("Ei Pysäkkejä", message: "Lähistöltä ei löytynyt pysäkkejä", preferredStyle: WKAlertControllerStyle.Alert, actions: [alertAction])
            nearestStopsTable.setNumberOfRows(0, withRowType: "nearestStopsRow")
        } else {
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
    }

    override public func willActivate() {
        session = WCSession.defaultSession()
        refreshInterface()
    }
}
