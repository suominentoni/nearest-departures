//
//  WatchSession.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 14/12/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import WatchConnectivity

class WatchSessionManager: NSObject, WCSessionDelegate {
    static let sharedManager = WatchSessionManager()
    private let session: WCSession? = WCSession.isSupported() ? WCSession.default : nil
    private var validSession: WCSession? {
        if let session = session, session.isPaired && session.isWatchAppInstalled {
            return session
        }
        return nil
    }

    private override init() {
        super.init()
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        transferFavoriteStops()
    }

    func startSession() {
        session?.delegate = self
        session?.activate()
    }
}

extension WatchSessionManager {
    func transferUserInfo(userInfo: [String : AnyObject]) -> WCSessionUserInfoTransfer? {
        return validSession?.transferUserInfo(userInfo)
    }

    func transferFavoriteStops() {
        do {
            let codes: [String] = try FavoriteStops.all().map({stop in stop.codeLong})
            let _ = WatchSessionManager.sharedManager.transferUserInfo(userInfo: ["foo" : codes as AnyObject])
        } catch {
            print("Failed transfering user info")
        }
    }
}
