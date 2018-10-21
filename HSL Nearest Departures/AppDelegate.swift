import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FavoriteStops.migrateToAgencyPrefixedCodeFormat()
        if (ProcessInfo.processInfo.arguments.contains("UITEST")) {
            let appDomain = Bundle.main.bundleIdentifier
            UserDefaults.standard.removePersistentDomain(forName: appDomain!)
        }
        if (ProcessInfo.processInfo.arguments.contains("UITEST_ERRONEOUSDATA")) {
            FavoriteStops.add(Stop(name: "Foo", lat: 0, lon: 0, distance: "0", codeLong: "invalid", codeShort: "invalid", departures: []))
        }
        return true
    }
}
