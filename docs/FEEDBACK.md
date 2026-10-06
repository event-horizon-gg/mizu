# Built-in feedback

Pow 1.0.6 is a regular package dependency. Consumers import `Mizu`; Pow types do not appear in Mizu's public API. The upstream MIT notice is bundled as `Pow-LICENSE.txt` in the Mizu resource bundle. [Pow source and licence](https://github.com/EmergeTools/Pow).

New Mizu buttons, choice controls, switches, copy actions and step-status changes include feedback by default. Native colour editing, menu presentation and indefinite progress avoid extra decorative effects. Existing `MizuPressStyle` and `MizuActionStyle` retain their original spring feedback, so adopting the package does not add Pow effects to Inari's existing card/coverage selector or button aliases.

```swift
MizuButton("Save") { save() } // Default activation feedback.

Text(status)
    .mizuFeedback(.success, trigger: successfulSaveCount)

Text(errorMessage)
    .mizuFeedback(.error, trigger: failedAttemptCount)
```

Use a monotonically changing event counter when the same operation can repeat. A value must change to trigger feedback; mounting a view alone does not trigger a change effect. Success means the caller has confirmed success, not merely tapped a button. Actions, selections and successes add no expanding outlines or ripples. Buttons dim and compress immediately on press, then spring back on release; selection retains its own spring. Optional event-specific haptics remain. The legacy MizuPressStyle default preserves animated press-in for existing selection controls. Errors use Pow shake when motion is enabled. iOS haptics reflect the event type. Pow jump is deliberately not used because its implementation also generates impact haptics internally, which would prevent independent haptic opt-out.

```swift
RootView()
    .mizuFeedback(.init(effectsEnabled: true, hapticsEnabled: false))

RootView()
    .mizuFeedback(.init(effectsEnabled: false, hapticsEnabled: false))

RootView().mizuReduceMotion(true)
```

Visual effects and haptics are independently configurable for a subtree. System Reduce Motion and the Mizu override suppress visual change effects; they do not suppress haptics. Disabling effects does not remove ordinary spring transitions; use Reduce Motion to suppress those too. Disabled controls suppress their effects, and native Buttons do not invoke their actions. macOS uses visual effects without iOS haptics.

Inari retains its existing app-specific Pow effects and its exact card/coverage transition. Both dependencies resolve to the same pinned Pow version; the library does not install another distinct version.
