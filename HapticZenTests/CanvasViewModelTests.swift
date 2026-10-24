import CoreGraphics
import SwiftUI
import XCTest
@testable import HapticZen

final class CanvasViewModelTests: XCTestCase {
    @MainActor
    func testInitialState() {
        let viewModel = CanvasViewModel()
        XCTAssertFalse(viewModel.dragState.isDragging)
        XCTAssertEqual(viewModel.dragState.velocity, 0)
        XCTAssertTrue(viewModel.touchPoints.isEmpty)
        XCTAssertTrue(viewModel.activeRipplePoints.isEmpty)
        XCTAssertTrue(viewModel.activeParticles.isEmpty)
    }

    @MainActor
    func testOnDragEndedResetsState() {
        let viewModel = CanvasViewModel()
        viewModel.touchPoints.append(CGPoint(x: 100, y: 100))
        viewModel.dragState.update(to: CGPoint(x: 100, y: 100), timestamp: 100.0)

        viewModel.onDragEnded(texture: .bubbleWrap)

        XCTAssertFalse(viewModel.dragState.isDragging)
        XCTAssertEqual(viewModel.dragState.velocity, 0)
        XCTAssertTrue(viewModel.touchPoints.isEmpty)
    }

    @MainActor
    func testRippleAndParticleModels() {
        let now = Date().timeIntervalSinceReferenceDate
        let ripple = CanvasViewModel.RippleEffect(
            position: CGPoint(x: 50, y: 50),
            startTime: now,
            maxRadius: 80
        )
        XCTAssertEqual(ripple.position, CGPoint(x: 50, y: 50))
        XCTAssertEqual(ripple.maxRadius, 80)

        let particle = CanvasViewModel.ParticleEffect(
            position: CGPoint(x: 10, y: 20),
            velocity: CGVector(dx: 5, dy: -5),
            startTime: now,
            size: 6.0,
            color: .zenGlow
        )
        XCTAssertEqual(particle.position, CGPoint(x: 10, y: 20))
        XCTAssertEqual(particle.size, 6.0)
    }
}
