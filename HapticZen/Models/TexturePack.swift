import Foundation
import SwiftUI

/// Represents a bundle of textures available for free or via In-App Purchase.
struct TexturePack: Identifiable, Equatable {
    let id: String
    let productID: String?
    let displayNameKey: LocalizedStringKey
    let descriptionKey: LocalizedStringKey
    let textures: [HapticTexture]
    let isFree: Bool

    static let freePack = TexturePack(
        id: "free_pack",
        productID: nil,
        displayNameKey: "pack.free.title",
        descriptionKey: "pack.free.desc",
        textures: [.bubbleWrap, .kineticSand],
        isFree: true
    )

    static let mechanicalPack = TexturePack(
        id: "mechanical_pack",
        productID: "com.hapticzen.pack.mechanical",
        displayNameKey: "pack.mechanical.title",
        descriptionKey: "pack.mechanical.desc",
        textures: [.typewriter, .gears],
        isFree: false
    )

    static let naturePack = TexturePack(
        id: "nature_pack",
        productID: "com.hapticzen.pack.nature",
        displayNameKey: "pack.nature.title",
        descriptionKey: "pack.nature.desc",
        textures: [.heavyRain, .steppingSnow],
        isFree: false
    )

    static let allPacks: [TexturePack] = [
        .freePack,
        .mechanicalPack,
        .naturePack
    ]

    /// Finds the pack that contains a specific texture ID.
    static func pack(for textureID: String) -> TexturePack? {
        return allPacks.first { pack in
            pack.textures.contains { $0.id == textureID }
        }
    }
}
