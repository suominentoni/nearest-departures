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
    
    @IBAction func buttonClicked(_ sender: Any) {
        print("fooo")
    }
    
    override func viewDidLoad() {
        buyButton.setTitle(NSLocalizedString("PREMIUM_BUTTON_TEXT", comment: ""), for: .normal)
        PremiumTextLabel.text = NSLocalizedString("PREMIUM_LABEL_TEXT", comment: "")
    }
}
