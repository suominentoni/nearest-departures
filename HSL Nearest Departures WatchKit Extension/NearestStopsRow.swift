import UIKit
import WatchKit

class NearestStopsRow: NSObject {
    @IBOutlet var stopCode: WKInterfaceLabel!
    @IBOutlet var stopName: WKInterfaceLabel!
    @IBOutlet var distance: WKInterfaceLabel!
    var code = ""
}
