//
//  StopsTableViewControllerDelegate.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 06/02/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

protocol StopsTableViewControllerDelegate: class {
    var updateUI: (_ stops: [Stop]?) -> Void { get set }

    func viewDidLoad() -> Void
    func loadData(callback: @escaping ([Stop]?) -> Void) -> Void
    func getTitle() -> String
    func getNoStopsMessage() -> String
}
