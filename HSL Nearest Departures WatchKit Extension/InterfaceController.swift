import WatchKit
import Foundation
import CoreLocation
import WatchConnectivity

public class InterfaceController: WKInterfaceController, WCSessionDelegate {

    @IBOutlet var nearestStop: WKInterfaceLabel!
    @IBOutlet var lineNumber: WKInterfaceLabel!
    @IBOutlet var destination: WKInterfaceLabel!
    @IBOutlet var departureTime: WKInterfaceLabel!

    var lat: Double = 0
    var lon: Double = 0

    override public func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        let session:WCSession
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            session.sendMessage(
                ["wakeUp": "wakeUp"],
                replyHandler: {m in NSLog("Got reply from iOS")},
                errorHandler: {m in NSLog("Error waking up iOS companion app")})
        }
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status != .AuthorizedAlways {
            NSLog("App is not authorized to use location services")
        }
    }

    public func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        NSLog("Received departure information from iOS")
        self.nearestStop.setText(String(message["stopName"]!))
        self.departureTime.setText(String(message["departureTime"]!))
        self.lineNumber.setText(String(message["lineNumber"]!))
        self.destination.setText(String(message["destination"]!))
    }

    @IBAction func refreshClick() {
    }
}
