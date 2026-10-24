import Foundation
import SwiftUI

/// Visual style variants associated with each haptic texture.
enum VisualStyle: String, CaseIterable, Codable {
    case shadow = "shadow"
    case ripple = "ripple"
    case particles = "particles"
}

/// Represents an individual haptic texture with associated AHAP pattern, audio, and visual style.
struct HapticTexture: Identifiable, Equatable, Hashable {
    let id: String
    let displayNameKey: LocalizedStringKey
    let descriptionKey: LocalizedStringKey
    let ahapFilename: String
    let audioFilename: String
    let defaultVisualStyle: VisualStyle
    let baseIntensity: Float
    let baseSharpness: Float
    let isContinuous: Bool

    var iconName: String {
        switch id {
        case "bubble_wrap": return "circle.grid.2x2.fill"
        case "kinetic_sand": return "wind"
        case "typewriter": return "keyboard.fill"
        case "gears": return "gearshape.2.fill"
        case "heavy_rain": return "cloud.heavyrain.fill"
        case "stepping_snow": return "snowflake"
        default: return "sparkles"
        }
    }

    // Hashable & Equatable on `id`
    static func == (lhs: HapticTexture, rhs: HapticTexture) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Built-in textures (Free & Premium)
    static let bubbleWrap = HapticTexture(
        id: "bubble_wrap",
        displayNameKey: "texture.bubbleWrap.title",
        descriptionKey: "texture.bubbleWrap.desc",
        ahapFilename: "bubble_wrap",
        audioFilename: "bubble_wrap",
        defaultVisualStyle: .ripple,
        baseIntensity: 0.8,
        baseSharpness: 0.9,
        isContinuous: false
    )

    static let kineticSand = HapticTexture(
        id: "kinetic_sand",
        displayNameKey: "texture.kineticSand.title",
        descriptionKey: "texture.kineticSand.desc",
        ahapFilename: "kinetic_sand",
        audioFilename: "kinetic_sand",
        defaultVisualStyle: .particles,
        baseIntensity: 0.4,
        baseSharpness: 0.3,
        isContinuous: true
    )

    static let typewriter = HapticTexture(
        id: "typewriter",
        displayNameKey: "texture.typewriter.title",
        descriptionKey: "texture.typewriter.desc",
        ahapFilename: "typewriter",
        audioFilename: "typewriter",
        defaultVisualStyle: .shadow,
        baseIntensity: 0.9,
        baseSharpness: 0.95,
        isContinuous: false
    )

    static let gears = HapticTexture(
        id: "gears",
        displayNameKey: "texture.gears.title",
        descriptionKey: "texture.gears.desc",
        ahapFilename: "gears",
        audioFilename: "gears",
        defaultVisualStyle: .ripple,
        baseIntensity: 0.7,
        baseSharpness: 0.8,
        isContinuous: false
    )

    static let heavyRain = HapticTexture(
        id: "heavy_rain",
        displayNameKey: "texture.heavyRain.title",
        descriptionKey: "texture.heavyRain.desc",
        ahapFilename: "heavy_rain",
        audioFilename: "heavy_rain",
        defaultVisualStyle: .particles,
        baseIntensity: 0.5,
        baseSharpness: 0.4,
        isContinuous: true
    )

    static let steppingSnow = HapticTexture(
        id: "stepping_snow",
        displayNameKey: "texture.steppingSnow.title",
        descriptionKey: "texture.steppingSnow.desc",
        ahapFilename: "stepping_snow",
        audioFilename: "stepping_snow",
        defaultVisualStyle: .shadow,
        baseIntensity: 0.6,
        baseSharpness: 0.5,
        isContinuous: true
    )

    static let allTextures: [HapticTexture] = [
        .bubbleWrap,
        .kineticSand,
        .typewriter,
        .gears,
        .heavyRain,
        .steppingSnow
    ]
}
