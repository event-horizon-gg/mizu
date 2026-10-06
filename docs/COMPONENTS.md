# Native component catalogue

Mizu uses the [Fluid Functionalism catalogue](https://www.fluidfunctionalism.com/) as a design reference, with independent SwiftUI implementations. The 22 families below have initial native counterparts. This means family coverage, not identical React props, every upstream variant or complete visual parity.

| Reference family | Mizu API | Native adaptation |
| --- | --- | --- |
| Accordion | `MizuAccordion` | Controlled native disclosure, animated expansion and selection feedback. |
| AskUserQuestions | `MizuAskUserQuestions` | Caller-owned position/answers, single/multiple choice, Other, Back, Skip and one completion callback. Explicit Continue confirmation on touch. |
| Badge | `MizuBadge` | Neutral/accent/positive/warning/negative tones; optional SF Symbol. Text and symbol convey status alongside colour. |
| Button | `MizuButton` | Primary/secondary/tertiary/ghost, native roles and disabled state, default action feedback. |
| ChatMessage | `MizuChatMessage` | User/assistant alignment, author and metadata, native child content and reduced-motion-aware entrance. Attachments/actions are caller-supplied views. |
| CheckboxGroup | `MizuCheckboxGroup`, `MizuCheckboxStyle` | Native toggle semantics, selected values in a caller-owned Set. |
| ColorPicker | `MizuColorPicker` | Native OS colour picker and opacity selection. No extra effect on each continuous colour edit. |
| Dialog | `MizuDialog`, `.mizuDialog(...)` | Native sheet, navigation title, scrolling, dismissal and caller-defined actions. |
| Dropdown | `MizuDropdown` | Native Menu, caller-defined actions and roles; native menu interaction rather than custom hover choreography. |
| InputCopy | `MizuInputCopy` | Selectable value, user-initiated clipboard write, temporary copied label and success feedback. |
| InputGroup | `MizuInputGroup`, `MizuInput` | Composable field group; labelled native normal/secure fields, caller-supplied validation and error feedback. |
| InputMessage | `MizuInputMessage` | Multiline composer; whitespace-only sends disabled, configurable clearing and caller-owned send callback. |
| RadioGroup | `MizuRadioGroup` | Caller-owned single selection, selected accessibility trait and feedback. |
| Select | `MizuSelect` | Native menu picker and selection feedback. |
| Slider | `MizuSlider` | Native adjustable slider, formatted value, bounded range/step, feedback at touch edit completion. |
| Switch | `MizuSwitch` | Native toggle with state-change feedback. |
| Table | `MizuTable`, `MizuTableColumn` | Horizontally scrollable columns on iPhone, optional stable sorting, empty state and labelled cells. Initial cells are textual. |
| Tabs | `MizuTabs(style: .pill)` | Segmented selection and caller-defined selected content. |
| TabsSubtle | `MizuTabs(style: .subtle)` | Scrollable text tabs with a moving underline. |
| ThinkingIndicator | `MizuThinkingIndicator` | Low-frequency dots and status label; static with Reduce Motion or inactive scene. |
| ThinkingSteps | `MizuThinkingSteps` | Caller-supplied pending/active/complete/failed steps, expandable details and completion/error feedback. |
| Tooltip | `MizuTooltip` | Accessible info button and touch popover; native hover help on macOS. |

## Public API examples

```swift
MizuButton("Save") { save() }
MizuSwitch("Notifications", isOn: $notifications)
MizuCheckboxGroup(options, selection: $selected, title: { $0.name })
MizuRadioGroup(options, selection: $choice, title: { $0.name })
MizuAccordion("Details", isExpanded: $expanded) { detailContent }
MizuInput("Email", text: $email, error: validationMessage)
MizuInputCopy("Reference", value: reference)
MizuInputMessage(text: $message) { submitted in queue(submitted) }
```

```swift
MizuTabs(sections, selection: $section, style: .subtle, title: { $0.title }) { selected in
    sectionContent(selected)
}

MizuAskUserQuestions(questions, currentIndex: $questionIndex, answers: $answers) { result in
    // Persist or submit in the app, not inside the library.
}
```

## Caller responsibilities and current boundaries

Supply unique option, question, step and column IDs. Keep a single-choice selection in its current option list. Slider step must be finite and positive; its finite range must have increasing bounds. Table ordering closures must define a consistent strict ordering. Input and message operations are synchronous callbacks; network state, retry and server validation belong to the app. Use `clearOnSend: false` if the app needs to retain a draft until asynchronous delivery succeeds.

Question flows retain prior answers when going back. Completing hides the controls to prevent duplicate callbacks. Recreate the flow with a new SwiftUI `.id(...)` to start another run. Strings are caller-supplied where exposed; some default accessibility/status strings remain English in this initial API. Localisation completeness is a release follow-up.

Files, PDF thumbnails, rich table cells, upstream question-flow variants, pointer proximity, custom input adornment slots and platform-specific keyboard shortcuts are not implemented as dedicated APIs yet. SwiftUI child-content slots support app composition where documented. Broader VoiceOver, contrast, hardware haptic feel and accessibility text-size review across the full catalogue remain needed before a stable release.

## Captured native examples

[Buttons in dark mode](images/buttons-dark.png) · [Question flow in light mode](images/questions-light.png)
