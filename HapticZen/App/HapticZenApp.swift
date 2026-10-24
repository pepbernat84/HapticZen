import SwiftUI

@main
struct HapticZenApp: App {
    @StateObject private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ZStack {
                CanvasView()
                    .environmentObject(appState)

                if appState.preferences.hasSeenOnboarding == false {
                    OnboardingView()
                        .environmentObject(appState)
                        .transition(.opacity)
                }
            }
            .preferredColorScheme(.dark)
            .onOpenURL { url in
                appState.handleDeepLink(url)
            }
            .onChange(of: scenePhase) { newPhase in
                handleScenePhaseChange(newPhase)
            }
        }
    }

    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .active:
            HapticEngine.shared.start()
            AudioEngine.shared.start()
            AudioEngine.shared.updateSoundscape(
                soundscape: appState.preferences.selectedSoundscape,
                volume: appState.preferences.soundscapeVolume,
                preferences: appState.preferences
            )
            SharedDataManager.sync(from: appState.preferences)
        case .background, .inactive:
            HapticEngine.shared.stop()
            AudioEngine.shared.stop()
        @unknown default:
            break
        }
    }
}
