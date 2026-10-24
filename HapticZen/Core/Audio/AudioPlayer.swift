import AVFoundation
import Foundation
import SwiftUI

@MainActor
class AudioPlayer {
    private var activeTextureID: String?
    private var audioBuffers: [String: AVAudioPCMBuffer] = [:]
    private var ambientBuffers: [String: AVAudioPCMBuffer] = [:]
    private var lastTransientPlayTime: TimeInterval = 0

    func update(
        velocity: CGFloat,
        position: CGPoint,
        screenSize: CGSize,
        texture: HapticTexture,
        preferences: UserPreferences,
        playerNode: AVAudioPlayerNode,
        varispeed: AVAudioUnitVarispeed,
        eq: AVAudioUnitEQ,
        mixer: AVAudioMixerNode
    ) {
        guard preferences.isAudioEnabled else {
            if playerNode.isPlaying {
                playerNode.volume = 0
            }
            return
        }

        // Map velocity to volume and varispeed rate
        let normalizedVelocity = Float(min(1.0, max(0.0, velocity / 600.0)))
        let targetVolume = max(0.1, min(1.0, (0.35 + 0.65 * normalizedVelocity) * Float(preferences.audioVolume)))
        playerNode.volume = targetVolume

        let pitchSensitivity = Float(preferences.audioPitchSensitivity)
        let rateOffset = (normalizedVelocity - 0.5) * 0.5 * pitchSensitivity
        let targetRate = max(0.5, min(2.0, Float(1.0 + rateOffset)))
        varispeed.rate = targetRate
        
        // Spatial Audio Panning (follow the finger on the X-axis)
        // Map screen X (0...width) to pan (-1.0...1.0)
        let panValue = max(-1.0, min(1.0, Float((position.x / screenSize.width) * 2.0 - 1.0)))
        playerNode.pan = panValue
        
        // Dynamic EQ (Low-Pass Filter) based on velocity for realistic friction
        // Low velocity = muffled (e.g. 500 Hz), High velocity = bright (e.g. 20000 Hz)
        if let filter = eq.bands.first {
            let targetFreq = 500.0 + 19500.0 * pow(normalizedVelocity, 1.5)
            filter.frequency = Float(targetFreq)
        }

        if texture.isContinuous {
            if activeTextureID != texture.id || !playerNode.isPlaying {
                stop(playerNode: playerNode)
                guard let buffer = getBuffer(for: texture) else { return }
                playerNode.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)
                playerNode.play()
                activeTextureID = texture.id
            }
        } else {
            // Transient pops for discrete textures
            guard velocity > 5 else { return }
            let now = Date().timeIntervalSinceReferenceDate
            let minInterval: TimeInterval = max(0.04, min(0.28, 120.0 / Double(max(10, velocity))))

            if now - lastTransientPlayTime >= minInterval {
                lastTransientPlayTime = now
                guard let buffer = getBuffer(for: texture) else { return }
                playerNode.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
                if !playerNode.isPlaying {
                    playerNode.play()
                }
            }
        }
    }

    func stop(playerNode: AVAudioPlayerNode) {
        playerNode.stop()
        activeTextureID = nil
    }

    private func getBuffer(for texture: HapticTexture) -> AVAudioPCMBuffer? {
        if let cached = audioBuffers[texture.id] {
            return cached
        }

        // Try loading from Bundle (.caf, .wav, or .m4a)
        let extensions = ["caf", "wav", "m4a"]
        for ext in extensions {
            if let url = Bundle.main.url(forResource: texture.audioFilename, withExtension: ext),
               let file = try? AVAudioFile(forReading: url),
               let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: file.fileFormat.sampleRate, channels: file.fileFormat.channelCount, interleaved: false),
               let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(file.length)) {
                do {
                    try file.read(into: buffer)
                    audioBuffers[texture.id] = buffer
                    return buffer
                } catch {
                    print("Error reading audio file \(url): \(error)")
                }
            }
        }

        // Fallback stereo procedural buffer if file missing
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        let frameCount: AVAudioFrameCount = texture.isContinuous ? 44100 * 2 : 44100 / 10
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount

        guard let channels = buffer.floatChannelData else { return nil }
        for i in 0..<Int(frameCount) {
            let t = Float(i) / 44100.0
            let sample: Float
            if texture.isContinuous {
                sample = Float.random(in: -0.3...0.3) * 0.5
            } else {
                sample = sin(2.0 * .pi * 1000.0 * t) * exp(-t * 60.0) * 0.6
            }
            channels[0][i] = sample
            channels[1][i] = sample
        }

        audioBuffers[texture.id] = buffer
        return buffer
    }

    /// Generates high-quality stereo procedural looped audio buffers for background meditative soundscapes.
    func getAmbientBuffer(for soundscape: Soundscape) -> AVAudioPCMBuffer? {
        guard soundscape != .none else { return nil }
        if let cached = ambientBuffers[soundscape.id] {
            return cached
        }

        let sampleRate: Float = 44100.0
        let format = AVAudioFormat(standardFormatWithSampleRate: Double(sampleRate), channels: 2)!
        let frameCount: AVAudioFrameCount = AVAudioFrameCount(sampleRate * 6.0) // 6 second seamless loop
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount

        guard let channels = buffer.floatChannelData else { return nil }
        var yPrevious: Float = 0.0
        var _: Float = 0.0

        for i in 0..<Int(frameCount) {
            let t = Float(i) / sampleRate
            let loopProgress = Float(i) / Float(frameCount)
            let sample: Float

            switch soundscape.id {
            case "tibetan_bowl":
                let f1: Float = 216.0
                let f2: Float = 432.0
                let f3: Float = 648.0
                let modulation = 0.6 + 0.4 * sin(2.0 * .pi * Float(loopProgress) * 2.0)
                sample = (0.5 * sin(2.0 * .pi * f1 * t) +
                          0.3 * sin(2.0 * .pi * f2 * t) +
                          0.15 * sin(2.0 * .pi * f3 * t)) * modulation * 0.6

            case "cosmicResonance", "pink_noise":
                let white = Float.random(in: -1.0...1.0)
                let alpha: Float = 0.06
                let pink = yPrevious + alpha * (white - yPrevious)
                yPrevious = pink
                let drone = sin(2.0 * .pi * 108.0 * t) * 0.2
                sample = (pink * 0.6 + drone) * 0.7

            case "rain_forest":
                let white = Float.random(in: -1.0...1.0)
                let alpha: Float = 0.12
                let pink = yPrevious + alpha * (white - yPrevious)
                yPrevious = pink
                let dropletCycle = sin(2.0 * .pi * Float(loopProgress) * 8.0)
                let droplet = dropletCycle > 0.98 ? sin(2.0 * .pi * 1200.0 * t) * 0.25 : 0.0
                sample = (pink * 0.6 + droplet) * 0.75

            case "ocean_drift":
                let white = Float.random(in: -1.0...1.0)
                let alpha: Float = 0.03
                let brown = yPrevious + alpha * (white - yPrevious)
                yPrevious = brown
                let waveEnvelope = 0.25 + 0.75 * pow(sin(.pi * Float(loopProgress)), 2)
                sample = brown * waveEnvelope * 1.4

            case "zenGarden":
                let white = Float.random(in: -1.0...1.0)
                let alpha: Float = 0.08
                let filtered = yPrevious + alpha * (white - yPrevious)
                yPrevious = filtered
                let breezeEnvelope = 0.4 + 0.6 * sin(2.0 * .pi * Float(loopProgress))
                sample = filtered * breezeEnvelope * 0.65

            default:
                sample = 0.0
            }

            channels[0][i] = sample
            channels[1][i] = sample
        }

        // Seamless loop crossfade (head-tail blending) to avoid volume dips at boundaries
        let fadeFrames = Int(sampleRate * 0.08)
        for ch in 0..<2 {
            let channelData = channels[ch]
            for i in 0..<fadeFrames {
                let fadeGain = Float(i) / Float(fadeFrames)
                let headSample = channelData[i]
                let tailSample = channelData[Int(frameCount) - fadeFrames + i]
                let blended = headSample * fadeGain + tailSample * (1.0 - fadeGain)
                channelData[i] = blended
                channelData[Int(frameCount) - fadeFrames + i] = blended
            }
        }

        ambientBuffers[soundscape.id] = buffer
        return buffer
    }
}
