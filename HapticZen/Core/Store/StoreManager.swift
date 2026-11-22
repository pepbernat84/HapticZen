import StoreKit
import SwiftUI

struct StoreAlertInfo: Identifiable, Equatable {
    let id = UUID()
    let titleKey: String
    let messageKey: String
    let detailMessage: String?

    init(titleKey: String, messageKey: String, detailMessage: String? = nil) {
        self.titleKey = titleKey
        self.messageKey = messageKey
        self.detailMessage = detailMessage
    }

    var localizedMessage: String {
        let base = NSLocalizedString(messageKey, bundle: .main, comment: "Store alert message")
        if let detailMessage = detailMessage, !detailMessage.isEmpty {
            return "\(base)\n\n\(detailMessage)"
        }
        return base
    }
}

@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()

    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var revokedProductIDs: Set<String> = []
    @Published var activeAlert: StoreAlertInfo? = nil
    @Published var isLoadingProducts: Bool = false
    @Published var isRestoring: Bool = false
    
    private var updatesTask: Task<Void, Never>?
    private var initialSyncTask: Task<Void, Never>?
    private var isPurchasing = false

    private init() {
        Task {
            await loadProducts()
            await updatePurchasedStatus()
        }
    }

    deinit {
        updatesTask?.cancel()
        initialSyncTask?.cancel()
    }

    func startListeningForUpdates(in appState: AppState) {
        updatesTask?.cancel()
        initialSyncTask?.cancel()
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
        initialSyncTask = Task { [weak appState] in
            await loadProducts()
            await updatePurchasedStatus()
            if let appState = appState {
                await updateUnlockedPacks(in: appState)
            }
        }
    }

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }
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
        activeAlert = nil

        guard let product = products.first(where: { $0.id == productID }) else {
            await loadProducts()
            guard let retryProduct = products.first(where: { $0.id == productID }) else {
                activeAlert = StoreAlertInfo(
                    titleKey: "store.error.title",
                    messageKey: "store.error.productUnavailable"
                )
                return
            }
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
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    await updatePurchasedStatus()
                    await updateUnlockedPacks(in: appState)
                case .unverified(_, let error):
                    print("Unverified transaction for \(product.id): \(error)")
                    activeAlert = StoreAlertInfo(
                        titleKey: "store.error.title",
                        messageKey: "store.error.verificationFailed"
                    )
                }
            case .pending:
                activeAlert = StoreAlertInfo(
                    titleKey: "store.pending.title",
                    messageKey: "store.pending.message"
                )
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch let storeKitError as StoreKitError {
            if case .userCancelled = storeKitError {
                return
            }
            print("Purchase failed (StoreKit): \(storeKitError)")
            activeAlert = StoreAlertInfo(
                titleKey: "store.error.title",
                messageKey: "store.error.purchaseFailed",
                detailMessage: storeKitError.localizedDescription
            )
        } catch {
            print("Purchase failed: \(error)")
            activeAlert = StoreAlertInfo(
                titleKey: "store.error.title",
                messageKey: "store.error.purchaseFailed",
                detailMessage: error.localizedDescription
            )
        }
    }

    func restorePurchases() async {
        guard !isRestoring else { return }
        isRestoring = true
        defer { isRestoring = false }
        activeAlert = nil

        do {
            try await AppStore.sync()
            await updatePurchasedStatus()
        } catch let storeKitError as StoreKitError {
            if case .userCancelled = storeKitError {
                return
            }
            print("Restore failed (StoreKit): \(storeKitError)")
            activeAlert = StoreAlertInfo(
                titleKey: "store.error.title",
                messageKey: "store.error.restoreFailed",
                detailMessage: storeKitError.localizedDescription
            )
        } catch {
            print("Restore failed: \(error)")
            activeAlert = StoreAlertInfo(
                titleKey: "store.error.title",
                messageKey: "store.error.restoreFailed",
                detailMessage: error.localizedDescription
            )
        }
    }

    func updatePurchasedStatus() async {
        var purchased: Set<String> = []
        var revoked: Set<String> = []

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.revocationDate == nil {
                    purchased.insert(transaction.productID)
                } else {
                    revoked.insert(transaction.productID)
                }
            }
        }

        for productID in ProductIDs.all where !purchased.contains(productID) {
            if let latest = await Transaction.latest(for: productID),
               case .verified(let transaction) = latest,
               transaction.revocationDate != nil {
                revoked.insert(productID)
            }
        }

        purchasedProductIDs = purchased
        revokedProductIDs = revoked
    }

    func updateUnlockedPacks(in appState: AppState) async {
        var activePackIDs: Set<String> = [TexturePack.freePack.id]
        for productID in purchasedProductIDs {
            if let pack = TexturePack.allPacks.first(where: { $0.productID == productID }) {
                activePackIDs.insert(pack.id)
            }
        }

        var revokedPackIDs: Set<String> = []
        for productID in revokedProductIDs {
            if let pack = TexturePack.allPacks.first(where: { $0.productID == productID }) {
                revokedPackIDs.insert(pack.id)
            }
        }

        appState.syncUnlockedPacks(activePackIDs, revokedPackIDs: revokedPackIDs)
    }
}
