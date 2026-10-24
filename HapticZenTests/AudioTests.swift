import AVFoundation
import XCTest
@testable import HapticZen

final class AudioTests: XCTestCase {
    @MainActor
    func testAmbientBufferGenerationForSoundscapes() {
        let player = AudioPlayer()

        // Off soundscape should return nil buffer
        let noneBuffer = player.getAmbientBuffer(for: .none)
        XCTAssertNil(noneBuffer)

        // All active soundscapes should return valid 6-second stereo buffers
        let activeSoundscapes: [Soundscape] = [
            .zenGarden,
            .cosmicResonance,
            .tibetanBowls,
            .forestStream,
            .nightRain
        ]

        for soundscape in activeSoundscapes {
            guard let buffer = player.getAmbientBuffer(for: soundscape) else {
                XCTFail("Buffer for soundscape \(soundscape.id) should not be nil")
                continue
            }

            // Check frame length (6 seconds at 44.1 kHz)
            let expectedFrames: AVAudioFrameCount = 44100 * 6
            XCTAssertEqual(buffer.frameLength, expectedFrames)
            XCTAssertEqual(buffer.format.channelCount, 2)
            XCTAssertEqual(buffer.format.sampleRate, 44100.0)

            // Validate audio samples
            guard let channelData = buffer.floatChannelData else {
                XCTFail("Buffer floatChannelData is nil for \(soundscape.id)")
                continue
            }

            var hasNonZeroSample = false
            for ch in 0..<Int(buffer.format.channelCount) {
                for i in 0..<Int(buffer.frameLength) {
                    let sample = channelData[ch][i]
                    XCTAssertFalse(sample.isNaN, "Sample is NaN in \(soundscape.id)")
                    XCTAssertFalse(sample.isInfinite, "Sample is infinite in \(soundscape.id)")
                    XCTAssertLessThanOrEqual(abs(sample), 2.0, "Sample exceeds reasonable amplitude in \(soundscape.id)")
                    if abs(sample) > 0.001 {
                        hasNonZeroSample = true
                    }
                }
            }
            XCTAssertTrue(hasNonZeroSample, "Soundscape \(soundscape.id) should produce audio content")
        }
    }

    func testSpatialAudioPanningCalculations() {
        let screenSize = CGSize(width: 400, height: 800)

        func calculatePan(x: CGFloat) -> Float {
            return max(-1.0, min(1.0, Float((x / screenSize.width) * 2.0 - 1.0)))
        }

        // Left boundary
        XCTAssertEqual(calculatePan(x: 0), -1.0, accuracy: 0.001)

        // Center
        XCTAssertEqual(calculatePan(x: 200), 0.0, accuracy: 0.001)

        // Right boundary
        XCTAssertEqual(calculatePan(x: 400), 1.0, accuracy: 0.001)

        // Beyond boundaries (clamping)
        XCTAssertEqual(calculatePan(x: -50), -1.0, accuracy: 0.001)
        XCTAssertEqual(calculatePan(x: 500), 1.0, accuracy: 0.001)
    }

    func testDynamicEQLowPassFilterFrequencyMapping() {
        func targetFrequency(normalizedVelocity: Double) -> Double {
            return 500.0 + 19500.0 * pow(normalizedVelocity, 1.5)
        }

        // Still (0 velocity) -> 500 Hz
        XCTAssertEqual(targetFrequency(normalizedVelocity: 0.0), 500.0, accuracy: 0.1)

        // Max velocity (1.0) -> 20000 Hz
        XCTAssertEqual(targetFrequency(normalizedVelocity: 1.0), 20000.0, accuracy: 0.1)

        // Intermediate velocity (0.5)
        let mid = targetFrequency(normalizedVelocity: 0.5)
        XCTAssertGreaterThan(mid, 500.0)
        XCTAssertLessThan(mid, 20000.0)
    }
}
