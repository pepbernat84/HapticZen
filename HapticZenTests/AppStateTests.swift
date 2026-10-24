import XCTest
@testable import HapticZen

final class AppStateTests: XCTestCase {
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
    func testSelectTextureWhenUnlocked() {
        let appState = AppState()
        appState.selectTexture(.kineticSand)
        XCTAssertEqual(appState.preferences.selectedTexture, .kineticSand)
        XCTAssertFalse(appState.isStorePresented)
    }

    @MainActor
    func testSelectTextureWhenLockedOpensStore() {
        let appState = AppState()
        // Ensure nature pack is not unlocked
        var current = appState.unlockedPackIDs
        current.remove(TexturePack.naturePack.id)
        appState.syncUnlockedPacks(current)

        appState.isStorePresented = false
        appState.selectTexture(.heavyRain)
        XCTAssertTrue(appState.isStorePresented)
    }

    @MainActor
    func testDeepLinkingRoutes() {
        let appState = AppState()

        // Deep link to breathing
        appState.handleDeepLink(URL(string: "hapticzen://breathing")!)
        XCTAssertTrue(appState.isMenuPresented)
        XCTAssertEqual(appState.selectedMenuTab, .breathing)

        // Deep link to canvas
        appState.handleDeepLink(URL(string: "hapticzen://canvas")!)
        XCTAssertFalse(appState.isMenuPresented)

        // Deep link to textures
        appState.handleDeepLink(URL(string: "hapticzen://textures")!)
        XCTAssertTrue(appState.isMenuPresented)
        XCTAssertEqual(appState.selectedMenuTab, .textures)

        // Deep link to store
        appState.handleDeepLink(URL(string: "hapticzen://store")!)
        XCTAssertTrue(appState.isStorePresented)

        // Unknown URL should not crash
        appState.handleDeepLink(URL(string: "hapticzen://unknown_action")!)
    }
}
