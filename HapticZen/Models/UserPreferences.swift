import Foundation
import SwiftUI

/// User preferences stored securely and fast via UserDefaults (@AppStorage).
class UserPreferences: ObservableObject {
    @AppStorage("selectedTextureID") var selectedTextureID: String = HapticTexture.bubbleWrap.id
    @AppStorage("hapticIntensityMultiplier") var hapticIntensityMultiplier: Double = 1.0
    @AppStorage("hapticSharpnessMultiplier") var hapticSharpnessMultiplier: Double = 1.0
    @AppStorage("audioVolume") var audioVolume: Double = 0.8
    @AppStorage("audioPitchSensitivity") var audioPitchSensitivity: Double = 1.0
    @AppStorage("selectedSoundscapeID") var selectedSoundscapeID: String = Soundscape.none.id
    @AppStorage("soundscapeVolume") var soundscapeVolume: Double = 0.4
    @AppStorage("isHapticsEnabled") var isHapticsEnabled: Bool = true
    @AppStorage("isAudioEnabled") var isAudioEnabled: Bool = true
    @AppStorage("isHealthKitTrackingEnabled") var isHealthKitTrackingEnabled: Bool = false
    @AppStorage("dailyMindfulSeconds") var dailyMindfulSeconds: Double = 0.0
    @AppStorage("preferredVisualStyle") var preferredVisualStyleString: String = ""
    @AppStorage("hasSeenOnboarding") var hasSeenOnboarding: Bool = false
    @AppStorage("menuTriggerGesture") var menuTriggerGesture: String = "threeFingerTap" // "threeFingerTap" or "edgeSwipe"
    @AppStorage("selectedBreathingPattern") var selectedBreathingPatternString: String = BreathingPattern.paced.rawValue

    var selectedBreathingPattern: BreathingPattern {
        get {
            BreathingPattern(rawValue: selectedBreathingPatternString) ?? .paced
        }
        set {
            selectedBreathingPatternString = newValue.rawValue
        }
    }

    var selectedTexture: HapticTexture {
        get {
            HapticTexture.allTextures.first { $0.id == selectedTextureID } ?? .bubbleWrap
        }
        set {
            selectedTextureID = newValue.id
        }
    }

    var selectedSoundscape: Soundscape {
        get {
            Soundscape.allSoundscapes.first { $0.id == selectedSoundscapeID } ?? .none
        }
        set {
            selectedSoundscapeID = newValue.id
        }
    }

    var preferredVisualStyle: VisualStyle? {
        get {
            guard !preferredVisualStyleString.isEmpty else { return nil }
            return VisualStyle(rawValue: preferredVisualStyleString)
        }
        set {
            preferredVisualStyleString = newValue?.rawValue ?? ""
        }
    }

    /// Returns the active visual style for the current texture, considering user overrides.
    func activeVisualStyle(for texture: HapticTexture) -> VisualStyle {
        return preferredVisualStyle ?? texture.defaultVisualStyle
    }
}
