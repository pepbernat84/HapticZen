import CoreHaptics
import Foundation

/// Maps finger drag velocity to CHHapticDynamicParameter intensity and sharpness controls.
struct HapticTextureMapper {
    static func map(velocity: CGFloat, texture: HapticTexture, multiplier: Double, sharpnessMultiplier: Double = 1.0) -> (intensity: Float, sharpness: Float) {
        // Linear clamping from 0 to 800 pts/sec -> [0.1, 1.0] relative curve
        let normalizedVelocity = Float(min(1.0, max(0.0, velocity / 800.0)))
        let intensityOffset = (normalizedVelocity - 0.5) * 0.6 * Float(multiplier)
        let sharpnessOffset = (normalizedVelocity - 0.5) * 0.5 * Float(sharpnessMultiplier)

        let finalIntensity = max(0.1, min(1.0, texture.baseIntensity + intensityOffset))
        let finalSharpness = max(0.1, min(1.0, texture.baseSharpness + sharpnessOffset))

        return (finalIntensity, finalSharpness)
    }
}
