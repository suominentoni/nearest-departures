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

    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activateSession()
            }
        }
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
        self.updateInterface(message)
    }

    @IBAction func refreshClick() {
        session!.sendMessage(["refresh": true],
            replyHandler: {departureInfo in
                self.updateInterface(departureInfo)
            },
            errorHandler: {error in
                NSLog("Error sending refresh message to iOS companion app: " + error.description)
            })
    }

    private func updateInterface(departureInfo: Dictionary<String, AnyObject>) {
        self.nearestStop.setText(String(departureInfo["stopName"]!))
        self.departureTime.setText(String(departureInfo["departureTime"]!))
        self.lineNumber.setText(String(departureInfo["lineNumber"]!))
        self.destination.setText(String(departureInfo["destination"]!))
    }
}
