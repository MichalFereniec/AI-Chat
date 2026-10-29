//
//  MockPurchaseService.swift
//  AIChatCourse
//
//  Created by Nick Sarno on 11/2/24.
//

struct MockPurchaseService: PurchaseService {
    
    let activeEntitlements: [PurchasedEntitlement]
    
    init(activeEntitlements: [PurchasedEntitlement] = []) {
        self.activeEntitlements = activeEntitlements
    }
    
    func listenForTransactions(onTransactionUpdated: ([PurchasedEntitlement]) async -> Void) async {
        await onTransactionUpdated(activeEntitlements)
    }
    
    func getUserEntitlements() async throws -> [PurchasedEntitlement] {
        activeEntitlements
    }
    
    func getProducts(productIds: [String]) async throws -> [AnyProduct] {
        return AnyProduct.mocks.filter { product in
            return productIds.contains(product.id)
        }
    }
    
    func restorePurchase() async throws -> [PurchasedEntitlement] {
        activeEntitlements
    }
    
    func purchaseProduct(productId: String) async throws -> [PurchasedEntitlement] {
        activeEntitlements
    }
    
    func logIn(userId: String) async throws -> [PurchasedEntitlement] {
        activeEntitlements
    }
    
    func updateProfileAttributes(attributes: PurchaseProfileAttributes) async throws {
        
    }
    
    func logOut() async throws {
        
    }
}
