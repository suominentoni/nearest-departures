import UIKit
import GoogleMobileAds
import NearestDeparturesDigitransit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var enableAds = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if (ProcessInfo.processInfo.arguments.contains("UITEST")) {
            let appDomain = Bundle.main.bundleIdentifier
            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
            enableAds = true // Test ads for now, despite them being removed from production version
        }
        if (ProcessInfo.processInfo.arguments.contains("UITEST_ERRONEOUSDATA")) {
            FavoriteStops.add(Stop(name: "Foo", lat: 0.0, lon: 0.0, distance: "0", codeLong: "invalid", codeShort: "invalid", departures: [Departure]()))
        }
        if(enableAds) {
            if (ProcessInfo.processInfo.arguments.contains("HAS_BOUGHT_PREMIUM")) {
                UserDefaults.standard.set(true, forKey: _Products.productId)
            }
            if (ProcessInfo.processInfo.arguments.contains("MOCKIAP")) {
                _Products.store = MockIAPHelper()
            }
            if (ProcessInfo.processInfo.arguments.contains("MOCKIAP_TRANSACTION_FAILS")) {
                _Products.store = MockIAPHelper(transactionFails: true)
            }
            if (ProcessInfo.processInfo.arguments.contains("MOCKIAP_PRODUCT_REQUEST_FAILS")) {
                _Products.store = MockIAPHelper(productsRequestFails: true)
            }
            if (!Products.hasPurchasedPremiumVersion()) {
                Products.loadProducts()
                GADMobileAds.configure(withApplicationID: "ca-app-pub-3940256099942544/2934735716") // SAMPLE
            }
        }
        WatchSessionManager.sharedManager.startSession()
        return true
    }
}
