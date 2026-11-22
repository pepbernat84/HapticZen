import CoreHaptics
import Foundation
import UIKit

/// Singleton managing the lifecycle of the CHHapticEngine.
@MainActor
class HapticEngine {
    static let shared = HapticEngine()

    private(set) var engine: CHHapticEngine?
    private var supportsHaptics: Bool = false
    private let player = HapticPlayer()
    private var isEngineStarted: Bool = false
    private var observers: [AnyObject] = []

    private init() {
        checkHardwareCapabilities()
        setupNotificationObservers()
    }

    deinit {
        for obs in observers {
            NotificationCenter.default.removeObserver(obs)
        }
        observers.removeAll()
    }

    private func checkHardwareCapabilities() {
        supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    private func setupNotificationObservers() {
        let obs1 = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.stop()
            }
        }
        observers.append(obs1)

        let obs2 = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.start()
            }
        }
        observers.append(obs2)
    }

    private func setupEngineHandlers(for newEngine: CHHapticEngine) {
        newEngine.playsHapticsOnly = true
        newEngine.isAutoShutdownEnabled = false

        newEngine.stoppedHandler = { [weak self] reason in
            print("CHHapticEngine stopped: \(reason)")
            Task { @MainActor in
                self?.isEngineStarted = false
            }
        }

        newEngine.resetHandler = { [weak self] in
            print("CHHapticEngine reset. Restarting...")
            Task { @MainActor in
                self?.player.invalidatePlayers()
                do {
                    try self?.engine?.start()
                    self?.isEngineStarted = true
                } catch {
                    print("Failed to restart CHHapticEngine after reset: \(error)")
                    self?.engine = nil
                    self?.isEngineStarted = false
                    self?.start()
                }
            }
        }
    }

    func start() {
        guard supportsHaptics else { return }
        if engine == nil {
            player.invalidatePlayers()
            do {
                let newEngine = try CHHapticEngine()
                setupEngineHandlers(for: newEngine)
                engine = newEngine
            } catch {
                print("Failed to create CHHapticEngine: \(error)")
                return
            }
        }

        if !isEngineStarted {
            do {
                try engine?.start()
                isEngineStarted = true
            } catch {
                print("Failed to start CHHapticEngine: \(error)")
                engine = nil
                isEngineStarted = false
                player.invalidatePlayers()
                do {
                    let newEngine = try CHHapticEngine()
                    setupEngineHandlers(for: newEngine)
                    engine = newEngine
                    try newEngine.start()
                    isEngineStarted = true
                } catch {
                    print("Failed to recreate and start CHHapticEngine: \(error)")
                }
            }
        }
    }

    func stop() {
        player.stop()
        engine?.stop()
        isEngineStarted = false
    }

    func updateParameters(velocity: CGFloat, texture: HapticTexture, preferences: UserPreferences) {
        guard supportsHaptics, preferences.isHapticsEnabled else {
            stopContinuousPattern()
            return
        }
        if !isEngineStarted || engine == nil {
            start()
        }
        guard let engine = engine else { return }
        player.update(velocity: velocity, texture: texture, preferences: preferences, engine: engine)
    }

    func stopContinuousPattern() {
        player.stop()
    }
}
