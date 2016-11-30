import WatchKit
import Foundation

open class NearestStopsInterfaceController: WKInterfaceController, CLLocationManagerDelegate {

    @IBOutlet var nearestStopsTable: WKInterfaceTable!
    @IBOutlet var loadingIndicatorLabel: WKInterfaceLabel!

    var nearestStops = [Stop]()

    var locationManager: CLLocationManager!
    var lat: Double = 0
    var lon: Double = 0

    override open func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let row = table.rowController(at: rowIndex) as! NearestStopsRow
        self.pushController(withName: "NextDeparturesInterfaceController", context: ["stopCode": row.code])
//        let foo = nearestStops[rowIndex].departures as! AnyObject
//        self.pushControllerWithName("NextDeparturesInterfaceController", context: ["departures": foo])
    }

    override open func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.initTimer()

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5

        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined) {
            locationManager.requestWhenInUseAuthorization()
        } else {
            requestLocation()
        }
    }

    open func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        requestLocation()
    }

    func requestLocation() {
        showLoadingIndicator()
        if(CLLocationManager.authorizationStatus() != CLAuthorizationStatus.restricted || CLLocationManager.authorizationStatus() != CLAuthorizationStatus.denied) {
            NSLog("Requesting location")
            locationManager.requestLocation()
        }
    }

    open func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("Location Manager error: " + error.localizedDescription)
        requestLocation()
    }

    open func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NSLog("New location data received")
        let lat = locations.last!.coordinate.latitude
        let lon = locations.last!.coordinate.longitude

        HSL.nearestStopsAndDepartures(lat, lon: lon, callback: updateInterface)
    }

    fileprivate func updateInterface(_ nearestStops: [Stop]) -> Void {
        NSLog("Updating Nearest Stops interface")

        loadingIndicatorLabel.setHidden(true)
        hideLoadingIndicator()
        self.nearestStops = nearestStops
        nearestStopsTable.setNumberOfRows(nearestStops.count, withRowType: "nearestStopsRow")

        if(nearestStops.count == 0) {
            self.presentAlert(Const.NO_STOPS_TITLE, message: Const.NO_STOPS_MSG)
        } else {
            var i: Int = 0
            for stop in nearestStops {
                let nearestStopRow = nearestStopsTable.rowController(at: i) as! NearestStopsRow

                nearestStopRow.code = stop.codeLong
                nearestStopRow.stopName.setText(stop.name)
                nearestStopRow.stopCode.setText(stop.codeShort)
                nearestStopRow.distance.setText(String(stop.distance) + " m")
                i += 1
            }
        }
    }

    override open func willDisappear() {
        invalidateTimer()
    }

    override open func willActivate() {
        requestLocation()
    }

    fileprivate func showLoadingIndicator() {
        initTimer()
        self.loadingIndicatorLabel.setHidden(false)
    }

    fileprivate func hideLoadingIndicator() {
        self.loadingIndicatorLabel.setHidden(true)
    }

    @IBAction func refreshClick() {
        requestLocation()
    }

    var counter = 1
    var timer: Timer = Timer()

    func initTimer() {
        invalidateTimer()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(NearestStopsInterfaceController.updateLoadingIndicatorText), userInfo: nil, repeats: true)
        self.timer.fire()
    }

    func invalidateTimer() {
        self.timer.invalidate()
    }

    @objc fileprivate func updateLoadingIndicatorText() {
        self.counter == 4 ? (self.counter = 1) : (self.counter = self.counter + 1)
        let dots = (1...counter).map({_ in "."}).joined()

        self.loadingIndicatorLabel.setText(dots)
    }
}
