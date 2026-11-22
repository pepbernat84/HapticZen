import SwiftUI

struct GuidedBreathingView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var showCloseButton: Bool = true

    @State private var currentPhase: BreathingPhase = .inhale
    @State private var circleScale: CGFloat = 0.4
    @State private var isTouchingCanvas: Bool = false
    @State private var sessionStartTime: Date = Date()
    @State private var phaseStartTime: Date = Date()
    @State private var displayedMindfulSeconds: Int = 0
    @State private var isSessionFinished: Bool = false

    private let hapticPlayer = BreathingHapticPlayer()

    private var activePattern: BreathingPattern {
        appState.preferences.selectedBreathingPattern
    }

    private var reduceMotionOpacity: Double {
        guard reduceMotion else { return 1.0 }
        return (currentPhase == .inhale || currentPhase == .holdIn) ? 0.95 : 0.45
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

            VStack(spacing: 40) {
                // Top header with optional close button, pattern switcher & timer summary
                HStack {
                    if showCloseButton {
                        Button {
                            finishSessionAndDismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .accessibilityLabel(Text("accessibility.menu.close"))

                        Spacer()
                    }

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
                                .font(.system(.footnote, weight: .semibold))
                                .foregroundColor(.zenGlow)
                            Text(activePattern.displayNameKey)
                                .font(.system(.footnote, design: .rounded, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(.caption2, weight: .bold))
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
                        Text(formatMindfulTime(TimeInterval(displayedMindfulSeconds)))
                            .font(.system(.callout, design: .monospaced, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
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
                        .opacity(reduceMotion ? reduceMotionOpacity : 1.0)
                        .animation(reduceMotion ? .easeInOut(duration: 0.35) : nil, value: currentPhase)
                        .shadow(color: Color.zenGlow.opacity(0.6), radius: isTouchingCanvas ? 30 : 10)

                    // Phase text instructions inside/above circle
                    VStack(spacing: 8) {
                        Text(LocalizedStringKey(currentPhase.rawValue))
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.75)
                            .shadow(radius: 4)

                        Text(isTouchingCanvas ? "breathing.touching" : "breathing.instruction")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .minimumScaleFactor(0.8)
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
                        .font(.system(.footnote, design: .rounded, weight: .medium))
                        .foregroundColor(.zenGlow.opacity(0.9))
                        .multilineTextAlignment(.center)

                    Text("breathing.footer")
                        .font(.system(.caption, design: .rounded, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
        }
        .task {
            while !Task.isCancelled && !isSessionFinished {
                try? await Task.sleep(for: .milliseconds(100), tolerance: .milliseconds(20))
                guard !Task.isCancelled && !isSessionFinished else { break }
                updateTimerAndPhase()
            }
        }
        .onAppear {
            isSessionFinished = false
            let now = Date()
            sessionStartTime = now
            phaseStartTime = now
            displayedMindfulSeconds = 0
            circleScale = reduceMotion ? 0.75 : 0.4
            startPhase(firstActivePhase(for: activePattern))
            if appState.preferences.isHealthKitTrackingEnabled && !HealthKitManager.shared.isAuthorized {
                HealthKitManager.shared.requestAuthorization { success in
                    if !success {
                        appState.preferences.isHealthKitTrackingEnabled = false
                    }
                }
            }
        }
        .onChange(of: reduceMotion) { isReduced in
            if isReduced {
                circleScale = 0.75
            }
        }
        .onDisappear {
            finishSessionAndDismiss()
        }
    }

    private func firstActivePhase(for pattern: BreathingPattern) -> BreathingPhase {
        if pattern.duration(for: .inhale) > 0 {
            return .inhale
        }
        return BreathingPhase.allCases.first { pattern.duration(for: $0) > 0 } ?? .inhale
    }

    private func startPhase(_ phase: BreathingPhase) {
        currentPhase = phase
        phaseStartTime = Date()
        announcePhase(phase)

        if reduceMotion {
            withAnimation(.easeInOut(duration: 0.35)) {
                circleScale = 0.75
            }
        } else {
            let phaseDuration = activePattern.duration(for: phase)
            let targetScale: CGFloat = (phase == .inhale || phase == .holdIn) ? 1.0 : 0.4
            withAnimation(.easeInOut(duration: max(0.05, phaseDuration))) {
                circleScale = targetScale
            }
        }
    }

    private func updateTimerAndPhase() {
        let now = Date()
        let elapsedWholeSeconds = Int(now.timeIntervalSince(sessionStartTime))
        if elapsedWholeSeconds != displayedMindfulSeconds {
            displayedMindfulSeconds = elapsedWholeSeconds
        }

        let duration = max(0.1, activePattern.duration(for: currentPhase))
        let phaseElapsed = now.timeIntervalSince(phaseStartTime)
        if phaseElapsed >= duration {
            advancePhase()
        }

        // Send continuous haptic parameter updates if finger is holding the screen
        if isTouchingCanvas {
            let activeDuration = max(0.1, activePattern.duration(for: currentPhase))
            let progress = min(1.0, max(0.0, now.timeIntervalSince(phaseStartTime) / activeDuration))
            switch currentPhase {
            case .inhale:
                hapticPlayer.updatePhase(progress: progress, isInhaling: true, preferences: appState.preferences)
            case .holdIn:
                hapticPlayer.updatePhase(progress: 1.0, isInhaling: true, preferences: appState.preferences)
            case .exhale:
                hapticPlayer.updatePhase(progress: progress, isInhaling: false, preferences: appState.preferences)
            case .holdOut:
                hapticPlayer.updatePhase(progress: 1.0, isInhaling: false, preferences: appState.preferences)
            }
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
        startPhase(next)
    }

    private func selectPattern(_ pattern: BreathingPattern) {
        appState.preferences.selectedBreathingPattern = pattern
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            circleScale = reduceMotion ? 0.75 : 0.4
        }
        Task { @MainActor in
            guard !isSessionFinished else { return }
            startPhase(firstActivePhase(for: pattern))
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
        let sessionDuration = Date().timeIntervalSince(sessionStartTime)
        if sessionDuration > 5 {
            HealthKitManager.shared.saveMindfulSession(duration: sessionDuration, preferences: appState.preferences)
        }
        dismiss()
    }

    private func formatMindfulTime(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
