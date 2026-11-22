import Combine
import Foundation
import SwiftUI

/// User preferences backed by `UserDefaults` with `@Published` reactivity so `AppState` receives all updates reliably.
class UserPreferences: ObservableObject {
    static let dailyGoalOptions: [Int] = [5, 10, 15, 20, 30, 45, 60]

    private enum Keys {
        static let selectedTextureID = "selectedTextureID"
        static let hapticIntensityMultiplier = "hapticIntensityMultiplier"
        static let hapticSharpnessMultiplier = "hapticSharpnessMultiplier"
        static let audioVolume = "audioVolume"
        static let audioPitchSensitivity = "audioPitchSensitivity"
        static let selectedSoundscapeID = "selectedSoundscapeID"
        static let soundscapeVolume = "soundscapeVolume"
        static let isHapticsEnabled = "isHapticsEnabled"
        static let isAudioEnabled = "isAudioEnabled"
        static let isHealthKitTrackingEnabled = "isHealthKitTrackingEnabled"
        static let dailyMindfulSeconds = "dailyMindfulSeconds"
        static let dailyGoalMinutes = "dailyGoalMinutes"
        static let preferredVisualStyle = "preferredVisualStyle"
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let selectedBreathingPattern = "selectedBreathingPattern"
    }

    private let defaults: UserDefaults

    @Published var selectedTextureID: String {
        didSet { defaults.set(selectedTextureID, forKey: Keys.selectedTextureID) }
    }

    @Published var hapticIntensityMultiplier: Double {
        didSet { defaults.set(hapticIntensityMultiplier, forKey: Keys.hapticIntensityMultiplier) }
    }

    @Published var hapticSharpnessMultiplier: Double {
        didSet { defaults.set(hapticSharpnessMultiplier, forKey: Keys.hapticSharpnessMultiplier) }
    }

    @Published var audioVolume: Double {
        didSet { defaults.set(audioVolume, forKey: Keys.audioVolume) }
    }

    @Published var audioPitchSensitivity: Double {
        didSet { defaults.set(audioPitchSensitivity, forKey: Keys.audioPitchSensitivity) }
    }

    @Published var selectedSoundscapeID: String {
        didSet { defaults.set(selectedSoundscapeID, forKey: Keys.selectedSoundscapeID) }
    }

    @Published var soundscapeVolume: Double {
        didSet { defaults.set(soundscapeVolume, forKey: Keys.soundscapeVolume) }
    }

    @Published var isHapticsEnabled: Bool {
        didSet { defaults.set(isHapticsEnabled, forKey: Keys.isHapticsEnabled) }
    }

    @Published var isAudioEnabled: Bool {
        didSet { defaults.set(isAudioEnabled, forKey: Keys.isAudioEnabled) }
    }

    @Published var isHealthKitTrackingEnabled: Bool {
        didSet { defaults.set(isHealthKitTrackingEnabled, forKey: Keys.isHealthKitTrackingEnabled) }
    }

    @Published var dailyMindfulSeconds: Double {
        didSet { defaults.set(dailyMindfulSeconds, forKey: Keys.dailyMindfulSeconds) }
    }

    @Published var dailyGoalMinutes: Int {
        didSet {
            let clamped = max(1, min(120, dailyGoalMinutes))
            if dailyGoalMinutes != clamped {
                dailyGoalMinutes = clamped
            }
            defaults.set(clamped, forKey: Keys.dailyGoalMinutes)
        }
    }

    @Published var preferredVisualStyleString: String {
        didSet { defaults.set(preferredVisualStyleString, forKey: Keys.preferredVisualStyle) }
    }

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var selectedBreathingPatternString: String {
        didSet { defaults.set(selectedBreathingPatternString, forKey: Keys.selectedBreathingPattern) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        self.selectedTextureID = defaults.string(forKey: Keys.selectedTextureID) ?? HapticTexture.bubbleWrap.id
        self.hapticIntensityMultiplier = defaults.object(forKey: Keys.hapticIntensityMultiplier) != nil
            ? defaults.double(forKey: Keys.hapticIntensityMultiplier)
            : 1.0
        self.hapticSharpnessMultiplier = defaults.object(forKey: Keys.hapticSharpnessMultiplier) != nil
            ? defaults.double(forKey: Keys.hapticSharpnessMultiplier)
            : 1.0
        self.audioVolume = defaults.object(forKey: Keys.audioVolume) != nil
            ? defaults.double(forKey: Keys.audioVolume)
            : 0.8
        self.audioPitchSensitivity = defaults.object(forKey: Keys.audioPitchSensitivity) != nil
            ? defaults.double(forKey: Keys.audioPitchSensitivity)
            : 1.0
        self.selectedSoundscapeID = defaults.string(forKey: Keys.selectedSoundscapeID) ?? Soundscape.none.id
        self.soundscapeVolume = defaults.object(forKey: Keys.soundscapeVolume) != nil
            ? defaults.double(forKey: Keys.soundscapeVolume)
            : 0.4
        self.isHapticsEnabled = defaults.object(forKey: Keys.isHapticsEnabled) != nil
            ? defaults.bool(forKey: Keys.isHapticsEnabled)
            : true
        self.isAudioEnabled = defaults.object(forKey: Keys.isAudioEnabled) != nil
            ? defaults.bool(forKey: Keys.isAudioEnabled)
            : true
        self.isHealthKitTrackingEnabled = defaults.object(forKey: Keys.isHealthKitTrackingEnabled) != nil
            ? defaults.bool(forKey: Keys.isHealthKitTrackingEnabled)
            : false
        self.dailyMindfulSeconds = defaults.object(forKey: Keys.dailyMindfulSeconds) != nil
            ? defaults.double(forKey: Keys.dailyMindfulSeconds)
            : 0.0

        let rawGoal: Int
        if defaults.object(forKey: Keys.dailyGoalMinutes) != nil {
            rawGoal = defaults.integer(forKey: Keys.dailyGoalMinutes)
        } else if defaults === UserDefaults.standard {
            rawGoal = SharedDataManager.dailyGoalMinutes
        } else {
            rawGoal = 10
        }
        self.dailyGoalMinutes = max(1, min(120, rawGoal))

        self.preferredVisualStyleString = defaults.string(forKey: Keys.preferredVisualStyle) ?? ""
        self.hasSeenOnboarding = defaults.object(forKey: Keys.hasSeenOnboarding) != nil
            ? defaults.bool(forKey: Keys.hasSeenOnboarding)
            : false
        self.selectedBreathingPatternString = defaults.string(forKey: Keys.selectedBreathingPattern) ?? BreathingPattern.paced.rawValue
    }

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
