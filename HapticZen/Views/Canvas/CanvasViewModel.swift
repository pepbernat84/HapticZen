import Combine
import CoreGraphics
import Foundation
import SwiftUI

@MainActor
class CanvasViewModel: ObservableObject {
    @Published var dragState = DragState()
    @Published var touchPoints: [CGPoint] = []
    @Published var activeRipplePoints: [RippleEffect] = []
    @Published var activeParticles: [ParticleEffect] = []
    
    private var lastRippleSpawnTime: TimeInterval = 0
    private var lastParticleSpawnTime: TimeInterval = 0
    private var dragStartTime: TimeInterval?

    struct RippleEffect: Identifiable {
        let id = UUID()
        let position: CGPoint
        let startTime: TimeInterval
        let maxRadius: CGFloat
    }

    struct ParticleEffect: Identifiable {
        let id = UUID()
        let position: CGPoint
        let velocity: CGVector
        let startTime: TimeInterval
        let size: CGFloat
        let color: Color
    }

    func onDragChanged(value: DragGesture.Value, canvasSize: CGSize, texture: HapticTexture, preferences: UserPreferences) {
        let now = Date().timeIntervalSinceReferenceDate
        if dragStartTime == nil {
            dragStartTime = now
        }
        dragState.update(to: value.location, timestamp: now)
        
        // Update visual feedback state
        touchPoints.append(value.location)
        if touchPoints.count > 30 {
            touchPoints.removeFirst()
        }

        // Clean up expired visual effects
        activeRipplePoints.removeAll { now - $0.startTime > 0.85 }
        activeParticles.removeAll { now - $0.startTime > 1.2 }

        // Spawn ripples or particles depending on active visual style
        let style = preferences.activeVisualStyle(for: texture)
        if style == .ripple && now - lastRippleSpawnTime > 0.12 && dragState.velocity > 20 {
            lastRippleSpawnTime = now
            activeRipplePoints.append(RippleEffect(
                position: value.location,
                startTime: now,
                maxRadius: min(130, max(45, dragState.velocity * 0.12))
            ))
            if activeRipplePoints.count > 12 {
                activeRipplePoints.removeFirst()
            }
        } else if style == .particles && now - lastParticleSpawnTime > 0.03 && dragState.velocity > 10 {
            lastParticleSpawnTime = now
            let colors: [Color] = [.zenGlow, .zenAccent, .white.opacity(0.9), .zenGlow.opacity(0.8)]
            let count = Int(max(1, min(4, dragState.velocity / 150)))
            for _ in 0..<count {
                let angle = Double.random(in: 0...2 * .pi)
                let speed = CGFloat.random(in: 30...min(250, max(60, dragState.velocity * 0.35)))
                let vel = CGVector(dx: cos(angle) * speed, dy: sin(angle) * speed)
                activeParticles.append(ParticleEffect(
                    position: value.location,
                    velocity: vel,
                    startTime: now,
                    size: CGFloat.random(in: 3...8),
                    color: colors.randomElement() ?? .zenGlow
                ))
            }
            if activeParticles.count > 60 {
                activeParticles.removeFirst(activeParticles.count - 60)
            }
        }

        // Connect to Haptics & Audio engines (Phases 2 & 3 & Spatial Audio)
        HapticEngine.shared.updateParameters(velocity: dragState.velocity, texture: texture, preferences: preferences)
        let safeSize = CGSize(width: max(1, canvasSize.width), height: max(1, canvasSize.height))
        AudioEngine.shared.updateParameters(
            velocity: dragState.velocity,
            position: dragState.currentPosition,
            screenSize: safeSize,
            texture: texture,
            preferences: preferences
        )
    }

    func onDragEnded(texture: HapticTexture, preferences: UserPreferences? = nil) {
        if let start = dragStartTime, let preferences = preferences {
            let duration = Date().timeIntervalSinceReferenceDate - start
            if duration > 5 {
                HealthKitManager.shared.saveMindfulSession(duration: duration, preferences: preferences)
            }
        }
        dragStartTime = nil
        dragState.endDrag()
        touchPoints.removeAll()
        // Connect to Haptics & Audio engines (Phases 2 & 3)
        HapticEngine.shared.stopContinuousPattern()
        AudioEngine.shared.stopContinuousClip()
        
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_300_000_000)
            if !self.dragState.isDragging {
                self.activeRipplePoints.removeAll()
                self.activeParticles.removeAll()
            }
        }
    }
}
