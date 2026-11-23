import Foundation
import WidgetKit

/// Synchronizes daily mindful progress and app preferences across the main app and Home / Lock Screen widgets via App Groups.
public struct SharedDataManager {
    public static let appGroupID = "group.com.hapticzen"
    
    public static var sharedDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? UserDefaults.standard
    }
    
    // Key identifiers
    private enum Keys {
        static let dailyMindfulSeconds = "dailyMindfulSeconds"
        static let dailyGoalMinutes = "dailyGoalMinutes"
        static let selectedBreathingPattern = "selectedBreathingPattern"
        static let selectedTextureID = "selectedTextureID"
        static let lastSavedDate = "lastSavedDate"
        static let currentStreakDays = "currentStreakDays"
        static let lastStreakDate = "lastStreakDate"
    }

    /// Records a completed mindful session and triggers a timeline reload on all active widgets.
    public static func recordMindfulDuration(_ seconds: TimeInterval, now: Date = Date()) {
        checkAndResetDailyIfNewDay(referenceDate: now)
        let current = sharedDefaults.double(forKey: Keys.dailyMindfulSeconds)
        let updated = current + seconds
        sharedDefaults.set(updated, forKey: Keys.dailyMindfulSeconds)
        sharedDefaults.set(now.timeIntervalSince1970, forKey: Keys.lastSavedDate)

        if seconds > 0 {
            updateStreak(for: now)
        }

        reloadWidgets()
    }

    private static func updateStreak(for date: Date) {
        let lastStreakTimestamp = sharedDefaults.double(forKey: Keys.lastStreakDate)
        var streak = sharedDefaults.integer(forKey: Keys.currentStreakDays)
        if lastStreakTimestamp <= 0 || streak <= 0 {
            streak = 1
        } else {
            let calendar = Calendar.current
            let lastStart = calendar.startOfDay(for: Date(timeIntervalSince1970: lastStreakTimestamp))
            let nowStart = calendar.startOfDay(for: date)
            let dayDiff = calendar.dateComponents([.day], from: lastStart, to: nowStart).day ?? 0
            if dayDiff == 0 {
                streak = max(1, streak)
            } else if dayDiff == 1 {
                streak += 1
            } else {
                streak = 1
            }
        }
        sharedDefaults.set(streak, forKey: Keys.currentStreakDays)
        sharedDefaults.set(date.timeIntervalSince1970, forKey: Keys.lastStreakDate)
    }

    /// Synchronizes current user preferences to shared storage for widgets.
    static func sync(from preferences: UserPreferences, now: Date = Date()) {
        let didReset = checkAndResetDailyIfNewDay(referenceDate: now)
        if didReset {
            preferences.dailyMindfulSeconds = 0.0
        }
        let syncedSeconds = max(sharedDefaults.double(forKey: Keys.dailyMindfulSeconds), preferences.dailyMindfulSeconds)
        sharedDefaults.set(syncedSeconds, forKey: Keys.dailyMindfulSeconds)
        preferences.dailyMindfulSeconds = syncedSeconds
        sharedDefaults.set(max(1, preferences.dailyGoalMinutes), forKey: Keys.dailyGoalMinutes)
        sharedDefaults.set(preferences.selectedBreathingPattern.rawValue, forKey: Keys.selectedBreathingPattern)
        sharedDefaults.set(preferences.selectedTexture.id, forKey: Keys.selectedTextureID)
        sharedDefaults.set(now.timeIntervalSince1970, forKey: Keys.lastSavedDate)
        reloadWidgets()
    }

    /// Returns the accumulated mindful seconds for today.
    public static func getDailyMindfulSeconds(for date: Date = Date()) -> Double {
        checkAndResetDailyIfNewDay(referenceDate: date)
        return sharedDefaults.double(forKey: Keys.dailyMindfulSeconds)
    }

    /// Returns the active consecutive-day streak for the given calendar day.
    public static func getCurrentStreakDays(for date: Date = Date()) -> Int {
        let streak = sharedDefaults.integer(forKey: Keys.currentStreakDays)
        let lastStreakTimestamp = sharedDefaults.double(forKey: Keys.lastStreakDate)
        guard streak > 0, lastStreakTimestamp > 0 else { return 0 }
        let calendar = Calendar.current
        let lastStart = calendar.startOfDay(for: Date(timeIntervalSince1970: lastStreakTimestamp))
        let targetStart = calendar.startOfDay(for: date)
        let dayDiff = calendar.dateComponents([.day], from: lastStart, to: targetStart).day ?? -1
        return (dayDiff == 0 || dayDiff == 1) ? streak : 0
    }

    /// Returns the daily goal in minutes (default: 10 minutes).
    public static var dailyGoalMinutes: Int {
        get {
            let val = sharedDefaults.integer(forKey: Keys.dailyGoalMinutes)
            return val > 0 ? val : 10
        }
        set {
            sharedDefaults.set(newValue, forKey: Keys.dailyGoalMinutes)
            reloadWidgets()
        }
    }

    /// Returns the stored breathing pattern identifier.
    public static var storedBreathingPattern: String {
        sharedDefaults.string(forKey: Keys.selectedBreathingPattern) ?? "paced"
    }

    /// Returns the stored active texture identifier.
    public static var storedTextureID: String {
        sharedDefaults.string(forKey: Keys.selectedTextureID) ?? "bubble_wrap"
    }

    /// Request WidgetKit to refresh all Home and Lock screen widgets.
    public static func reloadWidgets() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }

    /// Resets mindful seconds at the start of a new calendar day.
    @discardableResult
    private static func checkAndResetDailyIfNewDay(referenceDate: Date = Date()) -> Bool {
        let lastTimestamp = sharedDefaults.double(forKey: Keys.lastSavedDate)
        guard lastTimestamp > 0 else { return false }
        let lastDate = Date(timeIntervalSince1970: lastTimestamp)
        if !Calendar.current.isDate(lastDate, inSameDayAs: referenceDate) {
            sharedDefaults.set(0.0, forKey: Keys.dailyMindfulSeconds)
            sharedDefaults.set(referenceDate.timeIntervalSince1970, forKey: Keys.lastSavedDate)
            return true
        }
        return false
    }
}
