//
//  Products.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 22/11/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import Foundation
import StoreKit

public struct Products {
    public static var product: SKProduct?
    public static let productId = "nearest_departures_finland_premium_version"
    public static let store = IAPHelper(productId: productId)

    public static func hasPurchasedPremiumVersion() -> Bool {
        return store.isProductPurchased(productId)
    }

    public static func buyPremiumVersion(completionHandler: @escaping PurchaseCompletionHandler) {
        if (product != nil && IAPHelper.canMakePayments()) {
            store.buyProduct(product!, completionHandler: completionHandler)
        } else {
            print("Cannot buy Premium version. Can make payments: \(IAPHelper.canMakePayments()). Product: \(String(describing: product))")
            completionHandler(false, NSLocalizedString("CANNOT_BUY_MESSAGE", comment: ""))
        }
    }

    public static func restorePremiumVersion(completionHandler: @escaping PurchaseCompletionHandler) {
        if (product != nil) {
            store.restorePurchases(completionHandler: completionHandler)
        } else {
            print("Cannot restore Premium version. No product found.")
            completionHandler(false, NSLocalizedString("CANNOT_RESTORE_MESSAGE", comment: ""))
        }
    }

    public static func loadProducts() {
        store.requestProducts(productId: productId, { (ok, prods) in
            if (ok) {
                self.product = prods?.first
            }
        })
    }
}
