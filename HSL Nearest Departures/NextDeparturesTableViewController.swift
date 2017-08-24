
import UIKit

class NextDeparturesTableViewController: UITableViewController {

    var stop = Stop(name: "", lat: 0.0, lon: 0.0, distance: "", codeLong: "", codeShort: "", scheduleUrl: "", departures: [])

    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var stopName: UILabel!

    private var hasShortCodes: Bool = true

    override init(style: UITableViewStyle) {
        super.init(style: style)
        favoriteImageView.accessibilityLabel = "favoriteImage"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.top

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 250

        stopName.attributedText = Tools.formatStopText(stop: self.stop)

        tryAddStopNameGestureRecognizer()
        addFavoriteImageGestureRecognizer()

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(NextDeparturesTableViewController.refresh), for: UIControlEvents.valueChanged)

        reloadTableData()
    }

    private func tryAddStopNameGestureRecognizer() {
        if(stop.scheduleUrl != "") {
            stopName.isUserInteractionEnabled = true
            let linkTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(NextDeparturesTableViewController.linkTap))
            stopName.addGestureRecognizer(linkTapRecognizer)
        }
    }

    private func addFavoriteImageGestureRecognizer() {
        favoriteImageView.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(NextDeparturesTableViewController.favoriteTap))
        favoriteImageView.addGestureRecognizer(tapRecognizer)
    }

    override func viewWillAppear(_ animated: Bool) {
        setFavoriteImage(false)
    }

    @objc func linkTap() {
        let url = URL(string: stop.scheduleUrl)!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }

    @objc func favoriteTap() {
        FavoriteStops.isFavoriteStop(self.stop) ? FavoriteStops.remove(stop) : FavoriteStops.add(stop)
        setFavoriteImage(true)
    }

    fileprivate func setFavoriteImage(_ animated: Bool) {
        if(animated) {
            UIView.transition(with: favoriteImageView, duration: 0.07, options: UIViewAnimationOptions.curveEaseIn, animations: {
                FavoriteStops.isFavoriteStop(self.stop) ? self.setIsFavoriteImage() : self.setNotFavoriteImage()
                var f = self.favoriteImageView.frame;
                f.origin.y -= 7;
                self.favoriteImageView.frame = f;
            }, completion: { (finished: Bool) in
                UIView.transition(with: self.favoriteImageView, duration: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    var f = self.favoriteImageView.frame;
                    f.origin.y += 7;
                    self.favoriteImageView.frame = f;
                    }, completion: nil)
            })
        } else {
            FavoriteStops.isFavoriteStop(self.stop) ? self.setIsFavoriteImage() : self.setNotFavoriteImage()
        }
    }

    fileprivate func setNotFavoriteImage() {
        self.favoriteImageView.image = UIImage(named:"ic_favorite_border")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.favoriteImageView.tintColor = UIColor.black
    }

    fileprivate func setIsFavoriteImage() {
        self.favoriteImageView.image = UIImage(named:"ic_favorite")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        self.favoriteImageView.tintColor = UIColor.red
    }

    @objc fileprivate func refresh() {
        reloadTableData()
    }

    fileprivate func reloadTableData() {
        let x = self.tableView.center.x
        let y = self.tableView.center.y
        self.tableView.backgroundView = LoadingIndicator(frame: CGRect(x: x-35, y: y-35, width: 70 , height: 70))

        HSL.departuresForStop(self.stop.codeLong, callback: {(nextDepartures: [Departure]) -> Void in
            self.stop.departures = nextDepartures
            self.hasShortCodes = Tools.hasShortCodes(departures: nextDepartures)
            DispatchQueue.main.async(execute: {
                if(self.stop.departures.count == 0) {
                    let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
                    messageLabel.textAlignment = NSTextAlignment.center
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.stop.departures.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NextDepartureCell", for: indexPath) as! NextDepartureCell

        let departure = self.stop.departures[(indexPath as NSIndexPath).row]

        DispatchQueue.main.async(execute: {
            if let codeShort = departure.line.codeShort,
                let destination = departure.line.destination {

                cell.code.text = codeShort
                let codeLabelWidth: CGFloat = self.hasShortCodes ? 55 : 0
                if(cell.codeWidthConstraint != nil) {
                    cell.contentView.removeConstraint(cell.codeWidthConstraint!)
                }
                cell.codeWidthConstraint = NSLayoutConstraint(item: cell.code, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: codeLabelWidth)
                cell.contentView.addConstraint(cell.codeWidthConstraint!)

                cell.destination.text = destination
            } else {
                cell.code.text = departure.line.codeLong
            }
            cell.time.attributedText = Tools.formatDepartureTime(departure.scheduledDepartureTime, real: departure.realDepartureTime)
        })

        return cell
    }

    @IBAction func back(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let stopMapViewController = segue.destination as! StopMapViewController
        stopMapViewController.stop = stop
    }
}
