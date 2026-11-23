# Haptic Zen

An iOS sensory mindfulness app built with **SwiftUI**, **Core Haptics**, and **AVAudioEngine**, featuring tactile textures, velocity-reactive spatial ASMR audio, haptic-guided breathing, Home/Lock Screen widgets, Apple HealthKit integration, and StoreKit 2 in-app purchases.

---

## Features

* **Tactile Haptic Canvas** ([`CanvasView`](HapticZen/Views/Canvas/CanvasView.swift), [`HapticPlayer`](HapticZen/Core/Haptics/HapticPlayer.swift))
  * 6 tactile textures mapped to finger velocity and sharpness (`Bubble Wrap`, `Kinetic Sand`, `Typewriter`, `Gears`, `Heavy Rain`, `Stepping Snow`).
  * Procedural and `.ahap` haptic patterns with cached reusable players.
  * Dynamic visual trails (`Ripple`, `Particles`, `Shadow`) rendered with `TimelineView` and `Canvas`.
* **Spatial & Procedural Audio** ([`AudioEngine`](HapticZen/Core/Audio/AudioEngine.swift), [`AudioPlayer`](HapticZen/Core/Audio/AudioPlayer.swift))
  * Real-time stereo panning following touch X-coordinates and dynamic low-pass EQ tied to drag velocity.
  * 5 seamless stereo soundscapes (`Zen Garden`, `Cosmic Resonance`, `Tibetan Bowls`, `Forest Stream`, `Night Rain`).
  * Built-in **Sleep Timer** (`5–60 min`) with smooth volume fade-out.
* **Haptic-Guided Breathing** ([`GuidedBreathingView`](HapticZen/Views/Breathing/GuidedBreathingView.swift), [`BreathingHapticPlayer`](HapticZen/Core/Haptics/BreathingHapticPlayer.swift))
  * Four scientifically calibrated patterns: `Paced (4-2-6-2)`, `Box (4-4-4-4)`, `Relax 4-7-8`, and `Resonant (5-5)`.
* **Wellness, Widgets & StoreKit 2**
  * Customizable daily goal (`5–60 min`), consecutive-day **Daily Streak**, and automatic midnight rollover across the app and WidgetKit (`systemSmall`, `systemMedium`, `accessoryCircular`, `accessoryRectangular`, `accessoryInline`).
  * Optional write-only Apple Health (`Mindful Minutes`) tracking via [`HealthKitManager`](HapticZen/Core/Health/HealthKitManager.swift).
  * Non-consumable packs via StoreKit 2 ([`StoreManager`](HapticZen/Core/Store/StoreManager.swift)) with offline unlock preservation, revocation handling, and local [`HapticZen.storekit`](HapticZenTests/HapticZen.storekit) configuration.
* **Trilingual & Accessible**
  * 100% localized in **Catalan (`ca`)**, **English (`en`)**, and **Spanish (`es`)** via [`Localizable.xcstrings`](HapticZen/Resources/Localizable.xcstrings).
  * Full VoiceOver support (labels, Magic Tap, breathing phase announcements), Dynamic Type scaling, and `@Environment(\.accessibilityReduceMotion)` compliance.

---

## Project Structure

```text
├── HapticZen/                  # Main iOS app target (SwiftUI, Core Haptics, AVAudioEngine, StoreKit 2, HealthKit)
├── HapticZenWidgets/           # WidgetKit extension (Home & Lock Screen widgets)
├── HapticZenTests/             # XCTest unit test suite + StoreKit configuration
├── HapticZen.xcodeproj/        # Generated Xcode project and shared scheme
├── docs/
│   ├── APP_STORE_METADATA.md   # App Store Connect copy & review notes (ca / es / en)
│   └── privacy.html            # Responsive multilingual Privacy Policy & Support page
├── scripts/
│   └── generate_screenshots.swift # Renders App Store 6.7" & 6.5" PNG screenshots
├── generate_audio_assets.py    # Procedural .caf audio asset generator
└── generate_project.py         # Deterministic Xcode .pbxproj & .xcscheme generator
```

---

## Development Commands

### Regenerate Xcode Project & Set Signing Team
```bash
# Simulator / local unsigned build
python3 generate_project.py

# Physical device / TestFlight signing (preserved across future runs)
python3 generate_project.py --team-id YOUR_TEAM_ID
```

### Build & Run Unit Tests
```bash
xcodebuild build -scheme HapticZen -destination 'generic/platform=iOS Simulator'
xcodebuild test -scheme HapticZen -destination 'platform=iOS Simulator,name=iPhone 17'
```
> Note: Core Haptics tactile feedback requires a physical iPhone with a Taptic Engine.

### Regenerate Audio & App Store Screenshots
```bash
python3 generate_audio_assets.py
swift -module-cache-path /tmp/SwiftModuleCache scripts/generate_screenshots.swift
```

---

## Privacy & Release Docs

* App Store Connect metadata & IAP setup: [`docs/APP_STORE_METADATA.md`](docs/APP_STORE_METADATA.md)
* Static Privacy Policy & Support page (GitHub Pages ready): [`docs/privacy.html`](docs/privacy.html)
