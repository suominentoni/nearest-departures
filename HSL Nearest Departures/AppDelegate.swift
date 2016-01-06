import UIKit
import WatchConnectivity
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate, CLLocationManagerDelegate {

    var window: UIWindow?

    var locationManager: CLLocationManager!
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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.startUpdatingLocation()

        if WCSession.isSupported() {
            NSLog("Watch connectivity session is supported. Setting session object.")
            session = WCSession.defaultSession()
        }

        return true
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lat = locations.last!.coordinate.latitude
        lon = locations.last!.coordinate.longitude

        NSLog("Got new location data")

        getDepartureInfo(sendDepartureInfoToWatch)
    }

    private func getDepartureInfo(successCallback: (departureInfo: Dictionary<String, AnyObject>) -> Void) {
        var stopName = ""
        var departureTime = ""
        var lineNumber = ""
        var destination = ""

        HSL.getNearestStopInfo(String(lat), lon: String(lon)) {
        (stopInfo:Dictionary) -> Void in
            stopName = (stopInfo["name"])!
            HSL.getNextDepartureForStop(stopInfo["code"]!, callback: {departureInfo in
                departureTime = self.formatTimeString(departureInfo["time"]!)

                HSL.getLineInfo(departureInfo["code"]!, callback: {lineInfo in
                    lineNumber = lineInfo["code"]!
                    destination = lineInfo["name"]!

                    let departureInfo = [
                        "stopName": stopName,
                        "departureTime": departureTime,
                        "lineNumber": lineNumber,
                        "destination": destination
                    ]

                    successCallback(departureInfo: departureInfo)
                })
            })
        }
    }

    private func sendDepartureInfoToWatch(departureInfo: Dictionary<String, AnyObject>) {
        NSLog("Sending departure information to Apple Watch")
        self.session!.sendMessage(departureInfo,
            replyHandler: {r in NSLog("Got reply")},
            errorHandler: { error in
                NSLog("Error sending departure information to Apple Watch: " + error.description)
        })
    }

    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        if let _ = message["refresh"] as? Bool {
            getDepartureInfo(sendDepartureInfoToWatch)
        }
    }

    private func formatTimeString(var time:String) -> String {
        time.insert(":", atIndex: time.endIndex.predecessor().predecessor())
        return time
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.

       // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
