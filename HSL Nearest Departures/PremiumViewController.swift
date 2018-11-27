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

    @IBAction func buttonClicked(_ sender: Any) {
        Products.buyPremiumVersion(completionHandler: {ok in
            if (ok) {
                self.switchToNearestStopsTab()
            }
        })
    }

    @IBAction func restoreButtonClicked(_ sender: Any) {
        Products.restorePremiumVersion(completionHandler: {ok in
            if (ok) {
                self.switchToNearestStopsTab()
            }
        })
    }

    private func switchToNearestStopsTab() {
        self.tabBarController?.selectedIndex = 0
        if let appTabBarController = self.tabBarController as? AppTabBarController {
            appTabBarController.hidePremiumTab()
            if let viewControllers = appTabBarController.viewControllers,
                let navController = viewControllers.first as? UINavigationController,
                let stopsTableViewController = navController.children.first as? StopsTableViewController {
                stopsTableViewController.tableView.setNeedsDisplay()
                //stopsTableViewController.tableView.headerView(forSection: 0)?.setNeedsDisplay()
            }
        }
    }
    
    override func viewDidLoad() {
        buyButton.setTitle(NSLocalizedString("PREMIUM_BUTTON_TEXT", comment: ""), for: .normal)
        PremiumTextLabel.text = NSLocalizedString("PREMIUM_LABEL_TEXT", comment: "")
        restoreButton.setTitle(NSLocalizedString("RESTORE_BUTTON_TEXT", comment: ""), for: .normal)
        RestoreTextLabel.text = NSLocalizedString("RESTORE_LABEL_TEXT", comment: "")
    }
}
