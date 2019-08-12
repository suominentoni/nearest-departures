import Foundation
import UIKit
import NearestDeparturesDigitransit

class NextDepartureCell: UITableViewCell {
    @IBOutlet weak var code: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var destination: UILabel!
    var codeWidthConstraint: NSLayoutConstraint?

    func setDepartureData(departure: Departure, codeLabelWidth: CGFloat) {
        if let codeShort = departure.line.codeShort,
            let destination = departure.line.destination {
            self.code.text = codeShort
            if(self.codeWidthConstraint != nil) {
                self.contentView.removeConstraint(self.codeWidthConstraint!)
            }
            self.codeWidthConstraint = self.code.widthAnchor.constraint(equalToConstant: codeLabelWidth)
            self.contentView.addConstraint(self.codeWidthConstraint!)
            self.destination.text = destination
            self.accessibilityLabel = "\(NSLocalizedString("LINE", comment: "")) \(codeShort), \(NSLocalizedString("DESTINATION", comment: "")) \(destination), \(departure.formattedDepartureTime().string)"
        } else {
            self.code.text = departure.line.codeLong
        }
        self.time.attributedText = departure.formattedDepartureTime()
    }
}
