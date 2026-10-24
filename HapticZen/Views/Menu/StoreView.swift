import StoreKit
import SwiftUI

struct StoreView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            StoreViewContent()
                .navigationTitle("store.title")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("store.close") {
                            dismiss()
                        }
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.zenGlow)
                    }
                }
                .toolbarBackground(Color.zenCardBackground, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.medium, .large])
    }
}

struct StoreViewContent: View {
    @EnvironmentObject private var appState: AppState
    @ObservedObject private var storeManager = StoreManager.shared
    @State private var purchasingProductID: String? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Banner
                VStack(spacing: 8) {
                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.zenGlow)
                        .padding(.bottom, 4)

                    Text("store.banner.title")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("store.banner.subtitle")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.zenTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.top, 16)

                // Packs List
                VStack(spacing: 16) {
                    ForEach(TexturePack.allPacks.filter { !$0.isFree }) { pack in
                        packCard(for: pack)
                    }
                }
                .padding(.horizontal, 16)

                // Restore Purchases Button
                Button {
                    Task {
                        await StoreManager.shared.restorePurchases()
                        await StoreManager.shared.updateUnlockedPacks(in: appState)
                    }
                } label: {
                    Text("store.restore")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.zenTextSecondary)
                        .underline()
                }
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
        }
        .background(Color.zenDarkBackground)
        .task {
            if storeManager.products.isEmpty {
                await storeManager.loadProducts()
            }
        }
    }

    @ViewBuilder
    private func packCard(for pack: TexturePack) -> some View {
        let isUnlocked = appState.unlockedPackIDs.contains(pack.id)
        let product = storeManager.products.first(where: { $0.id == pack.productID })

        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(pack.displayNameKey)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(pack.descriptionKey)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(.zenTextSecondary)
                }
                Spacer()
            }

            // Textures preview pills
            HStack(spacing: 8) {
                ForEach(pack.textures) { texture in
                    HStack(spacing: 6) {
                        Image(systemName: texture.iconName)
                            .font(.caption)
                        Text(texture.displayNameKey)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(Color.white.opacity(0.1), in: Capsule())
                }
            }

            Divider()
                .background(Color.white.opacity(0.1))

            HStack {
                if isUnlocked {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.zenGlow)
                        Text("store.unlocked")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.zenGlow)
                    }
                } else {
                    if let product = product {
                        Text(product.displayPrice)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    } else {
                        ProgressView()
                            .tint(.zenGlow)
                    }

                    Spacer()

                    Button {
                        Task {
                            if let productID = pack.productID {
                                purchasingProductID = productID
                                await storeManager.purchase(productID: productID, appState: appState)
                                purchasingProductID = nil
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            if purchasingProductID == pack.productID {
                                ProgressView()
                                    .tint(.black)
                            }
                            Text("store.buy")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.black)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 24)
                        .background(Color.zenGlow, in: Capsule())
                    }
                    .disabled(purchasingProductID != nil)
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.zenCardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isUnlocked ? Color.zenGlow.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
