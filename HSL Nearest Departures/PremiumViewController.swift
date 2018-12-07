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

    @IBAction func buttonClicked(_ sender: Any) {
        transactionStarted()
        Products.buyPremiumVersion(completionHandler: {(ok, errorMessage) in
            self.transactionEnded()
            if (ok) {
                self.switchToNearestStopsTab()
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
                self.switchToNearestStopsTab()
            } else {
                self.displayPurchaseFailedAlert(message: errorMessage)
            }
        })
    }

    private func transactionStarted() {
        purchaseStatusIndicator.alpha = 1.0
    }

    private func transactionEnded() {
        purchaseStatusIndicator.alpha = 0.0
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

    private func switchToNearestStopsTab() {
        self.tabBarController?.selectedIndex = 0
        if let appTabBarController = self.tabBarController as? AppTabBarController {
            appTabBarController.hidePremiumTab()
            if let viewControllers = appTabBarController.viewControllers,
                let navController = viewControllers.first as? UINavigationController,
                let stopsTableViewController = navController.children.first as? StopsTableViewController {
                stopsTableViewController.tableView.setNeedsDisplay()
            }
        }
    }

    override func viewDidLoad() {
        purchaseStatusIndicator.addSubview(LoadingIndicator(frame: CGRect(x: 0, y: 0, width: 40, height: 40)))
        purchaseStatusIndicator.alpha = 0.0
        buyButton.setTitle(NSLocalizedString("PREMIUM_BUTTON_TEXT", comment: ""), for: .normal)
        PremiumTextLabel.text = NSLocalizedString("PREMIUM_LABEL_TEXT", comment: "")
        restoreButton.setTitle(NSLocalizedString("RESTORE_BUTTON_TEXT", comment: ""), for: .normal)
        RestoreTextLabel.text = NSLocalizedString("RESTORE_LABEL_TEXT", comment: "")
    }
}
