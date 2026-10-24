import XCTest
@testable import HapticZen

final class SharedDataManagerTests: XCTestCase {
    func testDailyMindfulSecondsRecording() {
        let before = SharedDataManager.getDailyMindfulSeconds()
        SharedDataManager.recordMindfulDuration(45.0)
        let after = SharedDataManager.getDailyMindfulSeconds()
        XCTAssertGreaterThanOrEqual(after, before + 44.0)
    }

    func testDailyGoalMinutesFallbackAndUpdate() {
        let defaultGoal = SharedDataManager.dailyGoalMinutes
        XCTAssertGreaterThanOrEqual(defaultGoal, 1)

        // Set custom goal
        SharedDataManager.dailyGoalMinutes = 15
        XCTAssertEqual(SharedDataManager.dailyGoalMinutes, 15)

        // Restore default goal
        SharedDataManager.dailyGoalMinutes = 10
        XCTAssertEqual(SharedDataManager.dailyGoalMinutes, 10)
    }

    func testSyncFromUserPreferences() {
        let prefs = UserPreferences()
        prefs.selectedBreathingPattern = .box
        prefs.selectedTexture = .kineticSand

        SharedDataManager.sync(from: prefs)

        XCTAssertEqual(SharedDataManager.storedBreathingPattern, "box")
        XCTAssertEqual(SharedDataManager.storedTextureID, HapticTexture.kineticSand.id)

        // Reset
        prefs.selectedBreathingPattern = .paced
        prefs.selectedTexture = .bubbleWrap
        SharedDataManager.sync(from: prefs)
    }
}
