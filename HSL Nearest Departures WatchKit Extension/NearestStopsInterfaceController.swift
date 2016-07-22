import WatchKit
import Foundation
import WatchConnectivity

public class NearestStopsInterfaceController: WKInterfaceController, WCSessionDelegate, CLLocationManagerDelegate {

    @IBOutlet var nearestStopsTable: WKInterfaceTable!

    var timer: NSTimer?

    var nearestStops = [Stop]()

    var locationManager: CLLocationManager!
    var lat: Double = 0
    var lon: Double = 0

    override public func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let row = table.rowControllerAtIndex(rowIndex) as! NearestStopsRow

        self.pushControllerWithName("NextDeparturesInterfaceController", context: ["stopCode": row.code])
    }

    override public func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.requestLocation()
    }

    func requestLocation() {
        NSLog("Requesting location")
        locationManager.requestLocation()
    }

    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("Location Manager error: " + error.localizedDescription)
    }

    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLat = locations.last!.coordinate.latitude
        let newLon = locations.last!.coordinate.longitude

        if(lat != newLat || lon != newLon) {
            NSLog("Got new location data")
            lat = newLat
            lon = newLon
            HSL.getNearestStops(lat, lon: lon, successCallback: updateInterface)
        } else {
            NSLog("Got same location data")
        }
    }

    private func updateInterface(nearestStops: [Stop]) -> Void {
        NSLog("Updating Nearest Stops interface")

        self.nearestStops = nearestStops
        nearestStopsTable.setNumberOfRows(nearestStops.count, withRowType: "nearestStopsRow")

        if(nearestStops.count == 0) {
            self.presentAlert(Const.NO_STOPS_TITLE, message: Const.NO_STOPS_MSG)
        } else {
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

    public override func willDisappear() {
        NSLog("Invalidating timer")
        timer?.invalidate()
        timer = nil
    }

    override public func willActivate() {
        requestLocation()
        NSLog("Creating timer")
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(NearestStopsInterfaceController.requestLocation), userInfo: nil, repeats: true)
    }

    @IBAction func refreshClick() {
        requestLocation()
    }
}
