import Foundation
import SwiftUI

/// Represents the individual stages of a guided breathing cycle.
enum BreathingPhase: String, CaseIterable {
    case inhale = "breathing.phase.inhale"
    case holdIn = "breathing.phase.hold"
    case exhale = "breathing.phase.exhale"
    case holdOut = "breathing.phase.rest"

    /// Default baseline duration (paced 4-2-6-2) for backwards compatibility.
    var duration: TimeInterval {
        switch self {
        case .inhale: return 4.0
        case .holdIn: return 2.0
        case .exhale: return 6.0
        case .holdOut: return 2.0
        }
    }
}

/// Defines guided breathing techniques with scientifically calibrated inhalation, hold, exhalation, and resting intervals.
enum BreathingPattern: String, CaseIterable, Identifiable, Codable {
    /// 4-2-6-2: Lengthened exhalation to activate parasympathetic calming and reduce anxiety.
    case paced = "paced"
    /// 4-4-4-4: Equal-duration four-stage Box Breathing popularized for focus and emotional regulation.
    case box = "box"
    /// 4-7-8-0: Dr. Andrew Weil's relaxing pranayama technique for deep sleep and stress relief.
    case relax478 = "relax478"
    /// 5-0-5-0: Resonant frequency / Heart Rate Variability (HRV) coherence (6 breaths per minute).
    case resonant = "resonant"

    var id: String { rawValue }

    var displayNameKey: LocalizedStringKey {
        switch self {
        case .paced: return "breathing.pattern.paced.title"
        case .box: return "breathing.pattern.box.title"
        case .relax478: return "breathing.pattern.relax478.title"
        case .resonant: return "breathing.pattern.resonant.title"
        }
    }

    var descriptionKey: LocalizedStringKey {
        switch self {
        case .paced: return "breathing.pattern.paced.desc"
        case .box: return "breathing.pattern.box.desc"
        case .relax478: return "breathing.pattern.relax478.desc"
        case .resonant: return "breathing.pattern.resonant.desc"
        }
    }

    var iconName: String {
        switch self {
        case .paced: return "wind"
        case .box: return "square"
        case .relax478: return "moon.stars.fill"
        case .resonant: return "waveform.path"
        }
    }

    /// Returns the duration in seconds for each phase of the breathing cycle.
    func duration(for phase: BreathingPhase) -> TimeInterval {
        switch self {
        case .paced:
            switch phase {
            case .inhale: return 4.0
            case .holdIn: return 2.0
            case .exhale: return 6.0
            case .holdOut: return 2.0
            }
        case .box:
            switch phase {
            case .inhale: return 4.0
            case .holdIn: return 4.0
            case .exhale: return 4.0
            case .holdOut: return 4.0
            }
        case .relax478:
            switch phase {
            case .inhale: return 4.0
            case .holdIn: return 7.0
            case .exhale: return 8.0
            case .holdOut: return 0.0
            }
        case .resonant:
            switch phase {
            case .inhale: return 5.0
            case .holdIn: return 0.0
            case .exhale: return 5.0
            case .holdOut: return 0.0
            }
        }
    }

    /// Total cycle duration in seconds.
    var totalCycleDuration: TimeInterval {
        BreathingPhase.allCases.reduce(0) { $0 + duration(for: $1) }
    }
}
