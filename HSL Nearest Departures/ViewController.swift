import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var nearestStops: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateView(departures: [NSDictionary]) {
    }
}

