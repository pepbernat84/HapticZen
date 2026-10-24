import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            Color.black.opacity(0.92)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "hand.draw.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.zenGlow)
                    .shadow(color: .zenGlow.opacity(0.5), radius: 20, x: 0, y: 0)

                VStack(spacing: 12) {
                    Text("onboarding.title")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)

                    Text("onboarding.subtitle")
                        .font(.system(size: 16, weight: .regular, design: .rounded))
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

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        appState.preferences.hasSeenOnboarding = true
                    }
                } label: {
                    Text("onboarding.button.start")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
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
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text(desc)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.zenTextSecondary)
            }
        }
    }
}
