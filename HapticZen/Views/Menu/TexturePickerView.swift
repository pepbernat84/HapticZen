import SwiftUI

struct TexturePickerView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(TexturePack.allPacks) { pack in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(pack.displayNameKey)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            if !pack.isFree && !appState.unlockedPackIDs.contains(pack.id) {
                                Image(systemName: "lock.fill")
                                    .font(.subheadline)
                                    .foregroundColor(.zenGlow)
                            }
                        }

                        Text(pack.descriptionKey)
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(.zenTextSecondary)

                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(pack.textures) { texture in
                                textureCard(for: texture, in: pack)
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    @ViewBuilder
    private func textureCard(for texture: HapticTexture, in pack: TexturePack) -> some View {
        let isSelected = appState.preferences.selectedTextureID == texture.id
        let isUnlocked = appState.isUnlocked(texture: texture)

        Button {
            if isUnlocked {
                appState.selectTexture(texture)
                dismiss()
            } else {
                appState.isStorePresented = true
            }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: texture.iconName)
                        .font(.title2)
                        .foregroundColor(isSelected ? .zenGlow : .white)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.zenGlow)
                    } else if !isUnlocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.zenTextSecondary)
                    }
                }

                Text(texture.displayNameKey)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(texture.descriptionKey)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.zenTextSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? Color.zenGlow.opacity(0.18) : Color.zenCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.zenGlow : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}
