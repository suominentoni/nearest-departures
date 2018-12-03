import UIKit
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if (ProcessInfo.processInfo.arguments.contains("UITEST")) {
            let appDomain = Bundle.main.bundleIdentifier
            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
        }
        if (ProcessInfo.processInfo.arguments.contains("UITEST_ERRONEOUSDATA")) {
            FavoriteStops.add(Stop(name: "Foo", lat: 0, lon: 0, distance: "0", codeLong: "invalid", codeShort: "invalid", departures: []))
        }
        if (ProcessInfo.processInfo.arguments.contains("HAS_BOUGHT_PREMIUM")) {
            UserDefaults.standard.set(true, forKey: Products.productId)
        }
        if (!Products.hasPurchasedPremiumVersion()) {
            Products.loadProducts()
            GADMobileAds.configure(withApplicationID: "ca-app-pub-3940256099942544/2934735716") // SAMPLE
        }
        return true
    }
}
