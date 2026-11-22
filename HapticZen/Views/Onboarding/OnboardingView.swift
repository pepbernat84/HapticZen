import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @ScaledMetric(relativeTo: .largeTitle) private var heroIconSize: CGFloat = 64

    var body: some View {
        ZStack {
            Color.black.opacity(0.92)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        Image(systemName: "hand.draw.fill")
                            .font(.system(size: min(heroIconSize, 88)))
                            .foregroundColor(.zenGlow)
                            .shadow(color: .zenGlow.opacity(0.5), radius: 20, x: 0, y: 0)
                            .padding(.top, 36)

                        VStack(spacing: 12) {
                            Text("onboarding.title")
                                .font(.system(.title, design: .rounded, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)

                            Text("onboarding.subtitle")
                                .font(.system(.callout, design: .rounded, weight: .regular))
                                .foregroundColor(.zenTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }

                        // Instructions Card
                        VStack(alignment: .leading, spacing: 20) {
                            instructionRow(
                                icon: "hand.point.up.left.fill",
                                title: "onboarding.drag.title",
                                desc: "onboarding.drag.desc"
                            )

                            instructionRow(
                                icon: "hand.tap.fill",
                                title: "onboarding.menu.title",
                                desc: "onboarding.menu.desc"
                            )

                            instructionRow(
                                icon: "arrow.right.to.line",
                                title: "onboarding.swipe.title",
                                desc: "onboarding.swipe.desc"
                            )
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color.zenCardBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 16)
                }

                Button {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8)) {
                        appState.preferences.hasSeenOnboarding = true
                    }
                } label: {
                    Text("onboarding.button.start")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.zenGlow, in: Capsule())
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
            }
        }
    }

    @ViewBuilder
    private func instructionRow(icon: String, title: LocalizedStringKey, desc: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.zenGlow)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.callout, design: .rounded, weight: .bold))
                    .foregroundColor(.white)

                Text(desc)
                    .font(.system(.footnote, design: .rounded, weight: .regular))
                    .foregroundColor(.zenTextSecondary)
            }
        }
    }
}
