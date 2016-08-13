import WatchKit
import Foundation
import WatchConnectivity

public class NearestStopsInterfaceController: WKInterfaceController, WCSessionDelegate, CLLocationManagerDelegate {

    @IBOutlet var nearestStopsTable: WKInterfaceTable!

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
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5

        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined) {
            locationManager.requestWhenInUseAuthorization()
        } else {
            requestLocation()
        }
    }

    public func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        requestLocation()
    }

    func requestLocation() {
        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.Restricted || CLLocationManager.authorizationStatus() != CLAuthorizationStatus.Denied) {
            NSLog("Requesting location")
            locationManager.requestLocation()
        }
    }

    public func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("Location Manager error: " + error.localizedDescription)
        requestLocation()
    }

    public func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NSLog("New location data received")
        let lat = locations.last!.coordinate.latitude
        let lon = locations.last!.coordinate.longitude

        HSL.getNearestStops(lat, lon: lon, successCallback: updateInterface)
    }

    private func updateInterface(nearestStops: [Stop]) -> Void {
        NSLog("Updating Nearest Stops interface")

        removeLoadingIndicator()
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

    override public func willActivate() {
        nearestStopsTable.insertRowsAtIndexes(NSIndexSet(index: 0), withRowType: "loadingIndicatorRow")
        requestLocation()
    }

    public override func willDisappear() {
        removeLoadingIndicator()
    }

    private func removeLoadingIndicator() {
        if let loadingIndicatorRow = nearestStopsTable.rowControllerAtIndex(0) as? LoadingIndicatorRow {
            loadingIndicatorRow.deinitTimer() // timer not invalidated automatically on row removal
            nearestStopsTable.removeRowsAtIndexes(NSIndexSet(index: 0))
        }
    }

    @IBAction func refreshClick() {
        requestLocation()
    }
}
