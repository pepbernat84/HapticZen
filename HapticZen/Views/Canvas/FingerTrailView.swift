import SwiftUI

/// Renders the dynamic visual feedback following the user's finger across the canvas.
struct FingerTrailView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let dragState: DragState
    let style: VisualStyle
    let touchPoints: [CGPoint]
    let ripples: [CanvasViewModel.RippleEffect]
    let particles: [CanvasViewModel.ParticleEffect]

    var body: some View {
        ZStack {
            switch style {
            case .shadow:
                shadowEffect
            case .ripple:
                rippleEffect
            case .particles:
                particleEffect
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Shadow Mode
    private var shadowEffect: some View {
        Group {
            if dragState.isDragging {
                let intensity = min(1.0, max(0.2, dragState.velocity / 800.0))
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.zenGlow.opacity(intensity * 0.6),
                        Color.zenAccent.opacity(intensity * 0.3),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 5,
                    endRadius: 100 + CGFloat(intensity * 60)
                )
                .frame(width: 350, height: 350)
                .position(dragState.currentPosition)
                .animation(reduceMotion ? nil : .interactiveSpring(), value: dragState.currentPosition)
            }
        }
    }

    // MARK: - Ripple Mode
    private var rippleEffect: some View {
        Group {
            if ripples.isEmpty {
                EmptyView()
            } else {
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        let now = timeline.date.timeIntervalSinceReferenceDate
                        for ripple in ripples {
                            let elapsed = now - ripple.startTime
                            let duration: TimeInterval = 0.85
                            if elapsed < duration && elapsed >= 0 {
                                let progress = elapsed / duration
                                let currentRadius = reduceMotion ? ripple.maxRadius * 0.6 : ripple.maxRadius * CGFloat(progress)
                                let opacity = (1.0 - progress) * 0.8
                                
                                let rect = CGRect(
                                    x: ripple.position.x - currentRadius,
                                    y: ripple.position.y - currentRadius,
                                    width: currentRadius * 2,
                                    height: currentRadius * 2
                                )
                                
                                var path = Path()
                                path.addEllipse(in: rect)
                                
                                context.stroke(
                                    path,
                                    with: .color(Color.zenGlow.opacity(opacity)),
                                    lineWidth: max(1.0, 3.5 * CGFloat(1.0 - progress))
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Particle Mode
    private var particleEffect: some View {
        Group {
            if !dragState.isDragging && touchPoints.isEmpty && particles.isEmpty {
                EmptyView()
            } else {
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        let now = timeline.date.timeIntervalSinceReferenceDate
                        
                        // 1. Draw glowing finger trail points
                        if dragState.isDragging {
                            for (index, point) in touchPoints.enumerated() {
                                let progress = CGFloat(index) / CGFloat(max(1, touchPoints.count))
                                let radius: CGFloat = 2.5 + progress * 5.0
                                let rect = CGRect(
                                    x: point.x - radius,
                                    y: point.y - radius,
                                    width: radius * 2,
                                    height: radius * 2
                                )
                                var path = Path()
                                path.addEllipse(in: rect)
                                context.fill(path, with: .color(Color.zenAccent.opacity(progress * 0.6)))
                            }
                        }
                        
                        // 2. Draw radiating physics particles
                        for particle in particles {
                            let elapsed = now - particle.startTime
                            let duration: TimeInterval = 1.2
                            if elapsed < duration && elapsed >= 0 {
                                let progress = elapsed / duration
                                let currentX = reduceMotion ? particle.position.x : particle.position.x + particle.velocity.dx * CGFloat(elapsed)
                                let currentY = reduceMotion ? particle.position.y : particle.position.y + particle.velocity.dy * CGFloat(elapsed)
                                let currentSize = max(1.0, particle.size * CGFloat(1.0 - progress * 0.6))
                                let opacity = (1.0 - progress) * 0.9
                                
                                let rect = CGRect(
                                    x: currentX - currentSize,
                                    y: currentY - currentSize,
                                    width: currentSize * 2,
                                    height: currentSize * 2
                                )
                                
                                var path = Path()
                                path.addEllipse(in: rect)
                                context.fill(path, with: .color(particle.color.opacity(opacity)))
                            }
                        }
                    }
                }
            }
        }
    }
}
