import SwiftUI
import WidgetKit

struct HapticZenWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: MindfulWidgetEntry

    // Harmonized Zen palette matching Color+Theme.swift
    private let zenGlow = Color(red: 0.35, green: 0.65, blue: 0.95)
    private let zenAccent = Color(red: 0.25, green: 0.50, blue: 0.85)
    private let zenDark = Color(red: 0.04, green: 0.05, blue: 0.08)
    private let zenCard = Color(red: 0.10, green: 0.12, blue: 0.18)

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidgetView
                .widgetURL(URL(string: "hapticzen://breathing"))
                .zenWidgetBackground(zenDark)
        case .systemMedium:
            mediumWidgetView
                .zenWidgetBackground(zenDark)
        case .accessoryCircular:
            accessoryCircularView
                .zenWidgetBackground(Color.clear)
        case .accessoryRectangular:
            accessoryRectangularView
                .zenWidgetBackground(Color.clear)
        case .accessoryInline:
            accessoryInlineView
                .zenWidgetBackground(Color.clear)
        default:
            smallWidgetView
                .widgetURL(URL(string: "hapticzen://breathing"))
                .zenWidgetBackground(zenDark)
        }
    }

    // MARK: - System Small
    private var smallWidgetView: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(zenGlow.opacity(0.20), lineWidth: 6)

                Circle()
                    .trim(from: 0, to: CGFloat(entry.progress))
                    .stroke(
                        LinearGradient(colors: [zenGlow, zenAccent], startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Image(systemName: "wind")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(zenGlow)

                    Text("\(Int(entry.mindfulMinutes))m")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .frame(width: 72, height: 72)
            .padding(.top, 4)

            VStack(spacing: 2) {
                Text("widget.calmToday")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                Text("\(Int(entry.progress * 100))% • \(entry.goalMinutes)m")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(zenGlow)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - System Medium
    private var mediumWidgetView: some View {
        HStack(spacing: 16) {
            // Left Column: Progress Ring
            ZStack {
                Circle()
                    .stroke(zenGlow.opacity(0.20), lineWidth: 7)

                Circle()
                    .trim(from: 0, to: CGFloat(entry.progress))
                    .stroke(
                        LinearGradient(colors: [zenGlow, zenAccent], startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 7, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(Int(entry.mindfulMinutes))")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)

                    Text("widget.minutesUnit")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundColor(zenGlow)
                }
            }
            .frame(width: 90, height: 90)

            // Right Column: Details & Deep Links
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Circle()
                        .fill(zenGlow)
                        .frame(width: 6, height: 6)

                    Text("Haptic Zen")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Spacer()

                    Text("\(Int(entry.progress * 100))%")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(zenGlow)
                }

                // Active Pattern Pill
                HStack(spacing: 5) {
                    Image(systemName: "lungs.fill")
                        .font(.system(size: 10))
                        .foregroundColor(zenGlow)

                    Text(entry.breathingPatternShortKey)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(zenCard)
                .cornerRadius(8)

                Spacer(minLength: 0)

                // Quick Actions
                HStack(spacing: 8) {
                    Link(destination: URL(string: "hapticzen://breathing")!) {
                        HStack(spacing: 4) {
                            Image(systemName: "wind")
                                .font(.system(size: 11, weight: .bold))
                            Text("widget.breatheAction")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(zenGlow, in: Capsule())
                    }

                    Link(destination: URL(string: "hapticzen://canvas")!) {
                        HStack(spacing: 4) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 11))
                            Text("widget.canvasAction")
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(zenCard, in: Capsule())
                        .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Lock Screen Circular
    private var accessoryCircularView: some View {
        Gauge(value: entry.progress) {
            Image(systemName: "wind")
        } currentValueLabel: {
            Text("\(Int(entry.mindfulMinutes))m")
                .font(.system(size: 12, weight: .bold, design: .rounded))
        }
        .gaugeStyle(.accessoryCircular)
    }

    // MARK: - Lock Screen Rectangular
    private var accessoryRectangularView: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Image(systemName: "wind")
                Text("Haptic Zen • \(Int(entry.mindfulMinutes))/\(entry.goalMinutes)m")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
            }

            ProgressView(value: entry.progress)
                .tint(zenGlow)

            Text(entry.breathingPatternShortKey)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Lock Screen Inline
    private var accessoryInlineView: some View {
        Label("\(Int(entry.mindfulMinutes))m • Haptic Zen", systemImage: "wind")
    }
}

private extension View {
    @ViewBuilder
    func zenWidgetBackground(_ color: Color) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            self.containerBackground(for: .widget) {
                color
            }
        } else {
            self.background(color)
        }
    }
}

struct HapticZenWidget: Widget {
    let kind: String = "HapticZenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HapticZenWidgetProvider()) { entry in
            HapticZenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Haptic Zen")
        .description("widget.description")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}
