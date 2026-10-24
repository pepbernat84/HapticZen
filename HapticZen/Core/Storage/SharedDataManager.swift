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
    }

    /// Records a completed mindful session and triggers a timeline reload on all active widgets.
    public static func recordMindfulDuration(_ seconds: TimeInterval) {
        checkAndResetDailyIfNewDay()
        let current = sharedDefaults.double(forKey: Keys.dailyMindfulSeconds)
        let updated = current + seconds
        sharedDefaults.set(updated, forKey: Keys.dailyMindfulSeconds)
        sharedDefaults.set(Date().timeIntervalSince1970, forKey: Keys.lastSavedDate)
        reloadWidgets()
    }

    /// Synchronizes current user preferences to shared storage for widgets.
    public static func sync(from preferences: UserPreferences) {
        checkAndResetDailyIfNewDay()
        sharedDefaults.set(preferences.dailyMindfulSeconds, forKey: Keys.dailyMindfulSeconds)
        sharedDefaults.set(preferences.selectedBreathingPattern.rawValue, forKey: Keys.selectedBreathingPattern)
        sharedDefaults.set(preferences.selectedTexture.id, forKey: Keys.selectedTextureID)
        sharedDefaults.set(Date().timeIntervalSince1970, forKey: Keys.lastSavedDate)
        reloadWidgets()
    }

    /// Returns the accumulated mindful seconds for today.
    public static func getDailyMindfulSeconds() -> Double {
        checkAndResetDailyIfNewDay()
        return sharedDefaults.double(forKey: Keys.dailyMindfulSeconds)
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
    private static func checkAndResetDailyIfNewDay() {
        let lastTimestamp = sharedDefaults.double(forKey: Keys.lastSavedDate)
        guard lastTimestamp > 0 else { return }
        let lastDate = Date(timeIntervalSince1970: lastTimestamp)
        if !Calendar.current.isDateInToday(lastDate) {
            sharedDefaults.set(0.0, forKey: Keys.dailyMindfulSeconds)
            sharedDefaults.set(Date().timeIntervalSince1970, forKey: Keys.lastSavedDate)
        }
    }
}
