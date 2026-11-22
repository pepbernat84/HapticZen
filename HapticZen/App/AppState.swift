import Combine
import Foundation
import SwiftUI

/// Available navigation tabs within the menu sheet.
enum MenuTab: LocalizedStringKey, CaseIterable {
    case textures = "menu.tab.textures"
    case breathing = "menu.tab.breathing"
    case store = "menu.tab.store"
    case settings = "menu.tab.settings"
}

/// Main observable application state shared across views and coordinators.
@MainActor
class AppState: ObservableObject {
    @Published var preferences = UserPreferences()
    @Published var unlockedPackIDs: Set<String> = [TexturePack.freePack.id]
    @Published var isMenuPresented: Bool = false
    @Published var isStorePresented: Bool = false
    @Published var selectedMenuTab: MenuTab = .textures
    
    private var cancellables = Set<AnyCancellable>()

    init() {
        if let saved = UserDefaults.standard.array(forKey: "savedUnlockedPackIDs") as? [String] {
            var loaded = Set(saved)
            loaded.insert(TexturePack.freePack.id)
            self.unlockedPackIDs = loaded
        }
        
        // Bubble up preferences changes to trigger AppState views re-render
        preferences.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        Task { @MainActor [weak self] in
            guard let self = self else { return }
            StoreManager.shared.startListeningForUpdates(in: self)
        }
    }

    /// Returns true if the user has access to the specified texture.
    func isUnlocked(texture: HapticTexture) -> Bool {
        guard let pack = TexturePack.pack(for: texture.id) else {
            return false
        }
        return pack.isFree || unlockedPackIDs.contains(pack.id)
    }

    /// Opens the store without triggering nested-sheet conflicts: switches to the store tab
    /// if the menu sheet is already open, or presents the standalone store sheet otherwise.
    func openStore() {
        if isMenuPresented {
            selectedMenuTab = .store
        } else {
            isStorePresented = true
        }
    }

    /// Selects a texture if unlocked; otherwise opens the store.
    func selectTexture(_ texture: HapticTexture) {
        if isUnlocked(texture: texture) {
            preferences.selectedTexture = texture
        } else {
            openStore()
        }
    }

    /// Unlocks a pack (called after successful IAP or restore).
    func unlock(packID: String) {
        unlockedPackIDs.insert(packID)
        UserDefaults.standard.set(Array(unlockedPackIDs), forKey: "savedUnlockedPackIDs")
    }

    /// Synchronizes unlocked packs with verified entitlements while preserving offline cached unlocks.
    /// Packs are only removed when explicitly listed in `revokedPackIDs` (or when `replaceExisting` is true).
    func syncUnlockedPacks(
        _ activePackIDs: Set<String>,
        revokedPackIDs: Set<String> = [],
        replaceExisting: Bool = false
    ) {
        var newSet: Set<String>
        if replaceExisting {
            newSet = activePackIDs
        } else {
            newSet = unlockedPackIDs.union(activePackIDs)
            newSet.subtract(revokedPackIDs)
        }
        newSet.insert(TexturePack.freePack.id)

        if self.unlockedPackIDs != newSet {
            self.unlockedPackIDs = newSet
            UserDefaults.standard.set(Array(newSet), forKey: "savedUnlockedPackIDs")
        }

        if !isUnlocked(texture: preferences.selectedTexture) {
            preferences.selectedTexture = .bubbleWrap
        }
    }

    /// Handles incoming deep links (e.g. from Home or Lock Screen widgets).
    func handleDeepLink(_ url: URL) {
        let action = url.host ?? url.pathComponents.last ?? ""
        switch action {
        case "breathing":
            isStorePresented = false
            selectedMenuTab = .breathing
            isMenuPresented = true
        case "canvas":
            isMenuPresented = false
            isStorePresented = false
        case "textures":
            isStorePresented = false
            selectedMenuTab = .textures
            isMenuPresented = true
        case "store":
            openStore()
        default:
            break
        }
    }
}
