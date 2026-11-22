import XCTest
@testable import HapticZen

final class SharedDataManagerTests: XCTestCase {
    private let sharedKeys = [
        "dailyMindfulSeconds",
        "dailyGoalMinutes",
        "lastSavedDate",
        "selectedBreathingPattern",
        "selectedTextureID"
    ]

    override func setUp() {
        super.setUp()
        clearDefaults()
    }

    override func tearDown() {
        clearDefaults()
        super.tearDown()
    }

    private func clearDefaults() {
        let shared = SharedDataManager.sharedDefaults
        for key in sharedKeys {
            shared.removeObject(forKey: key)
        }
        UserDefaults.standard.removeObject(forKey: "dailyMindfulSeconds")
        UserDefaults.standard.removeObject(forKey: "selectedBreathingPattern")
        UserDefaults.standard.removeObject(forKey: "selectedTextureID")
    }

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

    func testDailyMindfulSecondsResetsOnNewCalendarDay() throws {
        let today = Date()
        let yesterday = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -1, to: today))

        SharedDataManager.recordMindfulDuration(120.0, now: yesterday)
        XCTAssertEqual(SharedDataManager.getDailyMindfulSeconds(for: yesterday), 120.0, accuracy: 0.01)

        // Reading on a subsequent calendar day must reset the counter to 0
        XCTAssertEqual(SharedDataManager.getDailyMindfulSeconds(for: today), 0.0, accuracy: 0.01)
    }

    func testSyncDoesNotResurrectYesterdaysMindfulSeconds() throws {
        let today = Date()
        let yesterday = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -1, to: today))

        SharedDataManager.recordMindfulDuration(180.0, now: yesterday)
        let prefs = UserPreferences()
        prefs.dailyMindfulSeconds = 180.0

        SharedDataManager.sync(from: prefs, now: today)

        XCTAssertEqual(SharedDataManager.getDailyMindfulSeconds(for: today), 0.0, accuracy: 0.01)
        XCTAssertEqual(prefs.dailyMindfulSeconds, 0.0, accuracy: 0.01)
    }
}
