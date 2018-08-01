import Foundation
import UIKit

class StopsTableCell: UITableViewCell {
    @IBOutlet var code: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var destinations: UILabel!
    @IBOutlet weak var distance: UILabel!

    var codeWidthConstraint: NSLayoutConstraint?
}