
import UIKit

class NextDeparturesTableViewController: UITableViewController {

    var nextDepartures: [Departure] = []
    var stopCode: String = String()
    @IBOutlet weak var backButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.Top

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(NextDeparturesTableViewController.reloadTableData), forControlEvents: UIControlEvents.ValueChanged)

        reloadTableData()
    }

    func reloadTableData() {
        HSL.getNextDeparturesForStop(self.stopCode, callback: {(nextDepartures: [Departure]) -> Void in
            self.nextDepartures = nextDepartures
            dispatch_async(dispatch_get_main_queue(), {
                if(self.nextDepartures.count == 0) {
                    let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
                    messageLabel.textAlignment = NSTextAlignment.Center
                    messageLabel.numberOfLines = 0
                    messageLabel.text = Const.NO_DEPARTURES_MSG
                    messageLabel.sizeToFit()

                    self.tableView.backgroundView = messageLabel
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
                }
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
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
            cell.code.text = departure.line.codeShort != nil ? departure.line.codeShort : departure.line.codeLong
            cell.time.text = departure.time
        })

        return cell
    }

    @IBAction func back(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
