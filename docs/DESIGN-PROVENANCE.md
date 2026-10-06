# Design provenance and scope

Audit date: 6 October 2026.

Design reference: https://www.fluidfunctionalism.com and its introduction at /docs.
The examined public pages describe a React component registry and design principles. No applicable reuse licence was established from those pages; additional search was blocked by the site's robots policy. This is a bounded audit, not confirmation that no licence exists.

Mizu is an independent SwiftUI library inspired by those broad design principles. It does not claim to be an official port or to be affiliated with the reference's author. No upstream source, fonts, images, icons or documentation are included. Initial implementation derives from the UI foundations built for Inari and native SwiftUI APIs. Icons are system SF Symbols supplied by the OS.

## Package boundary

Mizu owns adaptive neutral colours, appearance choices, surface styling, press/action styles, reduced-motion-aware springs and a generic segmented control. iOS 17 is the primary minimum; macOS 14 compilation is also supported. The showcase is an iOS app.

Inari owns its brand accent, logo, card layout, insurer assets, provider sessions, persistence, coverage models, privacy cover, authentication and Pow effects. Its existing card/coverage selector and heading transition remain in Inari unchanged.

Before a public release: choose a licence for this original implementation, publish the repository, tag a version and replace Inari's sibling-path dependency with that version. No copying or official-port claim is authorized by this audit.
