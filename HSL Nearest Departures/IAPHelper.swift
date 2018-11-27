//
//  IAPHelper.swift
//  HSL Nearest Departures
//
//  Created by Toni Suominen on 22/11/2018.
//  Copyright © 2018 Toni Suominen. All rights reserved.
//

import Foundation
import StoreKit

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void
public typealias PurchaseCompletionHandler = (_ success: Bool) -> Void

extension Notification.Name {
    static let IAPHelperPurchaseNotification = Notification.Name("IAPHelperPurchaseNotification")
}

open class IAPHelper: NSObject  {
    private var purchasedProductIdentifiers: Set<ProductIdentifier> = []
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    private var purchaseCompletionHandler: PurchaseCompletionHandler?

    public init(productId: ProductIdentifier) {
        let purchased = UserDefaults.standard.bool(forKey: productId)
        if purchased {
            purchasedProductIdentifiers.insert(productId)
            print("Previously purchased: \(productId)")
        } else {
            print("Not purchased: \(productId)")
        }
        super.init()
        SKPaymentQueue.default().add(self)
    }
}

extension IAPHelper {

    public func requestProducts(productId: ProductIdentifier, _ completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        productsRequest = SKProductsRequest(productIdentifiers: [productId])
        productsRequest!.delegate = self
        productsRequest!.start()
    }

    public func buyProduct(_ product: SKProduct, completionHandler: @escaping PurchaseCompletionHandler) {
        print("Buying \(product.productIdentifier)...")
        purchaseCompletionHandler = completionHandler
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }

    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }

    public func restorePurchases(completionHandler: @escaping PurchaseCompletionHandler) {
        purchaseCompletionHandler = completionHandler
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

extension IAPHelper: SKProductsRequestDelegate {

    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()
        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }

    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

extension IAPHelper: SKPaymentTransactionObserver {

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            }
        }
    }

    private func complete(transaction: SKPaymentTransaction) {
        print("complete...")
        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        purchaseCompletionHandler?(true)
        purchaseCompletionHandler = nil
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        print("restore... \(productIdentifier)")
        deliverPurchaseNotificationFor(identifier: productIdentifier)
        purchaseCompletionHandler?(true)
        purchaseCompletionHandler = nil
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        if let transactionError = transaction.error as NSError?,
            let localizedDescription = transaction.error?.localizedDescription,
            transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(localizedDescription)")
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }
        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        NotificationCenter.default.post(name: .IAPHelperPurchaseNotification, object: identifier)
    }
}
