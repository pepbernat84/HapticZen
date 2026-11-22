import SwiftUI

struct MenuOverlayView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        NavigationStack {
            ZStack {
                Color.zenDarkBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Custom Tab Bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(MenuTab.allCases, id: \.self) { tab in
                                Button {
                                    withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.8)) {
                                        appState.selectedMenuTab = tab
                                    }
                                } label: {
                                    Text(tab.rawValue)
                                        .font(.system(.subheadline, design: .rounded, weight: appState.selectedMenuTab == tab ? .bold : .medium))
                                        .foregroundColor(appState.selectedMenuTab == tab ? .white : .zenTextSecondary)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 14)
                                        .background(
                                            appState.selectedMenuTab == tab ? Color.zenGlow.opacity(0.25) : Color.clear,
                                            in: Capsule()
                                        )
                                        .overlay(
                                            Capsule()
                                                .stroke(appState.selectedMenuTab == tab ? Color.zenGlow : Color.clear, lineWidth: 1)
                                        )
                                        .accessibilityAddTraits(appState.selectedMenuTab == tab ? [.isSelected] : [])
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 12)

                    Divider()
                        .background(Color.white.opacity(0.1))

                    // Tab Content
                    Group {
                        switch appState.selectedMenuTab {
                        case .textures:
                            TexturePickerView()
                        case .breathing:
                            GuidedBreathingView(showCloseButton: false)
                        case .store:
                            StoreViewContent()
                        case .settings:
                            SettingsView()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("menu.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.zenTextSecondary)
                    }
                    .accessibilityLabel(Text("accessibility.menu.close"))
                }
            }
            .toolbarBackground(Color.zenCardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
