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

## Pow and 22-family catalogue expansion

Same local toolchain and authorized iPhone 18 Pro simulator.

- Final macOS package build passes with Pow 1.0.6.
- Final iOS Simulator showcase Debug and Release builds pass.
- Seven behavioral UI tests pass: existing selection/action/disabled state; large text and reduced motion; new buttons with default Pow feedback and repeated success/error events; form checkbox/radio/switch state, validation and copy feedback; whitespace rejection and one message submission; question answer persistence and completion; accordion expansion, sheet dismissal and ascending/descending table ordering.
- Captured catalogue screens reviewed in light/dark, with the root also checked at accessibility text size. These do not amount to full visual/accessibility coverage for every component variant.
- Inari simulator build and unsigned iOS Release/privacy checks pass with the expanded package.
- Pow's notice confirmed in the Mizu resource bundle inside the Inari archive. Both apps resolve the same Pow 1.0.6 commit.
- Existing Inari card, header and selector still match the pre-extraction source verbatim.

Native menu/colour-picker interactions, complete VoiceOver review, every large-text layout and physical-device haptic feel remain validation follow-ups. GitHub Actions is authored to run the seven showcase checks and retain its result bundle; no hosted run has occurred.

## Feedback refinement

Removed expanding outline/ripple feedback for every activation, selection and success event after visual review. Existing press/selection springs, optional haptics and reduced-motion-aware error shake remain. Final macOS compilation and three targeted iPhone 18 Pro UI checks pass (buttons/repeated success, selection/disabled state and question flow).
