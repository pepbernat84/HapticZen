import XCTest
@testable import HapticZen

final class AppStateTests: XCTestCase {
    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "savedUnlockedPackIDs")
        UserDefaults.standard.removeObject(forKey: "selectedTextureID")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "savedUnlockedPackIDs")
        UserDefaults.standard.removeObject(forKey: "selectedTextureID")
        super.tearDown()
    }

    @MainActor
    func testInitialUnlockedPacksContainsFreePack() {
        let appState = AppState()
        XCTAssertTrue(appState.unlockedPackIDs.contains(TexturePack.freePack.id))
    }

    @MainActor
    func testFreeTexturesAreAlwaysUnlocked() {
        let appState = AppState()
        XCTAssertTrue(appState.isUnlocked(texture: .bubbleWrap))
        XCTAssertTrue(appState.isUnlocked(texture: .kineticSand))
    }

    @MainActor
    func testUnlockPackGrantsAccess() {
        let appState = AppState()
        appState.unlock(packID: TexturePack.mechanicalPack.id)
        XCTAssertTrue(appState.isUnlocked(texture: .typewriter))
        XCTAssertTrue(appState.isUnlocked(texture: .gears))
    }

    @MainActor
    func testSyncUnlockedPacksAlwaysRetainsFreePack() {
        let appState = AppState()
        appState.syncUnlockedPacks([])
        XCTAssertTrue(appState.unlockedPackIDs.contains(TexturePack.freePack.id))
    }

    @MainActor
    func testSyncUnlockedPacksPreservesCachedPacksWhenEmpty() {
        let appState = AppState()
        appState.unlock(packID: TexturePack.mechanicalPack.id)
        XCTAssertTrue(appState.unlockedPackIDs.contains(TexturePack.mechanicalPack.id))

        // Offline StoreKit query returning empty active packs must not wipe cached unlocks
        appState.syncUnlockedPacks([])
        XCTAssertTrue(appState.unlockedPackIDs.contains(TexturePack.mechanicalPack.id))
        XCTAssertTrue(appState.unlockedPackIDs.contains(TexturePack.freePack.id))
    }

    @MainActor
    func testSyncUnlockedPacksRemovesExplicitlyRevokedPack() {
        let appState = AppState()
        appState.unlock(packID: TexturePack.mechanicalPack.id)
        appState.unlock(packID: TexturePack.naturePack.id)

        appState.syncUnlockedPacks([], revokedPackIDs: [TexturePack.mechanicalPack.id])
        XCTAssertFalse(appState.unlockedPackIDs.contains(TexturePack.mechanicalPack.id))
        XCTAssertTrue(appState.unlockedPackIDs.contains(TexturePack.naturePack.id))
        XCTAssertTrue(appState.unlockedPackIDs.contains(TexturePack.freePack.id))
    }

    @MainActor
    func testSyncUnlockedPacksNeverRemovesFreePackEvenIfRevoked() {
        let appState = AppState()
        appState.syncUnlockedPacks([], revokedPackIDs: [TexturePack.freePack.id])
        XCTAssertTrue(appState.unlockedPackIDs.contains(TexturePack.freePack.id))
    }

    @MainActor
    func testSyncUnlockedPacksResetsSelectedTextureIfRevoked() {
        let appState = AppState()
        appState.unlock(packID: TexturePack.mechanicalPack.id)
        appState.selectTexture(.typewriter)
        XCTAssertEqual(appState.preferences.selectedTexture, .typewriter)

        appState.syncUnlockedPacks([], revokedPackIDs: [TexturePack.mechanicalPack.id])
        XCTAssertEqual(appState.preferences.selectedTexture, .bubbleWrap)
    }

    @MainActor
    func testSelectTextureWhenUnlocked() {
        let appState = AppState()
        appState.selectTexture(.kineticSand)
        XCTAssertEqual(appState.preferences.selectedTexture, .kineticSand)
        XCTAssertFalse(appState.isStorePresented)
    }

    @MainActor
    func testSelectTextureWhenLockedOpensStoreSheetWhenMenuClosed() {
        let appState = AppState()
        appState.syncUnlockedPacks([TexturePack.freePack.id], replaceExisting: true)

        appState.isMenuPresented = false
        appState.isStorePresented = false
        appState.selectTexture(.heavyRain)

        XCTAssertTrue(appState.isStorePresented)
    }

    @MainActor
    func testSelectTextureWhenLockedSwitchesMenuTabWhenMenuOpen() {
        let appState = AppState()
        appState.syncUnlockedPacks([TexturePack.freePack.id], replaceExisting: true)

        appState.isMenuPresented = true
        appState.selectedMenuTab = .textures
        appState.isStorePresented = false
        appState.selectTexture(.heavyRain)

        XCTAssertEqual(appState.selectedMenuTab, .store)
        XCTAssertFalse(appState.isStorePresented)
    }

    @MainActor
    func testDeepLinkingRoutes() {
        let appState = AppState()

        // Deep link to breathing
        appState.handleDeepLink(URL(string: "hapticzen://breathing")!)
        XCTAssertTrue(appState.isMenuPresented)
        XCTAssertFalse(appState.isStorePresented)
        XCTAssertEqual(appState.selectedMenuTab, .breathing)

        // Deep link to store while menu is open switches to store tab (no nested sheet)
        appState.handleDeepLink(URL(string: "hapticzen://store")!)
        XCTAssertEqual(appState.selectedMenuTab, .store)
        XCTAssertFalse(appState.isStorePresented)

        // Deep link to canvas closes menu and store
        appState.handleDeepLink(URL(string: "hapticzen://canvas")!)
        XCTAssertFalse(appState.isMenuPresented)
        XCTAssertFalse(appState.isStorePresented)

        // Deep link to store when menu is closed presents store sheet
        appState.handleDeepLink(URL(string: "hapticzen://store")!)
        XCTAssertTrue(appState.isStorePresented)

        // Deep link to textures dismisses store sheet and opens textures tab
        appState.handleDeepLink(URL(string: "hapticzen://textures")!)
        XCTAssertTrue(appState.isMenuPresented)
        XCTAssertFalse(appState.isStorePresented)
        XCTAssertEqual(appState.selectedMenuTab, .textures)

        // Unknown URL should not crash
        appState.handleDeepLink(URL(string: "hapticzen://unknown_action")!)
    }

    func testStoreAlertInfoLocalizedMessage() {
        let withoutDetail = StoreAlertInfo(
            titleKey: "store.error.title",
            messageKey: "store.error.purchaseFailed"
        )
        XCTAssertFalse(withoutDetail.localizedMessage.isEmpty)
        XCTAssertFalse(withoutDetail.localizedMessage.contains("\n\n"))

        let withDetail = StoreAlertInfo(
            titleKey: "store.error.title",
            messageKey: "store.error.purchaseFailed",
            detailMessage: "Network offline"
        )
        XCTAssertTrue(withDetail.localizedMessage.contains("Network offline"))
        XCTAssertTrue(withDetail.localizedMessage.contains("\n\n"))
    }
}
