//
//  PremiumViewController.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 13/11/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import Foundation
import UIKit

class PremiumViewController: UIViewController {
    @IBOutlet weak var PremiumTextLabel: UILabel!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var RestoreTextLabel: UILabel!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var purchaseStatusIndicator: UIView!
    private var loadingIndicator: LoadingIndicator?

    @IBAction func buttonClicked(_ sender: Any) {
        transactionStarted()
        Products.buyPremiumVersion(completionHandler: {(ok, errorMessage) in
            self.transactionEnded()
            if (ok) {
                self.setPremiumUI()
            } else {
                self.displayPurchaseFailedAlert(message: errorMessage)
            }
        })
    }

    @IBAction func restoreButtonClicked(_ sender: Any) {
        transactionStarted()
        Products.restorePremiumVersion(completionHandler: {(ok, errorMessage) in
            self.transactionEnded()
            if (ok) {
                self.setPremiumUI()
            } else {
                self.displayPurchaseFailedAlert(message: errorMessage)
            }
        })
    }

    private func transactionStarted() {
        loadingIndicator?.isHidden = false
    }

    private func transactionEnded() {
        loadingIndicator?.isHidden = true
    }

    private func displayPurchaseFailedAlert(message: String?) {
        let alert = UIAlertController(
            title: NSLocalizedString("PURCHASE_FAILED_TITLE", comment: ""),
            message: message == nil
                ? NSLocalizedString("PURCHASE_FAILED_MESSAGE", comment: "")
                : message,
            preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func setPremiumUI() {
        self.switchToNearestStopsTab()
        self.hideNearestStopsAdBanner()
        self.hidePremiumTab()
    }

    private func switchToNearestStopsTab() {
        self.tabBarController?.selectedIndex = 0
    }

    private func hidePremiumTab() {
        if let appTabBarController = self.tabBarController as? AppTabBarController {
            appTabBarController.hidePremiumTab()
        }
    }

    private func hideNearestStopsAdBanner() {
        if let appTabBarController = self.tabBarController as? AppTabBarController,
        let navController = appTabBarController.viewControllers?.first as? UINavigationController,
        let stopsTableViewController = navController.children.first as? StopsTableViewController {
            stopsTableViewController.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.3, animations: {
                let width = stopsTableViewController.tableView.frame.width
                stopsTableViewController.banner?.frame = CGRect(x: 0, y: 0, width: width, height: 0)
                stopsTableViewController.view.layoutIfNeeded()
            })
            stopsTableViewController.banner = nil
        }
    }

    override func viewDidLoad() {
        loadingIndicator = LoadingIndicator(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        loadingIndicator?.accessibilityIdentifier = "premium loading indicator"
        if (loadingIndicator != nil) {
            purchaseStatusIndicator.addSubview(loadingIndicator!)
        }
        loadingIndicator?.isHidden = true
        buyButton.setTitle(NSLocalizedString("PREMIUM_BUTTON_TEXT", comment: ""), for: .normal)
        PremiumTextLabel.text = NSLocalizedString("PREMIUM_LABEL_TEXT", comment: "")
        restoreButton.setTitle(NSLocalizedString("RESTORE_BUTTON_TEXT", comment: ""), for: .normal)
        RestoreTextLabel.text = NSLocalizedString("RESTORE_LABEL_TEXT", comment: "")
    }
}
