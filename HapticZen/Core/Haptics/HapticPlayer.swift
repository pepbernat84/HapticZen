import CoreHaptics
import Foundation
import SwiftUI

@MainActor
class HapticPlayer {
    private var activeContinuousPlayer: CHHapticAdvancedPatternPlayer?
    private var cachedTransientPlayers: [String: CHHapticPatternPlayer] = [:]
    private var currentTextureID: String?
    private var lastTransientTextureID: String?
    private weak var cachedEngine: CHHapticEngine?
    private var lastTransientPlayTime: TimeInterval = 0
    private var cachedPatterns: [String: CHHapticPattern] = [:]

    func update(velocity: CGFloat, texture: HapticTexture, preferences: UserPreferences, engine: CHHapticEngine) {
        if cachedEngine !== engine {
            invalidatePlayers()
            cachedEngine = engine
        }

        let (intensity, sharpness) = HapticTextureMapper.map(
            velocity: velocity,
            texture: texture,
            multiplier: preferences.hapticIntensityMultiplier,
            sharpnessMultiplier: preferences.hapticSharpnessMultiplier
        )

        if texture.isContinuous {
            if activeContinuousPlayer == nil || currentTextureID != texture.id {
                stop()
                guard let pattern = getPattern(for: texture) else { return }
                do {
                    let player = try engine.makeAdvancedPlayer(with: pattern)
                    player.loopEnabled = true
                    try player.start(atTime: 0)
                    activeContinuousPlayer = player
                    currentTextureID = texture.id
                } catch {
                    print("Failed to start continuous player for \(texture.id): \(error)")
                }
            }

            // Send dynamic parameter updates modulated by velocity
            let intensityParam = CHHapticDynamicParameter(
                parameterID: .hapticIntensityControl,
                value: intensity,
                relativeTime: 0
            )
            let sharpnessParam = CHHapticDynamicParameter(
                parameterID: .hapticSharpnessControl,
                value: sharpness,
                relativeTime: 0
            )
            do {
                try activeContinuousPlayer?.sendParameters([intensityParam, sharpnessParam], atTime: 0)
            } catch {
                print("Failed to send dynamic parameters: \(error)")
                activeContinuousPlayer = nil
                currentTextureID = nil
            }
        } else {
            // For discrete/transient textures (`bubbleWrap`, `typewriter`, `gears`), trigger crisp tactile pops
            // Throttled by velocity so faster dragging spawns more frequent pops
            let now = Date().timeIntervalSinceReferenceDate
            guard velocity > 5 else { return }

            let minInterval: TimeInterval = max(0.04, min(0.28, 120.0 / Double(max(10, velocity))))
            if now - lastTransientPlayTime >= minInterval {
                lastTransientPlayTime = now
                playTransient(texture: texture, intensity: intensity, sharpness: sharpness, engine: engine)
            }
        }
    }

    private func playTransient(texture: HapticTexture, intensity: Float, sharpness: Float, engine: CHHapticEngine) {
        let params = [
            CHHapticDynamicParameter(parameterID: .hapticIntensityControl, value: intensity, relativeTime: 0),
            CHHapticDynamicParameter(parameterID: .hapticSharpnessControl, value: sharpness, relativeTime: 0)
        ]

        func triggerCachedOrNew() throws {
            let player: CHHapticPatternPlayer
            if let existing = cachedTransientPlayers[texture.id] {
                player = existing
            } else {
                guard let pattern = getPattern(for: texture) else { return }
                let created = try engine.makePlayer(with: pattern)
                cachedTransientPlayers[texture.id] = created
                player = created
            }
            lastTransientTextureID = texture.id
            try player.sendParameters(params, atTime: CHHapticTimeImmediate)
            try player.start(atTime: CHHapticTimeImmediate)
        }

        do {
            try triggerCachedOrNew()
        } catch {
            // Evict potentially stale player and retry once with a fresh instance
            cachedTransientPlayers.removeValue(forKey: texture.id)
            do {
                try triggerCachedOrNew()
            } catch {
                print("Failed to play transient haptic: \(error)")
            }
        }
    }

    func stop() {
        do {
            try activeContinuousPlayer?.stop(atTime: 0)
            if let lastID = lastTransientTextureID,
               let transientPlayer = cachedTransientPlayers[lastID] {
                try transientPlayer.stop(atTime: CHHapticTimeImmediate)
            }
        } catch {
            print("Failed to stop haptic player: \(error)")
        }
        activeContinuousPlayer = nil
        currentTextureID = nil
        lastTransientTextureID = nil
    }

    /// Stops and clears all cached players when the underlying CHHapticEngine resets or changes.
    func invalidatePlayers() {
        try? activeContinuousPlayer?.stop(atTime: 0)
        for player in cachedTransientPlayers.values {
            try? player.stop(atTime: CHHapticTimeImmediate)
        }
        activeContinuousPlayer = nil
        currentTextureID = nil
        lastTransientTextureID = nil
        cachedTransientPlayers.removeAll()
        cachedEngine = nil
    }

    private func getPattern(for texture: HapticTexture) -> CHHapticPattern? {
        if let cached = cachedPatterns[texture.id] {
            return cached
        }

        // Try loading AHAP file from bundle
        if let url = Bundle.main.url(forResource: texture.ahapFilename, withExtension: "ahap"),
           let pattern = try? CHHapticPattern(contentsOf: url) {
            cachedPatterns[texture.id] = pattern
            return pattern
        }

        // Procedural fallback pattern
        do {
            if texture.isContinuous {
                let event = CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: texture.baseIntensity),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: texture.baseSharpness)
                    ],
                    relativeTime: 0,
                    duration: 30.0
                )
                let pattern = try CHHapticPattern(events: [event], parameters: [])
                cachedPatterns[texture.id] = pattern
                return pattern
            } else {
                let event = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        CHHapticEventParameter(parameterID: .hapticIntensity, value: texture.baseIntensity),
                        CHHapticEventParameter(parameterID: .hapticSharpness, value: texture.baseSharpness)
                    ],
                    relativeTime: 0
                )
                let pattern = try CHHapticPattern(events: [event], parameters: [])
                cachedPatterns[texture.id] = pattern
                return pattern
            }
        } catch {
            print("Failed to create fallback pattern: \(error)")
            return nil
        }
    }
}
