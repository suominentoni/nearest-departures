
import UIKit
import GoogleMobileAds
import NearestDeparturesDigitransit

class NextDeparturesTableViewController: UITableViewController, GADBannerViewDelegate {
    var stop = Stop(name: "", lat: 0.0, lon: 0.0, distance: "", codeLong: "", codeShort: "", departures: [])
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var stopName: UILabel!
    private var hasShortCodes: Bool = true
    var banner: GADBannerView?

    override init(style: UITableView.Style) {
        super.init(style: style)
        favoriteImageView.accessibilityLabel = "favoriteImage"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge.top

        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 250

        stopName.text = stop.nameWithCode

        favoriteImageView.isUserInteractionEnabled = true
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(NextDeparturesTableViewController.favoriteTap))
        favoriteImageView.addGestureRecognizer(tapRecognizer)

        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(NextDeparturesTableViewController.refresh), for: UIControl.Event.valueChanged)

        reloadTableData()

        if (self.shouldShowAddBanner()) {
            banner = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
            banner?.delegate = self
            banner?.adUnitID = "ca-app-pub-3940256099942544/2934735716" // SAMPLE
            banner?.rootViewController = self
            banner?.backgroundColor = UIColor.gray
            let request = GADRequest()
            request.testDevices = [ kGADSimulatorID ];
            banner?.accessibilityIdentifier = "next departures ad banner"
            banner?.load(request)
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return banner
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return banner?.frame.height ?? 0
    }

    private func shouldShowAddBanner() -> Bool {
        return !Products.hasPurchasedPremiumVersion()
    }

    override func viewWillAppear(_ animated: Bool) {
        setFavoriteImage(false)
    }

    @objc func favoriteTap() {
        FavoriteStops.isFavoriteStop(self.stop) ? FavoriteStops.remove(stop) : FavoriteStops.add(stop)
        setFavoriteImage(true)
    }

    fileprivate func setFavoriteImage(_ animated: Bool) {
        if(animated) {
            UIView.transition(with: favoriteImageView, duration: 0.07, options: UIView.AnimationOptions.curveEaseIn, animations: {
                FavoriteStops.isFavoriteStop(self.stop) ? self.setIsFavoriteImage() : self.setNotFavoriteImage()
                var f = self.favoriteImageView.frame;
                f.origin.y -= 7;
                self.favoriteImageView.frame = f;
            }, completion: { (finished: Bool) in
                UIView.transition(with: self.favoriteImageView, duration: 0.1, options: UIView.AnimationOptions.curveEaseIn, animations: {
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
        self.favoriteImageView.image = UIImage(named:"ic_favorite_border")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.favoriteImageView.tintColor = UIColor.black
    }

    fileprivate func setIsFavoriteImage() {
        self.favoriteImageView.image = UIImage(named:"ic_favorite")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.favoriteImageView.tintColor = UIColor.red
    }

    @objc fileprivate func refresh() {
        reloadTableData()
    }

    fileprivate func reloadTableData() {
        let x = self.tableView.center.x
        let y = self.tableView.center.y
        self.tableView.backgroundView = LoadingIndicator(frame: CGRect(x: x-35, y: y-35, width: 70 , height: 70))

        TransitData.departuresForStop(self.stop.codeLong, callback: {(nextDepartures: [Departure]) -> Void in
            self.stop.departures = nextDepartures
            self.hasShortCodes = nextDepartures.hasShortCodes()
            DispatchQueue.main.async(execute: {
                if(self.stop.departures.count == 0) {
                    let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
                    messageLabel.textAlignment = NSTextAlignment.center
                    messageLabel.numberOfLines = 0
                    messageLabel.text = NSLocalizedString("NO_DEPARTURES_MSG", comment: "")
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
            cell.time.attributedText = departure.formattedDepartureTime()
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
