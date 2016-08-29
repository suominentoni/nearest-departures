
import UIKit

class NextDeparturesTableViewController: UITableViewController {

    var stop = Stop(name: "", lat: 0.0, lon: 0.0, distance: "", codeLong: "", codeShort: "", departures: [])

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

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 250

        stopName.text = "\(stop.name) (\(stop.codeShort))"

        favoriteImageView.userInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(NextDeparturesTableViewController.favoriteTap))
        favoriteImageView.addGestureRecognizer(tapRecognizer)

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(NextDeparturesTableViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)

        reloadTableData()
    }

    override func viewWillAppear(animated: Bool) {
        setFavoriteImage(false)
    }

    func favoriteTap() {
        FavoriteStops.isFavoriteStop(self.stop) ? FavoriteStops.remove(stop) : FavoriteStops.add(stop)
        setFavoriteImage(true)
    }

    private func setFavoriteImage(animated: Bool) {
        if(animated) {
            UIView.transitionWithView(favoriteImageView, duration: 0.07, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                FavoriteStops.isFavoriteStop(self.stop) ? self.setIsFavoriteImage() : self.setNotFavoriteImage()
                var f = self.favoriteImageView.frame;
                f.origin.y -= 7;
                self.favoriteImageView.frame = f;
            }, completion: { (finished: Bool) in
                UIView.transitionWithView(self.favoriteImageView, duration: 0.1, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    var f = self.favoriteImageView.frame;
                    f.origin.y += 7;
                    self.favoriteImageView.frame = f;
                    }, completion: nil)
            })
        } else {
            FavoriteStops.isFavoriteStop(self.stop) ? self.setIsFavoriteImage() : self.setNotFavoriteImage()
        }
    }

    private func setNotFavoriteImage() {
        self.favoriteImageView.image = UIImage(named:"ic_favorite_border")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.favoriteImageView.tintColor = UIColor.blackColor()
    }

    private func setIsFavoriteImage() {
        self.favoriteImageView.image = UIImage(named:"ic_favorite")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.favoriteImageView.tintColor = UIColor.redColor()
    }

    @objc private func refresh() {
        reloadTableData()
    }

    private func reloadTableData() {
        let x = self.tableView.center.x
        let y = self.tableView.center.y
        self.tableView.backgroundView = LoadingIndicator(frame: CGRect(x: x-35, y: y-35, width: 70 , height: 70))

        HSL.departuresForStop("HSL:" + self.stop.codeLong, callback: {(nextDepartures: [Departure]) -> Void in
            self.stop.departures = nextDepartures
            dispatch_async(dispatch_get_main_queue(), {
                if(self.stop.departures.count == 0) {
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
        return self.stop.departures.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NextDepartureCell", forIndexPath: indexPath) as! NextDepartureCell

        let departure = self.stop.departures[indexPath.row]

        dispatch_async(dispatch_get_main_queue(), {
            if let codeShort = departure.line.codeShort,
                let destination = departure.line.destination {
                cell.code.text = codeShort
                cell.destination.text = destination
            } else {
                cell.code.text = departure.line.codeLong
            }
            cell.time.attributedText = Tools.formatDepartureTime(departure.scheduledDepartureTime, real: departure.realDepartureTime)
        })

        return cell
    }

    @IBAction func back(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let stopMapViewController = segue.destinationViewController as! StopMapViewController
        stopMapViewController.stop = stop
    }
}
