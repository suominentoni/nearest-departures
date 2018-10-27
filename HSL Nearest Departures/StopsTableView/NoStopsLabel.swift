//
//  NoStopsLabel.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 27/10/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import Foundation
import UIKit

class NoStopsLabel: UILabel {
     init(parentView: UIView, message: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: parentView.bounds.width, height: parentView.bounds.height))
        self.textAlignment = NSTextAlignment.center
        self.numberOfLines = 0
        self.text = message
        self.sizeToFit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
