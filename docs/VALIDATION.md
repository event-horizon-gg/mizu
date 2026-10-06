# Initial extraction validation

6 October 2026, local Xcode 27, iPhone 18 Pro simulator (iOS 27).

- Package compiles on macOS.
- Showcase Debug and Release builds compile for iOS Simulator.
- Two behavioral UI tests pass: selection updates its content, both actions invoke their callbacks, the disabled action stays disabled; controls remain operable at accessibility text size with library motion disabled.
- Light and dark showcase screenshots checked for layout and adaptive surfaces.
- Inari Debug simulator build passes with the sibling Mizu dependency.
- Inari unsigned iOS Release archive and existing privacy/removed-provider checks pass.
- Existing Inari views, native card, header and card/coverage selector preserved verbatim before the shared definitions; only an import was added in that section.

The showcase tests do not establish complete VoiceOver quality, contrast compliance, animation parity or regressions in provider sign-in. Further on-device accessibility review is needed before a library release. Inari has not been reinstalled on the physical device for this extraction.

GitHub Actions workflows are authored; no hosted run has occurred. Mizu has no remote yet. Inari's hosted workflow needs MIZU_REPOSITORY/MIZU_REF configured once the remote exists, with read access if private. A pinned remote package version remains a release follow-up.
