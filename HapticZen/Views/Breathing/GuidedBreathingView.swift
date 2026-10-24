import SwiftUI

struct GuidedBreathingView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var currentPhase: BreathingPhase = .inhale
    @State private var phaseProgress: Double = 0.0
    @State private var circleScale: CGFloat = 0.4
    @State private var isTouchingCanvas: Bool = false
    @State private var sessionStartTime: Date = Date()
    @State private var totalMindfulSeconds: TimeInterval = 0
    @State private var isSessionFinished: Bool = false

    private let hapticPlayer = BreathingHapticPlayer()

    private var activePattern: BreathingPattern {
        appState.preferences.selectedBreathingPattern
    }

    var body: some View {
        ZStack {
            Color.zenDarkBackground
                .ignoresSafeArea()

            // Soft radial ambient glow
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.zenGlow.opacity(0.35 * Double(circleScale)),
                            Color.clear
                        ]),
                        center: .center,
                        startRadius: 20,
                        endRadius: 260
                    )
                )
                .scaleEffect(circleScale * 1.4)
                .animation(.easeInOut(duration: 0.1), value: circleScale)

            VStack(spacing: 40) {
                // Top header with close button, pattern switcher & timer summary
                HStack {
                    Button {
                        finishSessionAndDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    // Quick Pattern Switcher
                    Menu {
                        ForEach(BreathingPattern.allCases) { pattern in
                            Button {
                                selectPattern(pattern)
                            } label: {
                                HStack {
                                    Text(pattern.displayNameKey)
                                    if activePattern == pattern {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: activePattern.iconName)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.zenGlow)
                            Text(activePattern.displayNameKey)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.zenCardBackground.opacity(0.9))
                        .cornerRadius(20)
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                    }

                    Spacer()

                    HStack(spacing: 6) {
                        Image(systemName: "heart.text.square.fill")
                            .foregroundColor(.zenGlow)
                        Text(formatMindfulTime(totalMindfulSeconds))
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Color.zenCardBackground.opacity(0.8))
                    .cornerRadius(20)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()

                // Meditative central circle & touch target
                ZStack {
                    // Outer ripple rings
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .stroke(Color.zenGlow.opacity(isTouchingCanvas ? 0.25 - Double(i) * 0.07 : 0.08), lineWidth: 2)
                            .frame(width: 180 + CGFloat(i * 40), height: 180 + CGFloat(i * 40))
                            .scaleEffect(circleScale * (1.0 + CGFloat(i) * 0.1))
                    }

                    // Main breathing circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.zenGlow.opacity(0.85),
                                    Color.zenGlow.opacity(0.35)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 180, height: 180)
                        .scaleEffect(circleScale)
                        .shadow(color: Color.zenGlow.opacity(0.6), radius: isTouchingCanvas ? 30 : 10)

                    // Phase text instructions inside/above circle
                    VStack(spacing: 8) {
                        Text(LocalizedStringKey(currentPhase.rawValue))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 4)

                        Text(isTouchingCanvas ? "breathing.touching" : "breathing.instruction")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .frame(width: 320, height: 320)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isTouchingCanvas && !isSessionFinished {
                                isTouchingCanvas = true
                                hapticPlayer.startBreathingSession()
                            }
                        }
                        .onEnded { _ in
                            isTouchingCanvas = false
                            hapticPlayer.stopBreathingSession()
                        }
                )

                Spacer()

                // Bottom guide text with active pattern info
                VStack(spacing: 6) {
                    Text(activePattern.descriptionKey)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.zenGlow.opacity(0.9))
                        .multilineTextAlignment(.center)

                    Text("breathing.footer")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
        }
        .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { _ in
            guard !isSessionFinished else { return }
            updateTimerAndPhase()
        }
        .onAppear {
            isSessionFinished = false
            sessionStartTime = Date()
            phaseProgress = 0
            currentPhase = .inhale
            circleScale = 0.4
            if activePattern.duration(for: .inhale) <= 0 {
                advancePhase()
            } else {
                announcePhase(.inhale)
            }
            if appState.preferences.isHealthKitTrackingEnabled && !HealthKitManager.shared.isAuthorized {
                HealthKitManager.shared.requestAuthorization { success in
                    if !success {
                        appState.preferences.isHealthKitTrackingEnabled = false
                    }
                }
            }
        }
        .onDisappear {
            finishSessionAndDismiss()
        }
    }

    private func updateTimerAndPhase() {
        totalMindfulSeconds += 0.05
        let duration = max(0.1, activePattern.duration(for: currentPhase))
        phaseProgress += 0.05 / duration

        if phaseProgress >= 1.0 {
            phaseProgress = 0.0
            advancePhase()
        }

        // Calculate smooth visual scale
        withAnimation(.linear(duration: 0.05)) {
            switch currentPhase {
            case .inhale:
                circleScale = 0.4 + CGFloat(phaseProgress) * 0.6 // 0.4 to 1.0
            case .holdIn:
                circleScale = 1.0
            case .exhale:
                circleScale = 1.0 - CGFloat(phaseProgress) * 0.6 // 1.0 to 0.4
            case .holdOut:
                circleScale = 0.4
            }
        }

        // Send continuous haptic parameter updates if finger is holding the screen
        if isTouchingCanvas {
            let isInhaling = (currentPhase == .inhale || currentPhase == .holdIn)
            hapticPlayer.updatePhase(
                progress: phaseProgress,
                isInhaling: isInhaling,
                preferences: appState.preferences
            )
        }
    }

    private func advancePhase() {
        var next = currentPhase
        repeat {
            switch next {
            case .inhale: next = .holdIn
            case .holdIn: next = .exhale
            case .exhale: next = .holdOut
            case .holdOut: next = .inhale
            }
        } while activePattern.duration(for: next) <= 0
        currentPhase = next
        announcePhase(currentPhase)
    }

    private func selectPattern(_ pattern: BreathingPattern) {
        withAnimation(.easeInOut(duration: 0.25)) {
            appState.preferences.selectedBreathingPattern = pattern
            phaseProgress = 0.0
            currentPhase = .inhale
            circleScale = 0.4
            if activePattern.duration(for: .inhale) <= 0 {
                advancePhase()
            } else {
                announcePhase(.inhale)
            }
        }
    }

    private func announcePhase(_ phase: BreathingPhase) {
        let announcement = NSLocalizedString(phase.rawValue, bundle: .main, comment: "Breathing phase")
        UIAccessibility.post(notification: .announcement, argument: announcement)
    }

    private func finishSessionAndDismiss() {
        guard !isSessionFinished else { return }
        isSessionFinished = true
        hapticPlayer.stopBreathingSession()
        if totalMindfulSeconds > 5 {
            HealthKitManager.shared.saveMindfulSession(duration: totalMindfulSeconds, preferences: appState.preferences)
            totalMindfulSeconds = 0
        }
        dismiss()
    }

    private func formatMindfulTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
