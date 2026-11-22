import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $appState.preferences.isHapticsEnabled) {
                    HStack {
                        Image(systemName: "hand.tap.fill")
                            .foregroundColor(.zenGlow)
                        Text("settings.haptics.enable")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .tint(.zenGlow)
                .padding(.vertical, 2)

                if appState.preferences.isHapticsEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "waveform")
                                .foregroundColor(.zenGlow)
                            Text("settings.haptics.intensity")
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                            Text(String(format: "%.0f%%", appState.preferences.hapticIntensityMultiplier * 100))
                                .font(.system(.footnote, design: .monospaced, weight: .semibold))
                                .foregroundColor(.zenGlow)
                        }
                        Slider(value: $appState.preferences.hapticIntensityMultiplier, in: 0.2...1.5, step: 0.1)
                            .tint(.zenGlow)
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(.zenGlow)
                            Text("settings.haptics.sharpness")
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                            Text(String(format: "%.0f%%", appState.preferences.hapticSharpnessMultiplier * 100))
                                .font(.system(.footnote, design: .monospaced, weight: .semibold))
                                .foregroundColor(.zenGlow)
                        }
                        Slider(value: $appState.preferences.hapticSharpnessMultiplier, in: 0.2...2.0, step: 0.1)
                            .tint(.zenGlow)
                    }
                    .padding(.vertical, 4)
                }

                Toggle(isOn: $appState.preferences.isAudioEnabled) {
                    HStack {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(.zenGlow)
                        Text("settings.audio.enable")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                .tint(.zenGlow)
                .padding(.vertical, 2)

                if appState.preferences.isAudioEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.zenGlow)
                            Text("settings.audio.volume")
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                            Text(String(format: "%.0f%%", appState.preferences.audioVolume * 100))
                                .font(.system(.footnote, design: .monospaced, weight: .semibold))
                                .foregroundColor(.zenGlow)
                        }
                        Slider(value: $appState.preferences.audioVolume, in: 0.0...1.0, step: 0.05)
                            .tint(.zenGlow)
                    }
                    .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "tuningfork")
                                .foregroundColor(.zenGlow)
                            Text("settings.audio.pitch")
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundColor(.white)
                            Spacer()
                            Text(String(format: "%.0f%%", appState.preferences.audioPitchSensitivity * 100))
                                .font(.system(.footnote, design: .monospaced, weight: .semibold))
                                .foregroundColor(.zenGlow)
                        }
                        Slider(value: $appState.preferences.audioPitchSensitivity, in: 0.5...2.0, step: 0.1)
                            .tint(.zenGlow)
                    }
                    .padding(.vertical, 4)

                    Picker(selection: $appState.preferences.selectedSoundscapeID) {
                        ForEach(Soundscape.allCases) { soundscape in
                            Text(soundscape.titleKey).tag(soundscape.id)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "cloud.rain.fill")
                                .foregroundColor(.zenGlow)
                            Text("settings.audio.soundscape")
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                        }
                    }
                    .pickerStyle(.menu)

                    if appState.preferences.selectedSoundscapeID != Soundscape.none.id {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "speaker.wave.1.fill")
                                    .foregroundColor(.zenGlow)
                                Text("settings.soundscape.volume")
                                    .font(.system(.subheadline, design: .rounded, weight: .medium))
                                    .foregroundColor(.white)
                                Spacer()
                                Text(String(format: "%.0f%%", appState.preferences.soundscapeVolume * 100))
                                    .font(.system(.footnote, design: .monospaced, weight: .semibold))
                                    .foregroundColor(.zenGlow)
                            }
                            Slider(value: $appState.preferences.soundscapeVolume, in: 0.0...1.0, step: 0.05)
                                .tint(.zenGlow)
                        }
                        .padding(.vertical, 4)
                    }
                }
            } header: {
                Text("settings.header.feedback")
            }
            .listRowBackground(Color.zenCardBackground)

            Section {
                Picker(selection: $appState.preferences.selectedBreathingPatternString) {
                    ForEach(BreathingPattern.allCases) { pattern in
                        Text(pattern.displayNameKey).tag(pattern.rawValue)
                    }
                } label: {
                    HStack {
                        Image(systemName: "wind")
                            .foregroundColor(.zenGlow)
                        Text("settings.wellness.breathingPattern")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                    }
                }
                .pickerStyle(.menu)

                Toggle(isOn: $appState.preferences.isHealthKitTrackingEnabled) {
                    HStack {
                        Image(systemName: "heart.text.square.fill")
                            .foregroundColor(.zenGlow)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("settings.wellness.healthkit")
                                .font(.system(.subheadline, design: .rounded, weight: .medium))
                                .foregroundColor(.white)
                            Text("settings.wellness.healthkit.desc")
                                .font(.system(.caption, design: .rounded, weight: .regular))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                .tint(.zenGlow)
                .padding(.vertical, 2)
            } header: {
                Text("settings.header.wellness")
            }
            .listRowBackground(Color.zenCardBackground)

            Section {
                Picker(selection: $appState.preferences.preferredVisualStyleString) {
                    Text("settings.visual.default").tag("")
                    ForEach(VisualStyle.allCases, id: \.self) { style in
                        Text(styleTitle(style)).tag(style.rawValue)
                    }
                } label: {
                    HStack {
                        Image(systemName: "eye.fill")
                            .foregroundColor(.zenGlow)
                        Text("settings.visual.style")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                    }
                }
                .pickerStyle(.menu)
            } header: {
                Text("settings.header.visuals")
            }
            .listRowBackground(Color.zenCardBackground)

            Section {
                Button {
                    appState.preferences.hasSeenOnboarding = false
                } label: {
                    HStack {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundColor(.zenGlow)
                        Text("settings.tutorial.show")
                            .font(.system(.subheadline, design: .rounded, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            } header: {
                Text("settings.header.help")
            }
            .listRowBackground(Color.zenCardBackground)
        }
        .scrollContentBackground(.hidden)
        .background(Color.zenDarkBackground)
        .onChange(of: appState.preferences.isAudioEnabled) { _ in
            updateAudioEngineSoundscape()
        }
        .onChange(of: appState.preferences.selectedSoundscapeID) { _ in
            updateAudioEngineSoundscape()
        }
        .onChange(of: appState.preferences.audioVolume) { _ in
            updateAudioEngineSoundscape()
        }
        .onChange(of: appState.preferences.soundscapeVolume) { _ in
            updateAudioEngineSoundscape()
        }
        .onChange(of: appState.preferences.isHealthKitTrackingEnabled) { enabled in
            if enabled && !HealthKitManager.shared.isAuthorized {
                HealthKitManager.shared.requestAuthorization { success in
                    if !success {
                        appState.preferences.isHealthKitTrackingEnabled = false
                    }
                }
            }
        }
    }

    private func updateAudioEngineSoundscape() {
        AudioEngine.shared.updateSoundscape(
            soundscape: appState.preferences.selectedSoundscape,
            volume: appState.preferences.soundscapeVolume,
            preferences: appState.preferences
        )
    }

    private func styleTitle(_ style: VisualStyle) -> LocalizedStringKey {
        switch style {
        case .shadow: return "style.shadow"
        case .ripple: return "style.ripple"
        case .particles: return "style.particles"
        }
    }
}
