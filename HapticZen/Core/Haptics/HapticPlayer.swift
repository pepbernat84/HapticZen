import CoreHaptics
import Foundation
import SwiftUI

@MainActor
class HapticPlayer {
    private var activeContinuousPlayer: CHHapticAdvancedPatternPlayer?
    private var activeTransientPlayer: CHHapticAdvancedPatternPlayer?
    private var currentTextureID: String?
    private var lastTransientPlayTime: TimeInterval = 0
    private var cachedPatterns: [String: CHHapticPattern] = [:]

    func update(velocity: CGFloat, texture: HapticTexture, preferences: UserPreferences, engine: CHHapticEngine) {
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
            }
        } else {
            // For discrete/transient textures (`bubbleWrap`, `typewriter`, `gears`), trigger crisp tactile pops
            // Throttled by velocity so faster dragging spawns more frequent pops
            let now = Date().timeIntervalSinceReferenceDate
            guard velocity > 5 else { return }

            let minInterval: TimeInterval = max(0.04, min(0.28, 120.0 / Double(max(10, velocity))))
            if now - lastTransientPlayTime >= minInterval {
                lastTransientPlayTime = now
                guard let pattern = getPattern(for: texture) else { return }
                do {
                    let player = try engine.makeAdvancedPlayer(with: pattern)
                    activeTransientPlayer = player
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
                    try player.sendParameters([intensityParam, sharpnessParam], atTime: 0)
                    try player.start(atTime: 0)
                } catch {
                    print("Failed to play transient haptic: \(error)")
                }
            }
        }
    }

    func stop() {
        do {
            try activeContinuousPlayer?.stop(atTime: 0)
            try activeTransientPlayer?.stop(atTime: 0)
        } catch {
            print("Failed to stop haptic player: \(error)")
        }
        activeContinuousPlayer = nil
        activeTransientPlayer = nil
        currentTextureID = nil
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
