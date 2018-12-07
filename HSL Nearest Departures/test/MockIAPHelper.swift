//
//  MockIAPHelper.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 07/12/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import Foundation
import StoreKit

open class MockIAPHelper: IAPHelper {
    var purchased: Bool = false
    let productsRequestFails: Bool
    let transactionFails: Bool

    public init(productsRequestFails: Bool = false, transactionFails: Bool = false) {
        self.productsRequestFails = productsRequestFails
        self.transactionFails = transactionFails
        super.init(productId: "foo")
    }
}

extension MockIAPHelper {

    public override func requestProducts(productId: ProductIdentifier, _ completionHandler: @escaping ProductsRequestCompletionHandler) {
        completionHandler(!productsRequestFails, [SKProduct()])
    }

    public override func buyProduct(_ product: SKProduct, completionHandler: @escaping PurchaseCompletionHandler) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.purchased = !self.transactionFails
            completionHandler(!self.transactionFails, nil)
        }
    }

    public override func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return purchased
    }

    public override class func canMakePayments() -> Bool {
        return true
    }

    public override func restorePurchases(completionHandler: @escaping PurchaseCompletionHandler) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.purchased = !self.transactionFails
            completionHandler(!self.transactionFails, nil)
        }
    }
}
