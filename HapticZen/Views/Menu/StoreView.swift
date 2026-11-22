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
                        .font(.system(.callout, design: .rounded, weight: .semibold))
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
                        .font(.largeTitle)
                        .foregroundColor(.zenGlow)
                        .padding(.bottom, 4)

                    Text("store.banner.title")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("store.banner.subtitle")
                        .font(.system(.subheadline, design: .rounded, weight: .regular))
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
                        await storeManager.restorePurchases()
                        await storeManager.updateUnlockedPacks(in: appState)
                    }
                } label: {
                    HStack(spacing: 8) {
                        if storeManager.isRestoring {
                            ProgressView()
                                .tint(.zenTextSecondary)
                        }
                        Text("store.restore")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundColor(.zenTextSecondary)
                            .underline()
                    }
                }
                .disabled(storeManager.isRestoring || purchasingProductID != nil)
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
        .alert(
            LocalizedStringKey(storeManager.activeAlert?.titleKey ?? "store.error.title"),
            isPresented: Binding(
                get: { storeManager.activeAlert != nil },
                set: { if !$0 { storeManager.activeAlert = nil } }
            ),
            presenting: storeManager.activeAlert
        ) { _ in
            Button("store.alert.ok", role: .cancel) {
                storeManager.activeAlert = nil
            }
        } message: { alert in
            Text(alert.localizedMessage)
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
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundColor(.white)

                    Text(pack.descriptionKey)
                        .font(.system(.footnote, design: .rounded, weight: .regular))
                        .foregroundColor(.zenTextSecondary)
                }
                Spacer()
            }

            // Textures preview pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(pack.textures) { texture in
                        HStack(spacing: 6) {
                            Image(systemName: texture.iconName)
                                .font(.caption)
                            Text(texture.displayNameKey)
                                .font(.system(.caption, design: .rounded, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(Color.white.opacity(0.1), in: Capsule())
                    }
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
                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                            .foregroundColor(.zenGlow)
                    }
                } else {
                    if let product = product {
                        Text(product.displayPrice)
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .foregroundColor(.white)
                    } else if storeManager.isLoadingProducts {
                        ProgressView()
                            .tint(.zenGlow)
                    } else {
                        Text("—")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .foregroundColor(.zenTextSecondary)
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
                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 24)
                        .background(Color.zenGlow, in: Capsule())
                    }
                    .disabled(purchasingProductID != nil || storeManager.isRestoring)
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
