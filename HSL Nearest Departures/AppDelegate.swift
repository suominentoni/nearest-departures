import UIKit
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        //let appDomain = Bundle.main.bundleIdentifier
        //UserDefaults.standard.removePersistentDomain(forName: appDomain!)

        if (ProcessInfo.processInfo.arguments.contains("UITEST")) {
            let appDomain = Bundle.main.bundleIdentifier
            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
        }
        if (ProcessInfo.processInfo.arguments.contains("UITEST_ERRONEOUSDATA")) {
            FavoriteStops.add(Stop(name: "Foo", lat: 0, lon: 0, distance: "0", codeLong: "invalid", codeShort: "invalid", departures: []))
        }
        Products.loadProducts()
        if (!Products.hasPurchasedPremiumVersion()) {
            GADMobileAds.configure(withApplicationID: "ca-app-pub-3940256099942544/2934735716") // SAMPLE
        }
        return true
    }
}
