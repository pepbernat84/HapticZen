import AVFoundation
import Foundation
import UIKit

@MainActor
class AudioEngine {
    static let shared = AudioEngine()

    private var audioEngine = AVAudioEngine()
    private var playerNode = AVAudioPlayerNode()
    private var ambientPlayerNode = AVAudioPlayerNode()
    private var varispeed = AVAudioUnitVarispeed()
    private var eq = AVAudioUnitEQ(numberOfBands: 1)
    private var reverb = AVAudioUnitReverb()
    
    private var isRunning = false
    private let player = AudioPlayer()
    private var activeSoundscapeID: String?
    private weak var cachedPreferences: UserPreferences?
    private var observers: [AnyObject] = []

    private(set) var sleepTimerMinutes: Int = 0
    private(set) var sleepTimerEndDate: Date? = nil
    private var sleepTimerTask: Task<Void, Never>? = nil

    private init() {
        setupSessionAndGraph()
        setupNotificationObservers()
    }

    deinit {
        for obs in observers {
            NotificationCenter.default.removeObserver(obs)
        }
        observers.removeAll()
    }

    private func setupSessionAndGraph() {
        Task.detached {
            do {
                let session = AVAudioSession.sharedInstance()
                try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
                try session.setActive(true)
            } catch {
                print("Failed to set up AVAudioSession: \(error)")
            }
        }

        // Configure EQ as a Low-Pass Filter
        if let filter = eq.bands.first {
            filter.filterType = .lowPass
            filter.frequency = 20000.0 // Start fully open
            filter.bypass = false
        }

        // Configure Ethereal Reverb
        reverb.loadFactoryPreset(.largeHall)
        reverb.wetDryMix = 25.0 // 25% wet for a subtle, ethereal tail

        audioEngine.attach(playerNode)
        audioEngine.attach(eq)
        audioEngine.attach(varispeed)
        audioEngine.attach(reverb)
        audioEngine.attach(ambientPlayerNode)

        // Graph: playerNode -> eq -> varispeed -> reverb -> mainMixerNode
        // Passing format: nil allows nodes to dynamically negotiate buffer formats without mismatch crashes
        audioEngine.connect(playerNode, to: eq, format: nil)
        audioEngine.connect(eq, to: varispeed, format: nil)
        audioEngine.connect(varispeed, to: reverb, format: nil)
        audioEngine.connect(reverb, to: audioEngine.mainMixerNode, format: nil)
        
        audioEngine.connect(ambientPlayerNode, to: audioEngine.mainMixerNode, format: nil)
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

        let obs3 = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                self?.handleInterruption(notification)
            }
        }
        observers.append(obs3)

        let obs4 = NotificationCenter.default.addObserver(
            forName: AVAudioSession.mediaServicesWereResetNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.handleMediaServicesReset()
            }
        }
        observers.append(obs4)
    }

    private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        if type == .began {
            stop()
        } else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    start()
                }
            }
        }
    }

    private func handleMediaServicesReset() {
        stop()
        // Media services reset invalidates all existing AVAudioEngine and AVAudioNode instances
        audioEngine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()
        ambientPlayerNode = AVAudioPlayerNode()
        varispeed = AVAudioUnitVarispeed()
        eq = AVAudioUnitEQ(numberOfBands: 1)
        reverb = AVAudioUnitReverb()
        setupSessionAndGraph()
        start()
    }

    func start() {
        guard !isRunning else { return }
        do {
            Task.detached {
                try? AVAudioSession.sharedInstance().setActive(true)
            }
            try audioEngine.start()
            isRunning = true
            if let prefs = cachedPreferences, prefs.isAudioEnabled, prefs.selectedSoundscape != .none {
                updateSoundscape(soundscape: prefs.selectedSoundscape, volume: prefs.soundscapeVolume, preferences: prefs)
            }
        } catch {
            print("Failed to start AVAudioEngine: \(error)")
            if !audioEngine.isRunning {
                isRunning = false
            }
        }
    }

    func stop() {
        sleepTimerTask?.cancel()
        sleepTimerTask = nil
        sleepTimerMinutes = 0
        sleepTimerEndDate = nil

        player.stop(playerNode: playerNode)
        ambientPlayerNode.stop()
        activeSoundscapeID = nil
        if audioEngine.isRunning {
            audioEngine.stop()
            isRunning = false
        }
    }

    func updateParameters(velocity: CGFloat, position: CGPoint, screenSize: CGSize, texture: HapticTexture, preferences: UserPreferences) {
        guard preferences.isAudioEnabled else {
            if playerNode.isPlaying {
                stopContinuousClip()
            }
            return
        }
        if !audioEngine.isRunning {
            start()
        }
        player.update(
            velocity: velocity,
            position: position,
            screenSize: screenSize,
            texture: texture,
            preferences: preferences,
            playerNode: playerNode,
            varispeed: varispeed,
            eq: eq,
            mixer: audioEngine.mainMixerNode
        )
    }

    func stopContinuousClip() {
        player.stop(playerNode: playerNode)
    }

    func updateSoundscape(soundscape: Soundscape, volume: Double, preferences: UserPreferences) {
        cachedPreferences = preferences
        guard preferences.isAudioEnabled && soundscape != .none else {
            if ambientPlayerNode.isPlaying {
                ambientPlayerNode.stop()
            }
            activeSoundscapeID = nil
            return
        }

        if !audioEngine.isRunning {
            start()
        }

        ambientPlayerNode.volume = Float(volume)

        if activeSoundscapeID != soundscape.id || !ambientPlayerNode.isPlaying {
            ambientPlayerNode.stop()
            if let buffer = player.getAmbientBuffer(for: soundscape) {
                ambientPlayerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
                ambientPlayerNode.play()
                activeSoundscapeID = soundscape.id
            } else {
                activeSoundscapeID = nil
            }
        }
    }

    /// Configures a smooth fade-out sleep timer for the background soundscape. Pass `0` to cancel.
    func setSleepTimer(minutes: Int, preferences: UserPreferences? = nil) {
        sleepTimerTask?.cancel()
        sleepTimerTask = nil

        if let prefs = preferences {
            cachedPreferences = prefs
        }

        guard minutes > 0 else {
            sleepTimerMinutes = 0
            sleepTimerEndDate = nil
            ambientPlayerNode.volume = Float((preferences ?? cachedPreferences)?.soundscapeVolume ?? 0.4)
            return
        }

        let clamped = max(1, min(180, minutes))
        sleepTimerMinutes = clamped
        let totalSeconds = TimeInterval(clamped * 60)
        sleepTimerEndDate = Date().addingTimeInterval(totalSeconds)

        sleepTimerTask = Task { @MainActor [weak self, weak preferences] in
            guard let self = self else { return }
            let fadeDuration = min(10.0, totalSeconds * 0.25)
            let waitDuration = max(0, totalSeconds - fadeDuration)

            if waitDuration > 0 {
                try? await Task.sleep(nanoseconds: UInt64(waitDuration * 1_000_000_000))
            }
            guard !Task.isCancelled else { return }

            let steps = 20
            let stepDuration = fadeDuration / Double(steps)
            let initialVolume = self.ambientPlayerNode.volume

            for step in 1...steps {
                guard !Task.isCancelled else { return }
                let remainingRatio = Float(steps - step) / Float(steps)
                self.ambientPlayerNode.volume = initialVolume * remainingRatio
                if stepDuration > 0 {
                    try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
                }
            }
            guard !Task.isCancelled else { return }

            self.ambientPlayerNode.stop()
            self.activeSoundscapeID = nil
            self.sleepTimerMinutes = 0
            self.sleepTimerEndDate = nil
            (preferences ?? self.cachedPreferences)?.sleepTimerMinutes = 0
        }
    }
}
