import XCTest
@testable import HapticZen

final class SharedDataManagerTests: XCTestCase {
    private let sharedKeys = [
        "dailyMindfulSeconds",
        "dailyGoalMinutes",
        "lastSavedDate",
        "selectedBreathingPattern",
        "selectedTextureID",
        "currentStreakDays",
        "lastStreakDate"
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
        UserDefaults.standard.removeObject(forKey: "dailyGoalMinutes")
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
        prefs.dailyGoalMinutes = 20

        SharedDataManager.sync(from: prefs)

        XCTAssertEqual(SharedDataManager.storedBreathingPattern, "box")
        XCTAssertEqual(SharedDataManager.storedTextureID, HapticTexture.kineticSand.id)
        XCTAssertEqual(SharedDataManager.dailyGoalMinutes, 20)

        // Reset
        prefs.selectedBreathingPattern = .paced
        prefs.selectedTexture = .bubbleWrap
        prefs.dailyGoalMinutes = 10
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

    func testDailyStreakIncrementsOnConsecutiveDaysAndResetsAfterGap() throws {
        let day1 = Date(timeIntervalSince1970: 1_763_800_000)
        let day2 = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: 1, to: day1))
        let day3 = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: 2, to: day1))
        let day5 = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: 4, to: day1))

        XCTAssertEqual(SharedDataManager.getCurrentStreakDays(for: day1), 0)

        SharedDataManager.recordMindfulDuration(60.0, now: day1)
        XCTAssertEqual(SharedDataManager.getCurrentStreakDays(for: day1), 1)

        // Recording again on the same day keeps streak at 1
        SharedDataManager.recordMindfulDuration(30.0, now: day1)
        XCTAssertEqual(SharedDataManager.getCurrentStreakDays(for: day1), 1)

        // Consecutive days increment streak
        SharedDataManager.recordMindfulDuration(45.0, now: day2)
        XCTAssertEqual(SharedDataManager.getCurrentStreakDays(for: day2), 2)

        SharedDataManager.recordMindfulDuration(45.0, now: day3)
        XCTAssertEqual(SharedDataManager.getCurrentStreakDays(for: day3), 3)

        // Missing a full calendar day resets active streak to 0 until a new session starts it at 1
        XCTAssertEqual(SharedDataManager.getCurrentStreakDays(for: day5), 0)
        SharedDataManager.recordMindfulDuration(45.0, now: day5)
        XCTAssertEqual(SharedDataManager.getCurrentStreakDays(for: day5), 1)
    }
}
