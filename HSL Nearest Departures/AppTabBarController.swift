//
//  AppTabBarController.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 15/11/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import Foundation
import UIKit

class AppTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        if let viewControllers = self.viewControllers {
        if viewControllers.count >= 3 {
            let vc1 = viewControllers[0]
            let vc2 = viewControllers[1]
            let vc3 = viewControllers[2]
            let vc4 = viewControllers[3]
            self.setViewControllers([vc1, vc2, vc3, vc4], animated: false)
            }
        }
    }
}
