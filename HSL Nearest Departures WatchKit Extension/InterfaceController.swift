import WatchKit
import Foundation
import CoreLocation

class InterfaceController: WKInterfaceController, CLLocationManagerDelegate {

    @IBOutlet var nearestStop: WKInterfaceLabel!
    @IBOutlet var lineNumber: WKInterfaceLabel!
    @IBOutlet var destination: WKInterfaceLabel!
    @IBOutlet var departureTime: WKInterfaceLabel!

    var locationManager: CLLocationManager!
    var lat: Double = 0
    var lon: Double = 0

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways {
            print("Location auth OK")
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lat = locations.last!.coordinate.latitude
        lon = locations.last!.coordinate.longitude

        print("New location data")

        updateUI()
    }

    override func willActivate() {
        updateUI()
        locationManager.requestLocation()
    }

    private func updateUI() {
        Util.getNearestStopInfo(
            String(lat), lon: String(lon)
        ) {
        (stopInfo:Dictionary) -> Void in
            self.nearestStop.setText(stopInfo["name"])
            Util.getNextDepartureForStop(stopInfo["code"]!, callback: {departureInfo in
                let time = self.formatTimeString(departureInfo["time"]!)
                self.departureTime.setText(time)

                let lineNumber = departureInfo["code"]
                Util.getLineInfo(lineNumber!, callback: {lineInfo in
                    self.lineNumber.setText(lineInfo["code"])
                    self.destination.setText(lineInfo["name"])
                })
            })
        }
    }

    private func formatTimeString(var time:String) -> String {
        time.insert(":", atIndex: time.endIndex.predecessor().predecessor())
        return time
    }

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location Manager Error " + error.description)
    }

    @IBAction func refreshClick() {
        updateUI()
    }
}
