import CoreGraphics
import XCTest
@testable import HapticZen

final class HapticTextureMapperTests: XCTestCase {
    func testVelocityMappingBoundaries() {
        let texture = HapticTexture.bubbleWrap // baseIntensity: 0.8, baseSharpness: 0.9
        
        // Zero velocity -> normalizedVelocity 0 -> offset (-0.5 * 0.6 = -0.3) -> 0.5 intensity
        let zeroResult = HapticTextureMapper.map(velocity: 0, texture: texture, multiplier: 1.0)
        XCTAssertEqual(zeroResult.intensity, 0.5, accuracy: 0.01)
        XCTAssertEqual(zeroResult.sharpness, 0.65, accuracy: 0.01)

        // Max velocity (800) -> normalizedVelocity 1.0 -> offset (+0.5 * 0.6 = +0.3) -> 1.0 (clamped)
        let maxResult = HapticTextureMapper.map(velocity: 800, texture: texture, multiplier: 1.0)
        XCTAssertEqual(maxResult.intensity, 1.0, accuracy: 0.01)
        XCTAssertEqual(maxResult.sharpness, 1.0, accuracy: 0.01)
        
        // Multiplier scaling check
        let halfMultiplier = HapticTextureMapper.map(velocity: 400, texture: texture, multiplier: 0.5)
        XCTAssertGreaterThan(halfMultiplier.intensity, 0.1)
        XCTAssertLessThanOrEqual(halfMultiplier.intensity, 1.0)
    }

    func testDragStateVelocityCalculation() {
        var state = DragState()
        let t0 = TimeInterval(100.0)
        state.update(to: CGPoint(x: 0, y: 0), timestamp: t0)
        XCTAssertTrue(state.isDragging)
        XCTAssertEqual(state.velocity, 0)

        // Move 100 points in 0.1 seconds -> raw velocity 1000 pts/sec
        // Since velocity is smoothed: (0 * 0.4) + (1000 * 0.6) = 600
        state.update(to: CGPoint(x: 100, y: 0), timestamp: t0 + 0.1)
        XCTAssertEqual(state.velocity, 600, accuracy: 0.1)
        XCTAssertEqual(state.totalDistanceTraveled, 100, accuracy: 0.1)
    }

    func testDragStateEndDragResetsVelocity() {
        var state = DragState()
        state.update(to: CGPoint(x: 0, y: 0), timestamp: 100.0)
        state.update(to: CGPoint(x: 100, y: 100), timestamp: 100.1)
        XCTAssertTrue(state.isDragging)
        XCTAssertGreaterThan(state.velocity, 0)

        state.endDrag()
        XCTAssertFalse(state.isDragging)
        XCTAssertEqual(state.velocity, 0)
    }

    func testAllTexturesIntegrityAndIcons() {
        XCTAssertEqual(HapticTexture.allTextures.count, 6)
        for texture in HapticTexture.allTextures {
            XCTAssertFalse(texture.id.isEmpty)
            XCTAssertFalse(texture.ahapFilename.isEmpty)
            XCTAssertFalse(texture.audioFilename.isEmpty)
            XCTAssertFalse(texture.iconName.isEmpty)
            XCTAssertGreaterThanOrEqual(texture.baseIntensity, 0.1)
            XCTAssertLessThanOrEqual(texture.baseIntensity, 1.0)
            XCTAssertGreaterThanOrEqual(texture.baseSharpness, 0.1)
            XCTAssertLessThanOrEqual(texture.baseSharpness, 1.0)
        }
    }
}

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
}

final class BreathingPhaseTests: XCTestCase {
    func testBreathingPhaseDurations() {
        XCTAssertEqual(BreathingPhase.inhale.duration, 4.0)
        XCTAssertEqual(BreathingPhase.holdIn.duration, 2.0)
        XCTAssertEqual(BreathingPhase.exhale.duration, 6.0)
        XCTAssertEqual(BreathingPhase.holdOut.duration, 2.0)

        let totalCycle = BreathingPhase.allCases.reduce(0) { $0 + $1.duration }
        XCTAssertEqual(totalCycle, 14.0)
    }

    func testBreathingPhaseCycleProgression() {
        var phase: BreathingPhase = .inhale
        func advance(from p: BreathingPhase) -> BreathingPhase {
            switch p {
            case .inhale: return .holdIn
            case .holdIn: return .exhale
            case .exhale: return .holdOut
            case .holdOut: return .inhale
            }
        }

        phase = advance(from: phase)
        XCTAssertEqual(phase, .holdIn)
        phase = advance(from: phase)
        XCTAssertEqual(phase, .exhale)
        phase = advance(from: phase)
        XCTAssertEqual(phase, .holdOut)
        phase = advance(from: phase)
        XCTAssertEqual(phase, .inhale)
    }

    func testBreathingPatternsDurationsAndCycles() {
        // Paced (4-2-6-2)
        let paced = BreathingPattern.paced
        XCTAssertEqual(paced.duration(for: .inhale), 4.0)
        XCTAssertEqual(paced.duration(for: .holdIn), 2.0)
        XCTAssertEqual(paced.duration(for: .exhale), 6.0)
        XCTAssertEqual(paced.duration(for: .holdOut), 2.0)
        XCTAssertEqual(paced.totalCycleDuration, 14.0)

        // Box (4-4-4-4)
        let box = BreathingPattern.box
        XCTAssertEqual(box.duration(for: .inhale), 4.0)
        XCTAssertEqual(box.duration(for: .holdIn), 4.0)
        XCTAssertEqual(box.duration(for: .exhale), 4.0)
        XCTAssertEqual(box.duration(for: .holdOut), 4.0)
        XCTAssertEqual(box.totalCycleDuration, 16.0)

        // Relax 4-7-8
        let relax478 = BreathingPattern.relax478
        XCTAssertEqual(relax478.duration(for: .inhale), 4.0)
        XCTAssertEqual(relax478.duration(for: .holdIn), 7.0)
        XCTAssertEqual(relax478.duration(for: .exhale), 8.0)
        XCTAssertEqual(relax478.duration(for: .holdOut), 0.0)
        XCTAssertEqual(relax478.totalCycleDuration, 19.0)

        // Resonant Coherence (5-5)
        let resonant = BreathingPattern.resonant
        XCTAssertEqual(resonant.duration(for: .inhale), 5.0)
        XCTAssertEqual(resonant.duration(for: .holdIn), 0.0)
        XCTAssertEqual(resonant.duration(for: .exhale), 5.0)
        XCTAssertEqual(resonant.duration(for: .holdOut), 0.0)
        XCTAssertEqual(resonant.totalCycleDuration, 10.0)
    }

    func testUserPreferencesBreathingPatternDefault() {
        let prefs = UserPreferences()
        XCTAssertEqual(prefs.selectedBreathingPattern, .paced)
        prefs.selectedBreathingPattern = .box
        XCTAssertEqual(prefs.selectedBreathingPattern, .box)
        // Reset to default
        prefs.selectedBreathingPattern = .paced
    }
}

final class TexturePackTests: XCTestCase {
    func testPackLookupForTextureID() {
        let bubblePack = TexturePack.pack(for: "bubble_wrap")
        XCTAssertEqual(bubblePack?.id, TexturePack.freePack.id)

        let typewriterPack = TexturePack.pack(for: "typewriter")
        XCTAssertEqual(typewriterPack?.id, TexturePack.mechanicalPack.id)

        let rainPack = TexturePack.pack(for: "heavy_rain")
        XCTAssertEqual(rainPack?.id, TexturePack.naturePack.id)

        let invalidPack = TexturePack.pack(for: "non_existent")
        XCTAssertNil(invalidPack)
    }

    func testSoundscapeIntegrity() {
        for soundscape in Soundscape.allCases {
            XCTAssertFalse(soundscape.id.isEmpty)
            XCTAssertFalse(soundscape.iconName.isEmpty)
        }
    }
}

final class SharedDataManagerAndDeepLinkTests: XCTestCase {
    func testSharedDataManagerDailyCalculations() {
        let initialSeconds = SharedDataManager.getDailyMindfulSeconds()
        SharedDataManager.recordMindfulDuration(30.0)
        let updatedSeconds = SharedDataManager.getDailyMindfulSeconds()
        XCTAssertGreaterThanOrEqual(updatedSeconds, initialSeconds + 29.0)

        // Goal minutes check
        XCTAssertGreaterThanOrEqual(SharedDataManager.dailyGoalMinutes, 1)
    }

    @MainActor
    func testAppStateDeepLinking() {
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
    }
}
