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

Controls respect system Reduce Motion; selection stacks at accessibility text sizes. Strings and brand colours belong to your app. No network requests, analytics, stored preferences or business models are included.

## Showcase

Open `Examples/MizuShowcase.xcodeproj`, choose **MizuShowcase** and an iPhone simulator. The app demonstrates selection, actions, adaptive layers, appearance, radius and Reduce Motion. `--light` and `--dark` launch arguments support visual checks.

## Validation and roadmap

GitHub Actions compiles the package on macOS, builds the iPhone showcase and runs UI checks for selection, action callbacks, disabled state and operation with large text/Reduce Motion. Inari consumes the local sibling package during development. No remote repository or release tag exists yet; nothing has been published.

This first slice extracts foundations. Further components, a versioned dependency and broader VoiceOver/Dynamic Type testing remain planned. See [design provenance](docs/DESIGN-PROVENANCE.md) for the reference audit and release boundaries. A distribution licence has not yet been selected.
