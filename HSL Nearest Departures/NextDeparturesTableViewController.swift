
import UIKit

class NextDeparturesTableViewController: UITableViewController {

    var nextDepartures: [Departure] = []
    var stopCode: String = String()
    @IBOutlet weak var backButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.Top

        HSL.getNextDeparturesForStop(self.stopCode, callback: {(nextDepartures: [Departure]) -> Void in
            self.nextDepartures = nextDepartures
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nextDepartures.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NextDepartureCell", forIndexPath: indexPath) as! NextDepartureCell

        let departure = self.nextDepartures[indexPath.row]

        dispatch_async(dispatch_get_main_queue(), {
            cell.code.text = departure.line
            cell.time.text = departure.time
        })
        HSL.getLineInfo(departure.line, callback: {(lineInfo: NSDictionary) -> Void in
            if let shortCode = lineInfo["code"] as? String {
                dispatch_async(dispatch_get_main_queue(), {
                    cell.code.text = shortCode
                })
            }
        })

        return cell
    }

    @IBAction func back(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
