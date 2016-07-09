
import UIKit

class NextDeparturesTableViewController: UITableViewController {

    var nextDepartures: [NSDictionary] = [NSDictionary]()
    var stopCode: String = String()
    @IBOutlet weak var backButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.Top

        HSL.getNextDeparturesForStop(self.stopCode, callback: {(nextDepartures: NSArray) -> Void in
            self.nextDepartures = nextDepartures as! [NSDictionary]
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

        if let code = departure["code"] as? String,
            let time = departure["time"] as? String {
            dispatch_async(dispatch_get_main_queue(), {
                cell.code.text = code
                cell.time.text = time
            })
            HSL.getLineInfo(code, callback: {(lineInfo: NSDictionary) -> Void in
                if let shortCode = lineInfo["code"] as? String,
                let name = lineInfo["name"] as? String {
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.code.text = shortCode
                        cell.name.text = name
                    })
                }
            })
        }

        return cell
    }

    @IBAction func back(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
