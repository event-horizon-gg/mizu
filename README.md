# Mizu

A native SwiftUI library for adaptive surfaces, tactile controls and purposeful motion. Independently inspired by Fluid Functionalism. Inari is its first consumer.

## Use locally

Requires iOS 17+ or macOS 14+, Swift 5.9+.

```swift
.package(path: "../mizu")
// Target dependency: .product(name: "Mizu", package: "mizu")
```

```swift
import SwiftUI
import Mizu

VStack(alignment: .leading, spacing: 16) {
    Text("Your content").font(.title3.weight(.semibold))
    Button("Continue") { /* perform action */ }
        .buttonStyle(MizuActionStyle())
}.padding(22).mizuSurface()
```

- `MizuPalette`: canvas, surface, raised, recess, ink, line; adaptive neutral colours.
- `MizuAppearance`: system/light/dark and an optional `colorScheme`. The app owns storage.
- `.mizuReduceMotion(true)`: disable library motion for a subtree; system Reduce Motion always wins.
- `MizuMotion`: press and selection springs; return nil when Reduce Motion is enabled.
- `MizuPressStyle`: feedback for caller-styled controls; the caller owns their accessible target size.
- `MizuActionStyle(secondary:cornerRadius:)`: 48-point minimum height, disabled feedback and optional secondary appearance.
- `.mizuSurface(cornerRadius:fill:)`: full-width surface; apply after your content padding.
- `MizuSegmentedControl(_:selection:title:)`: unique hashable values, native buttons and selected accessibility traits. Supply a selection present in the values and short, localized labels.

Controls respect system Reduce Motion; selection stacks at accessibility text sizes. Strings and brand colours belong to your app. The library makes no network requests and includes no analytics, stored preferences or business models. Copy writes the clipboard only after a user action.

## Showcase

Open `Examples/MizuShowcase.xcodeproj`, choose **MizuShowcase** and an iPhone simulator. The app demonstrates selection, actions, adaptive layers, appearance, radius and Reduce Motion. `--light` and `--dark` launch arguments support visual checks.

## Component catalogue and Pow

All 22 reference component families have initial native counterparts, available in the showcase's **Component catalogue**. See [components and API boundaries](docs/COMPONENTS.md). This is independent native family coverage, not full upstream feature/prop parity.

Mizu bundles Pow 1.0.6 for default semantic feedback in its new controls. Apps do not need to import Pow. Read [feedback configuration](docs/FEEDBACK.md) to disable visual effects or haptics independently. System Reduce Motion always wins. The original button styles retain their established springs, preserving Inari's existing transition.

```swift
MizuButton("Continue") { proceed() }
MizuSwitch("Notifications", isOn: $notifications)
// Configure a subtree:
RootView().mizuFeedback(.init(effectsEnabled: true, hapticsEnabled: false))
```

## Validation and roadmap

GitHub Actions compiles the package on macOS, builds the iPhone showcase and runs UI checks for selection, action callbacks, disabled state and operation with large text/Reduce Motion. Inari consumes the local sibling package during development. No remote repository or release tag exists yet; nothing has been published.

Foundations and initial native versions of the 22 reference component families are implemented. Full variant parity, localisation, richer composition APIs, a versioned dependency and broader VoiceOver/Dynamic Type testing remain planned. See [design provenance](docs/DESIGN-PROVENANCE.md) for the reference audit and release boundaries. A distribution licence has not yet been selected.
