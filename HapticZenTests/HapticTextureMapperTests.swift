import CoreGraphics
import XCTest
@testable import HapticZen

final class HapticTextureMapperTests: XCTestCase {
    func testVelocityMappingBoundaries() {
        let texture = HapticTexture.bubbleWrap // baseIntensity: 0.8, baseSharpness: 0.9
        
        // Zero velocity -> normalizedVelocity 0 -> offset (-0.5 * 0.6 = -0.3) -> 0.5 intensity
        let zeroResult = HapticTextureMapper.map(velocity: 0, texture: texture, multiplier: 1.0)
        XCTAssertEqual(zeroResult.intensity, 0.5, accuracy: 0.01)
        XCTAssertEqual(zeroResult.sharpness, 0.65, accuracy: 0.01)

        // Max velocity (800) -> normalizedVelocity 1.0 -> offset (+0.5 * 0.6 = +0.3) -> 1.0 (clamped)
        let maxResult = HapticTextureMapper.map(velocity: 800, texture: texture, multiplier: 1.0)
        XCTAssertEqual(maxResult.intensity, 1.0, accuracy: 0.01)
        XCTAssertEqual(maxResult.sharpness, 1.0, accuracy: 0.01)
        
        // Multiplier scaling check
        let halfMultiplier = HapticTextureMapper.map(velocity: 400, texture: texture, multiplier: 0.5)
        XCTAssertGreaterThan(halfMultiplier.intensity, 0.1)
        XCTAssertLessThanOrEqual(halfMultiplier.intensity, 1.0)
    }

    func testDragStateVelocityCalculation() {
        var state = DragState()
        let t0 = TimeInterval(100.0)
        state.update(to: CGPoint(x: 0, y: 0), timestamp: t0)
        XCTAssertTrue(state.isDragging)
        XCTAssertEqual(state.velocity, 0)

        // Move 100 points in 0.1 seconds -> raw velocity 1000 pts/sec
        // Since velocity is smoothed: (0 * 0.4) + (1000 * 0.6) = 600
        state.update(to: CGPoint(x: 100, y: 0), timestamp: t0 + 0.1)
        XCTAssertEqual(state.velocity, 600, accuracy: 0.1)
        XCTAssertEqual(state.totalDistanceTraveled, 100, accuracy: 0.1)
    }

    func testDragStateEndDragResetsVelocity() {
        var state = DragState()
        state.update(to: CGPoint(x: 0, y: 0), timestamp: 100.0)
        state.update(to: CGPoint(x: 100, y: 100), timestamp: 100.1)
        XCTAssertTrue(state.isDragging)
        XCTAssertGreaterThan(state.velocity, 0)

        state.endDrag()
        XCTAssertFalse(state.isDragging)
        XCTAssertEqual(state.velocity, 0)
    }

    func testAllTexturesIntegrityAndIcons() {
        XCTAssertEqual(HapticTexture.allTextures.count, 6)
        for texture in HapticTexture.allTextures {
            XCTAssertFalse(texture.id.isEmpty)
            XCTAssertFalse(texture.ahapFilename.isEmpty)
            XCTAssertFalse(texture.audioFilename.isEmpty)
            XCTAssertFalse(texture.iconName.isEmpty)
            XCTAssertGreaterThanOrEqual(texture.baseIntensity, 0.1)
            XCTAssertLessThanOrEqual(texture.baseIntensity, 1.0)
            XCTAssertGreaterThanOrEqual(texture.baseSharpness, 0.1)
            XCTAssertLessThanOrEqual(texture.baseSharpness, 1.0)
        }
    }

    func testTextureEqualityAndHashing() {
        let t1 = HapticTexture.bubbleWrap
        let t2 = HapticTexture.bubbleWrap
        let t3 = HapticTexture.gears
        XCTAssertEqual(t1, t2)
        XCTAssertNotEqual(t1, t3)
        XCTAssertEqual(t1.hashValue, t2.hashValue)
    }

    func testTexturePackLookup() {
        let bubblePack = TexturePack.pack(for: "bubble_wrap")
        XCTAssertEqual(bubblePack?.id, TexturePack.freePack.id)

        let typewriterPack = TexturePack.pack(for: "typewriter")
        XCTAssertEqual(typewriterPack?.id, TexturePack.mechanicalPack.id)

        let rainPack = TexturePack.pack(for: "heavy_rain")
        XCTAssertEqual(rainPack?.id, TexturePack.naturePack.id)

        let invalidPack = TexturePack.pack(for: "non_existent")
        XCTAssertNil(invalidPack)
    }
}
