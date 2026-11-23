import Foundation
import SwiftUI
import WidgetKit

/// Model representing a single snapshot of the user's daily mindful progress for widgets.
struct MindfulWidgetEntry: TimelineEntry {
    let date: Date
    let mindfulMinutes: Double
    let goalMinutes: Int
    let breathingPatternShortKey: LocalizedStringKey
    let textureName: String
    var streakDays: Int = 0

    var progress: Double {
        guard goalMinutes > 0 else { return 0 }
        return min(1.0, max(0.0, mindfulMinutes / Double(goalMinutes)))
    }
}

/// Provides timeline entries by reading from the shared App Group UserDefaults container.
struct HapticZenWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> MindfulWidgetEntry {
        MindfulWidgetEntry(
            date: Date(),
            mindfulMinutes: 7.0,
            goalMinutes: 10,
            breathingPatternShortKey: "breathing.pattern.paced.short",
            textureName: "Haptic Zen"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MindfulWidgetEntry) -> Void) {
        let entry = currentEntry(for: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MindfulWidgetEntry>) -> Void) {
        let now = Date()
        let entry = currentEntry(for: now)
        // Proactively refresh every 30 minutes, or instantly when main app posts WidgetCenter reload
        let thirtyMinutesLater = Calendar.current.date(byAdding: .minute, value: 30, to: now) ?? now.addingTimeInterval(1800)

        var entries = [entry]
        // Schedule an automatic midnight entry so the widget resets to 0m at 00:00 even if the app isn't opened
        if let startOfTomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: now)) {
            entries.append(
                MindfulWidgetEntry(
                    date: startOfTomorrow,
                    mindfulMinutes: 0.0,
                    goalMinutes: entry.goalMinutes,
                    breathingPatternShortKey: entry.breathingPatternShortKey,
                    textureName: entry.textureName
                )
            )
        }

        let timeline = Timeline(entries: entries, policy: .after(thirtyMinutesLater))
        completion(timeline)
    }

    private func currentEntry(for date: Date = Date()) -> MindfulWidgetEntry {
        let appGroupID = "group.com.hapticzen"
        let defaults = UserDefaults(suiteName: appGroupID) ?? UserDefaults.standard
        let rawSeconds = defaults.double(forKey: "dailyMindfulSeconds")
        let lastTimestamp = defaults.double(forKey: "lastSavedDate")

        let seconds: Double
        if lastTimestamp > 0 {
            let lastDate = Date(timeIntervalSince1970: lastTimestamp)
            seconds = Calendar.current.isDate(lastDate, inSameDayAs: date) ? rawSeconds : 0.0
        } else {
            seconds = rawSeconds
        }

        let goalVal = defaults.integer(forKey: "dailyGoalMinutes")
        let goal = goalVal > 0 ? goalVal : 10
        let patternKey = defaults.string(forKey: "selectedBreathingPattern") ?? "paced"

        let rawStreak = defaults.integer(forKey: "currentStreakDays")
        let lastStreakTimestamp = defaults.double(forKey: "lastStreakDate")
        let streakDays: Int
        if rawStreak > 0, lastStreakTimestamp > 0 {
            let calendar = Calendar.current
            let lastStart = calendar.startOfDay(for: Date(timeIntervalSince1970: lastStreakTimestamp))
            let targetStart = calendar.startOfDay(for: date)
            let dayDiff = calendar.dateComponents([.day], from: lastStart, to: targetStart).day ?? -1
            streakDays = (dayDiff == 0 || dayDiff == 1) ? rawStreak : 0
        } else {
            streakDays = 0
        }

        let patternShortKey: LocalizedStringKey
        switch patternKey {
        case "box": patternShortKey = "breathing.pattern.box.short"
        case "relax478": patternShortKey = "breathing.pattern.relax478.short"
        case "resonant": patternShortKey = "breathing.pattern.resonant.short"
        default: patternShortKey = "breathing.pattern.paced.short"
        }

        return MindfulWidgetEntry(
            date: date,
            mindfulMinutes: seconds / 60.0,
            goalMinutes: goal,
            breathingPatternShortKey: patternShortKey,
            textureName: "Haptic Zen",
            streakDays: streakDays
        )
    }
}
