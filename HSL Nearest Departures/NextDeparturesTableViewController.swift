
import UIKit

class NextDeparturesTableViewController: UITableViewController {

    var nextDepartures: [Departure] = []
    var stop = Stop(name: "", distance: "", codeLong: "", codeShort: "")

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var stopName: UILabel!

    override init(style: UITableViewStyle) {
        super.init(style: style)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.Top

        stopName.text = "\(stop.name) (\(stop.codeShort))"

        favoriteImageView.image = FavoriteStops.isFavoriteStop(stop) ? UIImage(named: "ic_favorite") : UIImage(named: "ic_favorite_border")

        favoriteImageView.userInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(NextDeparturesTableViewController.favoriteTap))
        favoriteImageView.addGestureRecognizer(tapRecognizer)

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(NextDeparturesTableViewController.reloadTableData), forControlEvents: UIControlEvents.ValueChanged)

        reloadTableData()
    }

    override func viewWillAppear(animated: Bool) {
        setFavoriteImage()
    }

    func favoriteTap() {
        FavoriteStops.isFavoriteStop(self.stop) ? FavoriteStops.remove(stop) : FavoriteStops.add(stop)
        setFavoriteImage()
    }

    private func setFavoriteImage() {
        if(FavoriteStops.isFavoriteStop(stop)) {
            favoriteImageView.image = UIImage(named:"ic_favorite")
            favoriteImageView.image = favoriteImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            favoriteImageView.tintColor = UIColor.redColor()
        } else {
            favoriteImageView.image = UIImage(named: "ic_favorite_border")
        }
    }

    func reloadTableData() {
        HSL.getNextDeparturesForStop(self.stop.codeLong, callback: {(nextDepartures: [Departure]) -> Void in
            self.nextDepartures = nextDepartures
            dispatch_async(dispatch_get_main_queue(), {
                if(self.nextDepartures.count == 0) {
                    let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
                    messageLabel.textAlignment = NSTextAlignment.Center
                    messageLabel.numberOfLines = 0
                    messageLabel.text = Const.NO_DEPARTURES_MSG
                    messageLabel.sizeToFit()

                    self.tableView.backgroundView = messageLabel
                } else {
                    self.tableView.backgroundView = nil
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
            if let codeShort = departure.line.codeShort,
                let destination = departure.line.destination {
                cell.code.text = codeShort
                cell.destination.text = destination
            } else {
                cell.code.text = departure.line.codeLong
            }
            cell.time.text = departure.time
        })

        return cell
    }

    @IBAction func back(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
