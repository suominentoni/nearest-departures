//
//  Products.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 22/11/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import Foundation
import StoreKit

let Products = _Products.sharedInstance

public class _Products {
    fileprivate static let sharedInstance = _Products(store: _Products.store)
    public static var store: IAPHelper = IAPHelper(productId: productId)
    fileprivate var product: SKProduct?
    public static let productId = "nearest_departures_finland_premium_version"

    fileprivate init(store: IAPHelper) {
        _Products.store = store
    }

    public func hasPurchasedPremiumVersion() -> Bool {
        return _Products.store.isProductPurchased(_Products.productId)
    }

    public func buyPremiumVersion(completionHandler: @escaping PurchaseCompletionHandler) {
        if (product != nil && IAPHelper.canMakePayments()) {
            _Products.store.buyProduct(product!, completionHandler: completionHandler)
        } else {
            print("Cannot buy Premium version. Can make payments: \(IAPHelper.canMakePayments()). Product: \(String(describing: product))")
            completionHandler(false, NSLocalizedString("CANNOT_BUY_MESSAGE", comment: ""))
        }
    }

    public func restorePremiumVersion(completionHandler: @escaping PurchaseCompletionHandler) {
        if (product != nil) {
            _Products.store.restorePurchases(completionHandler: completionHandler)
        } else {
            print("Cannot restore Premium version. No product found.")
            completionHandler(false, NSLocalizedString("CANNOT_RESTORE_MESSAGE", comment: ""))
        }
    }

    public func loadProducts() {
        _Products.store.requestProducts(productId: _Products.productId, { (ok, prods) in
            if (ok) {
                self.product = prods?.first
            }
        })
    }
}
