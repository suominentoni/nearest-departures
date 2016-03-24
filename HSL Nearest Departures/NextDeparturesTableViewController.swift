
import UIKit

class NextDeparturesTableViewController: UITableViewController {

    var nextDepartures: [NSDictionary] = [NSDictionary]()
    var stopCode: String = String()
    @IBOutlet weak var backButton: UIBarButtonItem!

    override func viewWillAppear(animated: Bool) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        HSL.getNextDeparturesForStop(self.stopCode, callback: {(nextDepartures: NSArray) -> Void in
            self.nextDepartures = nextDepartures as! [NSDictionary]
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        })
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


}
