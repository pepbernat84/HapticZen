import XCTest
@testable import HapticZen

final class UserPreferencesTests: XCTestCase {
    func testDefaultPreferencesValues() {
        let prefs = UserPreferences()
        XCTAssertEqual(prefs.selectedTextureID, HapticTexture.bubbleWrap.id)
        XCTAssertEqual(prefs.selectedTexture, HapticTexture.bubbleWrap)
        XCTAssertEqual(prefs.hapticIntensityMultiplier, 1.0, accuracy: 0.01)
        XCTAssertEqual(prefs.hapticSharpnessMultiplier, 1.0, accuracy: 0.01)
        XCTAssertEqual(prefs.audioVolume, 0.8, accuracy: 0.01)
        XCTAssertEqual(prefs.isHapticsEnabled, true)
        XCTAssertEqual(prefs.isAudioEnabled, true)
        XCTAssertEqual(prefs.selectedBreathingPattern, .paced)
        XCTAssertEqual(prefs.selectedSoundscape, .none)
    }

    func testActiveVisualStyleResolution() {
        let prefs = UserPreferences()

        // When no preferred style is set, it falls back to the texture's default style
        prefs.preferredVisualStyle = nil
        XCTAssertEqual(prefs.activeVisualStyle(for: .bubbleWrap), .ripple)
        XCTAssertEqual(prefs.activeVisualStyle(for: .kineticSand), .particles)
        XCTAssertEqual(prefs.activeVisualStyle(for: .typewriter), .shadow)

        // When user explicitly sets preferred style, it overrides texture default
        prefs.preferredVisualStyle = .particles
        XCTAssertEqual(prefs.activeVisualStyle(for: .bubbleWrap), .particles)
        XCTAssertEqual(prefs.activeVisualStyle(for: .typewriter), .particles)

        // Reset
        prefs.preferredVisualStyle = nil
    }

    func testBreathingPatternSwitching() {
        let prefs = UserPreferences()
        prefs.selectedBreathingPattern = .box
        XCTAssertEqual(prefs.selectedBreathingPattern, .box)

        prefs.selectedBreathingPattern = .relax478
        XCTAssertEqual(prefs.selectedBreathingPattern, .relax478)

        prefs.selectedBreathingPattern = .resonant
        XCTAssertEqual(prefs.selectedBreathingPattern, .resonant)

        // Reset
        prefs.selectedBreathingPattern = .paced
    }

    func testSoundscapeSwitching() {
        let prefs = UserPreferences()
        prefs.selectedSoundscape = .zenGarden
        XCTAssertEqual(prefs.selectedSoundscape, .zenGarden)
        XCTAssertEqual(prefs.selectedSoundscapeID, Soundscape.zenGarden.id)

        // Reset
        prefs.selectedSoundscape = .none
    }
}
