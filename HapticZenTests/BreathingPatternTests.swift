import XCTest
@testable import HapticZen

final class BreathingPatternTests: XCTestCase {
    func testBreathingPhaseDurations() {
        XCTAssertEqual(BreathingPhase.inhale.duration, 4.0)
        XCTAssertEqual(BreathingPhase.holdIn.duration, 2.0)
        XCTAssertEqual(BreathingPhase.exhale.duration, 6.0)
        XCTAssertEqual(BreathingPhase.holdOut.duration, 2.0)

        let totalCycle = BreathingPhase.allCases.reduce(0) { $0 + $1.duration }
        XCTAssertEqual(totalCycle, 14.0)
    }

    func testBreathingPhaseCycleProgression() {
        var phase: BreathingPhase = .inhale
        func advance(from p: BreathingPhase) -> BreathingPhase {
            switch p {
            case .inhale: return .holdIn
            case .holdIn: return .exhale
            case .exhale: return .holdOut
            case .holdOut: return .inhale
            }
        }

        phase = advance(from: phase)
        XCTAssertEqual(phase, .holdIn)
        phase = advance(from: phase)
        XCTAssertEqual(phase, .exhale)
        phase = advance(from: phase)
        XCTAssertEqual(phase, .holdOut)
        phase = advance(from: phase)
        XCTAssertEqual(phase, .inhale)
    }

    func testBreathingPatternsDurationsAndCycles() {
        // Paced (4-2-6-2)
        let paced = BreathingPattern.paced
        XCTAssertEqual(paced.duration(for: .inhale), 4.0)
        XCTAssertEqual(paced.duration(for: .holdIn), 2.0)
        XCTAssertEqual(paced.duration(for: .exhale), 6.0)
        XCTAssertEqual(paced.duration(for: .holdOut), 2.0)
        XCTAssertEqual(paced.totalCycleDuration, 14.0)

        // Box (4-4-4-4)
        let box = BreathingPattern.box
        XCTAssertEqual(box.duration(for: .inhale), 4.0)
        XCTAssertEqual(box.duration(for: .holdIn), 4.0)
        XCTAssertEqual(box.duration(for: .exhale), 4.0)
        XCTAssertEqual(box.duration(for: .holdOut), 4.0)
        XCTAssertEqual(box.totalCycleDuration, 16.0)

        // Relax 4-7-8
        let relax478 = BreathingPattern.relax478
        XCTAssertEqual(relax478.duration(for: .inhale), 4.0)
        XCTAssertEqual(relax478.duration(for: .holdIn), 7.0)
        XCTAssertEqual(relax478.duration(for: .exhale), 8.0)
        XCTAssertEqual(relax478.duration(for: .holdOut), 0.0)
        XCTAssertEqual(relax478.totalCycleDuration, 19.0)

        // Resonant Coherence (5-0-5-0)
        let resonant = BreathingPattern.resonant
        XCTAssertEqual(resonant.duration(for: .inhale), 5.0)
        XCTAssertEqual(resonant.duration(for: .holdIn), 0.0)
        XCTAssertEqual(resonant.duration(for: .exhale), 5.0)
        XCTAssertEqual(resonant.duration(for: .holdOut), 0.0)
        XCTAssertEqual(resonant.totalCycleDuration, 10.0)
    }

    func testAllBreathingPatternsProperties() {
        for pattern in BreathingPattern.allCases {
            XCTAssertFalse(pattern.id.isEmpty)
            XCTAssertFalse(pattern.iconName.isEmpty)
            XCTAssertGreaterThan(pattern.totalCycleDuration, 0)
        }
    }
}
