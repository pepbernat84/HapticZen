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
        let entry = currentEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MindfulWidgetEntry>) -> Void) {
        let entry = currentEntry()
        // Proactively refresh every 30 minutes, or instantly when main app posts WidgetCenter reload
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func currentEntry() -> MindfulWidgetEntry {
        let appGroupID = "group.com.hapticzen"
        let defaults = UserDefaults(suiteName: appGroupID) ?? UserDefaults.standard
        let seconds = defaults.double(forKey: "dailyMindfulSeconds")
        let goalVal = defaults.integer(forKey: "dailyGoalMinutes")
        let goal = goalVal > 0 ? goalVal : 10
        let patternKey = defaults.string(forKey: "selectedBreathingPattern") ?? "paced"

        let patternShortKey: LocalizedStringKey
        switch patternKey {
        case "box": patternShortKey = "breathing.pattern.box.short"
        case "relax478": patternShortKey = "breathing.pattern.relax478.short"
        case "resonant": patternShortKey = "breathing.pattern.resonant.short"
        default: patternShortKey = "breathing.pattern.paced.short"
        }

        return MindfulWidgetEntry(
            date: Date(),
            mindfulMinutes: seconds / 60.0,
            goalMinutes: goal,
            breathingPatternShortKey: patternShortKey,
            textureName: "Haptic Zen"
        )
    }
}
