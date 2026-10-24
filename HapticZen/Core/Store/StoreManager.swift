import StoreKit
import SwiftUI

@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()

    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    
    private var updatesTask: Task<Void, Never>?
    private var isPurchasing = false

    private init() {
        Task {
            await loadProducts()
            await updatePurchasedStatus()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func startListeningForUpdates(in appState: AppState) {
        updatesTask?.cancel()
        updatesTask = Task { [weak appState] in
            for await verification in Transaction.updates {
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                }
                await self.updatePurchasedStatus()
                if let appState = appState {
                    await self.updateUnlockedPacks(in: appState)
                }
            }
        }
        Task { [weak appState] in
            await loadProducts()
            await updatePurchasedStatus()
            if let appState = appState {
                await updateUnlockedPacks(in: appState)
            }
        }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: ProductIDs.all)
        } catch {
            print("Failed to fetch products: \(error)")
        }
    }

    func purchase(productID: String, appState: AppState) async {
        guard !isPurchasing else { return }
        isPurchasing = true
        defer { isPurchasing = false }

        guard let product = products.first(where: { $0.id == productID }) else {
            await loadProducts()
            guard let retryProduct = products.first(where: { $0.id == productID }) else { return }
            await executePurchase(product: retryProduct, appState: appState)
            return
        }
        await executePurchase(product: product, appState: appState)
    }

    private func executePurchase(product: Product, appState: AppState) async {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    await updatePurchasedStatus()
                    await updateUnlockedPacks(in: appState)
                }
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updatePurchasedStatus()
        } catch {
            print("Restore failed: \(error)")
        }
    }

    func updatePurchasedStatus() async {
        var purchased: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.revocationDate == nil {
                    purchased.insert(transaction.productID)
                }
            }
        }
        purchasedProductIDs = purchased
    }

    func updateUnlockedPacks(in appState: AppState) async {
        var activePackIDs: Set<String> = [TexturePack.freePack.id]
        for productID in purchasedProductIDs {
            if let pack = TexturePack.allPacks.first(where: { $0.productID == productID }) {
                activePackIDs.insert(pack.id)
            }
        }
        appState.syncUnlockedPacks(activePackIDs)
    }
}
