//
//  WatchSession.swift
//  HSL Nearest Departures WatchKit Extension
//
//  Created by Toni Suominen on 14/12/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate {
    static let sharedManager = WatchSessionManager()
    var userInfo: [String] = []
    private let session: WCSession = WCSession.default

    private override init() {
        super.init()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Wake up iOS app in the background to get up-to-date favorite stops to watch
        session.sendMessage([:], replyHandler: {_ in }, errorHandler: {_ in})
    }

    func startSession() {
        session.delegate = self
        session.activate()
    }
}

extension WatchSessionManager {
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        NSLog("FAV: received data: \(userInfo.debugDescription)")
        if let stopCodes = userInfo["foo"] as? [String] {
            self.userInfo = stopCodes
            print("FAV: assigned stops codes: \(stopCodes)")
        }
    }
}
