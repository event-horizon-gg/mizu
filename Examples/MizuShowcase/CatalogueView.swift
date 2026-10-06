import SwiftUI
import Mizu

struct CatalogueView: View {
    private let categories = ["Buttons & status", "Choices & inputs", "Presentation & data", "Conversation", "Questions"]
    var body: some View {
        List(categories, id: \.self) { category in
            NavigationLink(category) {
                Group {
                    switch category {
                    case "Buttons & status": ButtonsDemo()
                    case "Choices & inputs": FormDemo()
                    case "Presentation & data": PresentationDemo()
                    case "Conversation": ConversationDemo()
                    default: QuestionsDemo()
                    }
                }.navigationTitle(category).navigationBarTitleDisplayMode(.inline)
            }
        }.navigationTitle("Component catalogue").navigationBarTitleDisplayMode(.inline)
    }
}

private struct DemoPage<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        ScrollView { VStack(alignment: .leading, spacing: 24) { content }.padding(24).frame(maxWidth: 650).frame(maxWidth: .infinity) }
            .background(MizuPalette.canvas)
    }
}

private struct ButtonsDemo: View {
    @State private var outcome = "Ready"
    @State private var errors = 0
    @State private var successes = 0
    var body: some View {
        DemoPage {
            Text("Buttons").font(.title2.weight(.semibold))
            MizuButton("Primary") { outcome = "Primary selected" }
            MizuButton("Secondary", kind: .secondary) { outcome = "Secondary selected" }
            MizuButton("Tertiary", kind: .tertiary) { outcome = "Tertiary selected" }
            MizuButton("Ghost", kind: .ghost) { outcome = "Ghost selected" }
            MizuButton("Disabled") {}.disabled(true)
            Text(outcome).accessibilityIdentifier("catalogue-action")
            Text("Badges").font(.headline)
            ViewThatFits(in: .horizontal) {
                HStack { badges }
                VStack(alignment: .leading) { badges }
            }
            Text("Semantic feedback").font(.headline)
            MizuButton("Show success", kind: .secondary) { successes += 1 }
            Label("Saved · \(successes)", systemImage: "checkmark.circle").accessibilityIdentifier("success-feedback").padding(18).mizuSurface()
                .mizuFeedback(.success, trigger: successes)
            MizuButton("Show error", kind: .secondary) { errors += 1 }
            Label("Please check this value", systemImage: "exclamationmark.circle").padding(18).mizuSurface()
                .mizuFeedback(.error, trigger: errors)
        }
    }
    @ViewBuilder private var badges: some View {
        MizuBadge("Draft")
        MizuBadge("Active", symbol: "checkmark", tone: .positive)
        MizuBadge("Needs review", tone: .warning)
        MizuBadge("Failed", tone: .negative)
    }
}

private struct FormDemo: View {
    @State private var selected: Set<String> = ["Notifications"]
    @State private var mode = "Calm"
    @State private var role = "Viewer"
    @State private var enabled = false
    @State private var accent: Color = .mint
    @State private var volume = 60.0
    @State private var name = ""
    @State private var email = ""
    @State private var validation: String?
    var body: some View {
        DemoPage {
            Text("Checkbox group").font(.headline)
            MizuCheckboxGroup(["Notifications", "Sound"], selection: $selected, title: { $0 })
            Text("Selected: \(selected.sorted().joined(separator: ", "))").font(.footnote).accessibilityIdentifier("checkbox-result")
            Text("Radio group").font(.headline)
            MizuRadioGroup(["Calm", "Focused"], selection: $mode, title: { $0 })
            Text("Mode: \(mode)").accessibilityIdentifier("radio-result")
            MizuSwitch("Private mode", isOn: $enabled)
            MizuSelect("Role", values: ["Viewer", "Editor", "Owner"], selection: $role, optionTitle: { $0 })
            MizuColorPicker("Accent", selection: $accent)
            MizuSlider("Volume", value: $volume, in: 0...100, step: 1, format: { "\(Int($0))%" })
            MizuInputGroup("Profile") {
                MizuInput("Name", text: $name, prompt: "Your name")
                MizuInput("Email", text: $email, prompt: "you@example.com", error: validation)
                MizuButton("Check email", kind: .secondary) { validation = email.contains("@") ? nil : "Include an @ in your email" }
            }
            MizuInputCopy("Example identifier", value: "MIZU-DEMO-001")
        }
    }
}

private struct DemoPerson: Identifiable {
    let id: String
    let name: String
    let role: String
}

private struct PresentationDemo: View {
    @State private var expanded = false
    @State private var dialog = false
    @State private var action = "No menu action"
    @State private var tab = "Details"
    @State private var subtleTab = "Design"
    private let rows = [DemoPerson(id: "zoe", name: "Zoe", role: "Engineer"), DemoPerson(id: "kai", name: "Kai", role: "Designer"), DemoPerson(id: "mira", name: "Mira", role: "Editor")]
    var body: some View {
        DemoPage {
            MizuAccordion("How surfaces work", isExpanded: $expanded) {
                Text("Soft layers keep content readable.")
            }
            MizuTooltip("Every control follows the system accessibility settings.") { Text("Accessible controls").font(.headline) }
            MizuButton("Open dialog") { dialog = true }
            MizuDropdown {
                Button("Export") { action = "Export selected" }
                Button("Duplicate") { action = "Duplicate selected" }
                Button("Delete", role: .destructive) { action = "Delete selected" }
            } label: { Label("Actions", systemImage: "ellipsis") }
            Text(action).accessibilityIdentifier("menu-result")
            Text("Tabs").font(.headline)
            MizuTabs(["Details", "History"], selection: $tab, title: { $0 }) { value in Text("Showing \(value)").padding(18).mizuSurface() }
            Text("Subtle tabs").font(.headline)
            MizuTabs(["Design", "Motion", "Access"], selection: $subtleTab, style: .subtle, title: { $0 }) { value in Text("Showing \(value)") }
            Text("Sortable table").font(.headline)
            MizuTable(rows: rows, columns: [
                MizuTableColumn("name", title: "Name", width: 140, text: { $0.name }, order: { $0.name < $1.name }),
                MizuTableColumn("role", title: "Role", width: 160, text: { $0.role }, order: { $0.role < $1.role })
            ])
        }.mizuDialog(isPresented: $dialog, title: "Native dialog") {
            Text("This sheet supports native focus, scrolling and dismissal.")
            MizuBadge("Ready", tone: .positive)
        }
    }
}

private struct ConversationDemo: View {
    @State private var message = ""
    @State private var sent: [String] = []
    @State private var complete = false
    var body: some View {
        DemoPage {
            MizuChatMessage(role: .user, author: "You", metadata: "Just now") { Text("Show me the component library.") }
            MizuChatMessage(role: .assistant, author: "Assistant") {
                Text("Here are the native controls and their current status.")
                MizuBadge("Example", tone: .accent)
            }
            MizuThinkingIndicator("Preparing preview")
            MizuThinkingSteps([
                .init(id: "read", title: "Read components", detail: "The catalogue contains native examples.", status: .complete),
                .init(id: "preview", title: "Prepare preview", detail: "Appearance adapts to light and dark.", status: complete ? .complete : .active),
                .init(id: "review", title: "Review accessibility", status: .pending)
            ])
            MizuButton("Complete preview", kind: .secondary) { complete = true }
            ForEach(Array(sent.enumerated()), id: \.offset) { _, text in
                MizuChatMessage(role: .user, author: "You") { Text(text) }
            }
            MizuInputMessage("Message", text: $message) { sent.append($0) }
            Text("Sent: \(sent.count)").accessibilityIdentifier("sent-count")
        }
    }
}

private struct QuestionsDemo: View {
    @State private var index = 0
    @State private var answers: [String: MizuQuestionAnswer] = [:]
    @State private var result: String?
    private let questions: [MizuQuestion] = [
        .init(id: "use", title: "How will you use Mizu?", options: [
            .init(id: "personal", title: "Personal", detail: "Build something for yourself."),
            .init(id: "team", title: "Team", detail: "Share components across apps.")
        ], skippable: false),
        .init(id: "features", title: "What matters to you?", options: [
            .init(id: "cards", title: "Cards"), .init(id: "coverage", title: "Coverage"), .init(id: "motion", title: "Motion")
        ], multiple: true, allowsOther: true)
    ]
    var body: some View {
        DemoPage {
            MizuAskUserQuestions(questions, currentIndex: $index, answers: $answers) { saved in result = "Complete: \(saved.count) answers" }
            if let result { Text(result).accessibilityIdentifier("question-result") }
        }
    }
}
