import CoreHaptics
import Foundation
import SwiftUI

/// Manages continuous tactile breathing guidance patterns synced with the visual inhale/exhale cycle.
@MainActor
class BreathingHapticPlayer {
    private var activePlayer: CHHapticAdvancedPatternPlayer?
    private var isPlaying = false

    func startBreathingSession() {
        guard isPlaying == false else { return }
        stopBreathingSession()

        HapticEngine.shared.start()
        guard let engine = HapticEngine.shared.engine else { return }

        // Create a long 60-second continuous base pattern that we can modulate continuously
        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.2),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
            ],
            relativeTime: 0,
            duration: 60.0
        )

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makeAdvancedPlayer(with: pattern)
            player.loopEnabled = true
            try player.start(atTime: 0)
            activePlayer = player
            isPlaying = true
        } catch {
            print("Failed to create advanced player for breathing: \(error)")
        }
    }

    func updatePhase(progress: Double, isInhaling: Bool, preferences: UserPreferences) {
        guard isPlaying, let player = activePlayer, preferences.isHapticsEnabled else {
            if activePlayer != nil && !preferences.isHapticsEnabled {
                stopBreathingSession()
            }
            return
        }

        let baseMultiplier = Float(preferences.hapticIntensityMultiplier)
        let sharpnessMultiplier = Float(preferences.hapticSharpnessMultiplier)

        let targetIntensity: Float
        let targetSharpness: Float

        if isInhaling {
            // Smoothly ramp intensity up from 0.15 to 0.85
            targetIntensity = max(0.1, min(1.0, Float(0.15 + 0.7 * progress) * baseMultiplier))
            targetSharpness = max(0.1, min(1.0, Float(0.2 + 0.4 * progress) * sharpnessMultiplier))
        } else {
            // Smoothly ramp intensity down from 0.85 to 0.15
            targetIntensity = max(0.1, min(1.0, Float(0.85 - 0.7 * progress) * baseMultiplier))
            targetSharpness = max(0.1, min(1.0, Float(0.6 - 0.4 * progress) * sharpnessMultiplier))
        }

        let intensityParam = CHHapticDynamicParameter(
            parameterID: .hapticIntensityControl,
            value: targetIntensity,
            relativeTime: 0
        )
        let sharpnessParam = CHHapticDynamicParameter(
            parameterID: .hapticSharpnessControl,
            value: targetSharpness,
            relativeTime: 0
        )

        do {
            try player.sendParameters([intensityParam, sharpnessParam], atTime: 0)
        } catch {
            // If engine disconnected or reset, try recovering
            stopBreathingSession()
            startBreathingSession()
        }
    }

    func stopBreathingSession() {
        do {
            try activePlayer?.stop(atTime: 0)
        } catch {
            print("Error stopping breathing haptics: \(error)")
        }
        activePlayer = nil
        isPlaying = false
    }
}
