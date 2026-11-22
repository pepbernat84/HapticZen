import Combine
import XCTest
@testable import HapticZen

final class UserPreferencesTests: XCTestCase {
    private let suiteName = "com.hapticzen.tests.userpreferences"
    private var testDefaults: UserDefaults!
    private var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
        testDefaults = UserDefaults(suiteName: suiteName)!
        testDefaults.removePersistentDomain(forName: suiteName)
        UserDefaults.standard.removeObject(forKey: "savedUnlockedPackIDs")
        UserDefaults.standard.removeObject(forKey: "isHapticsEnabled")
        UserDefaults.standard.removeObject(forKey: "dailyGoalMinutes")
    }

    override func tearDown() {
        cancellables.removeAll()
        testDefaults.removePersistentDomain(forName: suiteName)
        testDefaults = nil
        UserDefaults.standard.removeObject(forKey: "savedUnlockedPackIDs")
        UserDefaults.standard.removeObject(forKey: "isHapticsEnabled")
        UserDefaults.standard.removeObject(forKey: "dailyGoalMinutes")
        super.tearDown()
    }

    func testDefaultPreferencesValues() {
        let prefs = UserPreferences(defaults: testDefaults)
        XCTAssertEqual(prefs.selectedTextureID, HapticTexture.bubbleWrap.id)
        XCTAssertEqual(prefs.selectedTexture, HapticTexture.bubbleWrap)
        XCTAssertEqual(prefs.hapticIntensityMultiplier, 1.0, accuracy: 0.01)
        XCTAssertEqual(prefs.hapticSharpnessMultiplier, 1.0, accuracy: 0.01)
        XCTAssertEqual(prefs.audioVolume, 0.8, accuracy: 0.01)
        XCTAssertEqual(prefs.isHapticsEnabled, true)
        XCTAssertEqual(prefs.isAudioEnabled, true)
        XCTAssertEqual(prefs.dailyGoalMinutes, 10)
        XCTAssertEqual(prefs.selectedBreathingPattern, .paced)
        XCTAssertEqual(prefs.selectedSoundscape, .none)
    }

    func testActiveVisualStyleResolution() {
        let prefs = UserPreferences(defaults: testDefaults)

        // When no preferred style is set, it falls back to the texture's default style
        prefs.preferredVisualStyle = nil
        XCTAssertEqual(prefs.activeVisualStyle(for: .bubbleWrap), .ripple)
        XCTAssertEqual(prefs.activeVisualStyle(for: .kineticSand), .particles)
        XCTAssertEqual(prefs.activeVisualStyle(for: .typewriter), .shadow)

        // When user explicitly sets preferred style, it overrides texture default
        prefs.preferredVisualStyle = .particles
        XCTAssertEqual(prefs.activeVisualStyle(for: .bubbleWrap), .particles)
        XCTAssertEqual(prefs.activeVisualStyle(for: .typewriter), .particles)
    }

    func testBreathingPatternSwitching() {
        let prefs = UserPreferences(defaults: testDefaults)
        prefs.selectedBreathingPattern = .box
        XCTAssertEqual(prefs.selectedBreathingPattern, .box)

        prefs.selectedBreathingPattern = .relax478
        XCTAssertEqual(prefs.selectedBreathingPattern, .relax478)

        prefs.selectedBreathingPattern = .resonant
        XCTAssertEqual(prefs.selectedBreathingPattern, .resonant)
    }

    func testSoundscapeSwitching() {
        let prefs = UserPreferences(defaults: testDefaults)
        prefs.selectedSoundscape = .zenGarden
        XCTAssertEqual(prefs.selectedSoundscape, .zenGarden)
        XCTAssertEqual(prefs.selectedSoundscapeID, Soundscape.zenGarden.id)
    }

    func testMutationsEmitObjectWillChange() {
        let prefs = UserPreferences(defaults: testDefaults)
        var changeCount = 0

        prefs.objectWillChange
            .sink { _ in
                changeCount += 1
            }
            .store(in: &cancellables)

        prefs.isHapticsEnabled = false
        prefs.selectedTexture = .kineticSand
        prefs.dailyGoalMinutes = 20
        prefs.audioVolume = 0.5
        prefs.selectedSoundscape = .zenGarden
        prefs.selectedBreathingPattern = .box

        XCTAssertEqual(changeCount, 6)
    }

    @MainActor
    func testAppStateBubblesUpUserPreferencesChanges() {
        let appState = AppState()
        var changeCount = 0

        appState.objectWillChange
            .sink { _ in
                changeCount += 1
            }
            .store(in: &cancellables)

        appState.preferences.isHapticsEnabled.toggle()
        appState.preferences.dailyGoalMinutes = 25

        XCTAssertGreaterThanOrEqual(changeCount, 2)
    }

    func testPreferencesPersistAcrossInstances() {
        let first = UserPreferences(defaults: testDefaults)
        first.selectedTexture = .gears
        first.isHapticsEnabled = false
        first.audioVolume = 0.35
        first.dailyGoalMinutes = 30
        first.selectedBreathingPattern = .relax478
        first.selectedSoundscape = .tibetanBowls

        let second = UserPreferences(defaults: testDefaults)
        XCTAssertEqual(second.selectedTexture, .gears)
        XCTAssertEqual(second.isHapticsEnabled, false)
        XCTAssertEqual(second.audioVolume, 0.35, accuracy: 0.001)
        XCTAssertEqual(second.dailyGoalMinutes, 30)
        XCTAssertEqual(second.selectedBreathingPattern, .relax478)
        XCTAssertEqual(second.selectedSoundscape, .tibetanBowls)
    }

    func testDailyGoalMinutesDefaultAndClamping() {
        let prefs = UserPreferences(defaults: testDefaults)
        XCTAssertEqual(prefs.dailyGoalMinutes, 10)

        prefs.dailyGoalMinutes = 20
        XCTAssertEqual(prefs.dailyGoalMinutes, 20)

        prefs.dailyGoalMinutes = 0
        XCTAssertEqual(prefs.dailyGoalMinutes, 1)

        prefs.dailyGoalMinutes = 500
        XCTAssertEqual(prefs.dailyGoalMinutes, 120)
    }
}
