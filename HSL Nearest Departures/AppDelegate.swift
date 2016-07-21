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

        HSL.getNearestStops(lat, lon: lon, successCallback: updateViews)
    }

    private func updateViews(nearestStops: [Stop]) {
        if let navController = self.window!.rootViewController! as? UINavigationController {
            if let viewController = navController.viewControllers[0] as? NearestStopsTableViewController {
                dispatch_async(dispatch_get_main_queue(), {
                    viewController.reloadWithNewData(nearestStops)
                })
            }
        }

        if session != nil && session!.reachable {
            sendNearestStopsToWatch(nearestStops)
        }
    }

    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: [String: AnyObject] -> Void) {
        if let _ = message["refresh"] as? Bool {
            HSL.getNearestStops(lat, lon: lon, successCallback: {(nearestStops: [Stop]) in
                let stopsDict = nearestStops.map({stop in stop.toDict()})
                replyHandler(["nearestStops": stopsDict])
            })
        }
        else if let stopCode = message["stopCode"] as? String {
            HSL.getNextDeparturesForStop(stopCode, callback: {(nextDepartures: [Departure]) -> Void in
                NSLog("Replying to watch message with next departures for stop " + stopCode)
                let depsDict = nextDepartures.map({ dep in return dep.toDict() })
                replyHandler(["nextDepartures": depsDict])
            })
        }
        else if let longCode = message["longCode"] as? String {
            HSL.getLineInfo(longCode, callback: {(lineInfo: NSDictionary) -> Void in
                replyHandler(["lineInfo": lineInfo])
            })
        }
    }

    private func sendNearestStopsToWatch(nearestStops: [Stop]) {
        NSLog("Sending nearest stops to Apple Watch")
        let stopDicts = nearestStops.map({stop in return stop.toDict()})
        self.session?.sendMessage(["nearestStops": stopDicts],
            replyHandler: {r in NSLog("Got reply")},
            errorHandler: { error in
                NSLog("Error sending departure information to Apple Watch: " + error.description)
        })
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
