import Foundation
import UIKit
import NearestDeparturesDigitransit

class StopsTableCell: UITableViewCell {
    @IBOutlet var code: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var destinations: UILabel!
    @IBOutlet weak var distance: UILabel!
    var codeWidthConstraint: NSLayoutConstraint?

    func displayStopData(stop: Stop, codeWidth: CGFloat, displayDistance: Bool) {
        self.updateCodeWidthConstraint(codeWidth: codeWidth)
        self.code.text = stop.codeShort
        self.name.text = stop.name
        self.destinations.text = stop.departures.destinations()
        self.distance.text = displayDistance ? String(stop.distance) + " m" : ""
    }

    fileprivate func updateCodeWidthConstraint(codeWidth: CGFloat) {
        if let constraint = self.codeWidthConstraint {
            self.code.removeConstraint(constraint)
            self.codeWidthConstraint = nil
        }
        let codeWidthConstraint = self.code.widthAnchor.constraint(equalToConstant: codeWidth)
        self.codeWidthConstraint = codeWidthConstraint
        self.code.addConstraint(codeWidthConstraint)
    }
}
