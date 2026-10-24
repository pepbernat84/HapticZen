import Foundation
import SwiftUI

/// Represents a continuous background meditative soundscape layer.
struct Soundscape: Identifiable, Equatable, Hashable, CaseIterable {
    let id: String
    let displayNameKey: LocalizedStringKey
    let descriptionKey: LocalizedStringKey
    let iconName: String

    var titleKey: LocalizedStringKey { displayNameKey }

    static func == (lhs: Soundscape, rhs: Soundscape) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static let none = Soundscape(
        id: "none",
        displayNameKey: "settings.soundscape.off",
        descriptionKey: "",
        iconName: "speaker.slash"
    )

    static let zenGarden = Soundscape(
        id: "zenGarden",
        displayNameKey: "soundscape.zenGarden.title",
        descriptionKey: "soundscape.zenGarden.desc",
        iconName: "leaf.fill"
    )

    static let cosmicResonance = Soundscape(
        id: "cosmicResonance",
        displayNameKey: "soundscape.cosmicResonance.title",
        descriptionKey: "soundscape.cosmicResonance.desc",
        iconName: "sparkles"
    )

    static let tibetanBowls = Soundscape(
        id: "tibetan_bowl",
        displayNameKey: "soundscape.tibetanBowls.title",
        descriptionKey: "soundscape.tibetanBowls.desc",
        iconName: "bell.and.waves.left.and.right.fill"
    )

    static let forestStream = Soundscape(
        id: "rain_forest",
        displayNameKey: "soundscape.forestStream.title",
        descriptionKey: "soundscape.forestStream.desc",
        iconName: "tree.fill"
    )

    static let nightRain = Soundscape(
        id: "ocean_drift",
        displayNameKey: "soundscape.nightRain.title",
        descriptionKey: "soundscape.nightRain.desc",
        iconName: "cloud.rain.fill"
    )

    static let allSoundscapes: [Soundscape] = [
        .none,
        .zenGarden,
        .cosmicResonance,
        .tibetanBowls,
        .forestStream,
        .nightRain
    ]

    static var allCases: [Soundscape] {
        allSoundscapes
    }
}
