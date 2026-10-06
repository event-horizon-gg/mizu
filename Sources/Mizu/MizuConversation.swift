import SwiftUI

public enum MizuMessageRole: Sendable { case user, assistant }

/// Supply attachments/actions as native child views; the library never loads files or URLs.
public struct MizuChatMessage<Content: View>: View {
    private let role: MizuMessageRole
    private let author: String
    private let metadata: String?
    private let content: Content
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.mizuReduceMotion) private var appReduceMotion
    public init(role: MizuMessageRole, author: String, metadata: String? = nil, @ViewBuilder content: () -> Content) {
        self.role = role; self.author = author; self.metadata = metadata; self.content = content()
    }
    public var body: some View {
        HStack {
            if role == .user { Spacer(minLength: 24) }
            VStack(alignment: .leading, spacing: 8) {
                Text(author).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                content
                if let metadata { Text(metadata).font(.caption2).foregroundStyle(.secondary) }
            }.padding(role == .user ? 18 : 0)
                .background(role == .user ? MizuPalette.recess : .clear, in: RoundedRectangle(cornerRadius: 22))
                .accessibilityElement(children: .contain)
            if role == .assistant { Spacer(minLength: 24) }
        }.opacity(systemReduceMotion || appReduceMotion || appeared ? 1 : 0)
            .offset(y: systemReduceMotion || appReduceMotion || appeared ? 0 : 6)
            .onAppear {
                withAnimation(MizuMotion.selection(reduceMotion: systemReduceMotion || appReduceMotion)) { appeared = true }
            }
    }
}

public struct MizuThinkingIndicator: View {
    private let title: String
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.mizuReduceMotion) private var appReduceMotion
    @Environment(\.scenePhase) private var scenePhase
    public init(_ title: String = "Thinking") { self.title = title }
    public var body: some View {
        HStack(spacing: 12) {
            if systemReduceMotion || appReduceMotion || scenePhase != .active {
                dots(phase: 0)
            } else {
                TimelineView(.periodic(from: .now, by: 0.4)) { context in
                    dots(phase: Int(context.date.timeIntervalSinceReferenceDate / 0.4) % 3)
                }
            }
            Text(title).font(.subheadline).foregroundStyle(.secondary)
        }.accessibilityElement(children: .ignore).accessibilityLabel(title)
    }
    private func dots(phase: Int) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in Circle().fill(Color.primary.opacity(index == phase ? 0.8 : 0.25)).frame(width: 5, height: 5) }
        }.accessibilityHidden(true)
    }
}

public enum MizuStepStatus: String, Sendable { case pending, active, complete, failed }

public struct MizuThinkingStep: Identifiable, Equatable, Sendable {
    public let id: String
    public var title: String
    public var detail: String?
    public var status: MizuStepStatus
    public init(id: String, title: String, detail: String? = nil, status: MizuStepStatus = .pending) {
        self.id = id; self.title = title; self.detail = detail; self.status = status
    }
}

public struct MizuThinkingSteps: View {
    private let steps: [MizuThinkingStep]
    @State private var expanded: Set<String> = []
    public init(_ steps: [MizuThinkingStep]) { self.steps = steps }
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(steps) { step in
                VStack(alignment: .leading, spacing: 8) {
                    if step.detail != nil {
                        DisclosureGroup(isExpanded: Binding(
                            get: { expanded.contains(step.id) },
                            set: { if $0 { expanded.insert(step.id) } else { expanded.remove(step.id) } }
                        )) { Text(step.detail ?? "").font(.footnote).foregroundStyle(.secondary).padding(.top, 8) }
                        label: { stepLabel(step) }
                    } else { stepLabel(step) }
                }.padding(16).mizuSurface(cornerRadius: 18)
                    .mizuFeedback(step.status == .failed ? .error : .success, trigger: step.status,
                                  isEnabled: step.status == .complete || step.status == .failed)
            }
        }
    }
    private func stepLabel(_ step: MizuThinkingStep) -> some View {
        HStack(spacing: 10) {
            if step.status == .active { MizuThinkingIndicator("") }
            else {
                Image(systemName: step.status == .complete ? "checkmark.circle.fill" : step.status == .failed ? "exclamationmark.circle" : "circle")
                    .foregroundStyle(step.status == .failed ? Color.red : .secondary).accessibilityHidden(true)
            }
            Text(step.title).font(.subheadline.weight(step.status == .active ? .semibold : .regular))
        }.frame(minHeight: 44).accessibilityElement(children: .ignore)
            .accessibilityLabel("\(step.title), \(step.status.rawValue)")
    }
}

public struct MizuQuestionOption: Identifiable, Equatable, Sendable {
    public let id: String
    public var title: String
    public var detail: String?
    public init(id: String, title: String, detail: String? = nil) { self.id = id; self.title = title; self.detail = detail }
}

public struct MizuQuestion: Identifiable, Equatable, Sendable {
    public let id: String
    public var title: String
    public var options: [MizuQuestionOption]
    public var multiple: Bool
    public var allowsOther: Bool
    public var skippable: Bool
    public init(id: String, title: String, options: [MizuQuestionOption], multiple: Bool = false,
                allowsOther: Bool = false, skippable: Bool = true) {
        self.id = id; self.title = title; self.options = options; self.multiple = multiple
        self.allowsOther = allowsOther; self.skippable = skippable
    }
}

public struct MizuQuestionAnswer: Equatable, Sendable {
    public var selectedIDs: Set<String>
    public var otherText: String
    public var skipped: Bool
    public init(selectedIDs: Set<String> = [], otherText: String = "", skipped: Bool = false) {
        self.selectedIDs = selectedIDs; self.otherText = otherText; self.skipped = skipped
    }
}

public struct MizuQuestionLabels: Sendable {
    public var back = "Back"
    public var next = "Continue"
    public var finish = "Finish"
    public var skip = "Skip"
    public var other = "Other answer"
    public var complete = "Completed"
    public var empty = "No questions"
    public init() {}
}

/// Caller owns both answers and position. Selection requires explicit confirmation on touch.
public struct MizuAskUserQuestions: View {
    private let questions: [MizuQuestion]
    @Binding private var currentIndex: Int
    @Binding private var answers: [String: MizuQuestionAnswer]
    private let labels: MizuQuestionLabels
    private let onComplete: ([String: MizuQuestionAnswer]) -> Void
    @State private var completed = false
    public init(_ questions: [MizuQuestion], currentIndex: Binding<Int>, answers: Binding<[String: MizuQuestionAnswer]>,
                labels: MizuQuestionLabels = .init(), onComplete: @escaping ([String: MizuQuestionAnswer]) -> Void) {
        self.questions = questions; self._currentIndex = currentIndex; self._answers = answers
        self.labels = labels; self.onComplete = onComplete
    }
    private var index: Int { min(max(currentIndex, 0), max(0, questions.count - 1)) }
    public var body: some View {
        Group {
            if questions.isEmpty { Text(labels.empty).foregroundStyle(.secondary) }
            else if completed { Label(labels.complete, systemImage: "checkmark.circle.fill") }
            else { questionView(questions[index]) }
        }
    }
    private func questionView(_ question: MizuQuestion) -> some View {
        let answer = answers[question.id] ?? .init()
        let validIDs = Set(question.options.map(\.id))
        let hasAnswer = !answer.selectedIDs.intersection(validIDs).isEmpty || (question.allowsOther && !answer.otherText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        return VStack(alignment: .leading, spacing: 18) {
            ProgressView(value: Double(index + 1), total: Double(questions.count))
                .accessibilityLabel("Question progress")
            Text(question.title).font(.title3.weight(.semibold))
            ForEach(question.options) { option in
                Button {
                    var updated = answers[question.id] ?? .init()
                    if question.multiple {
                        if updated.selectedIDs.contains(option.id) { updated.selectedIDs.remove(option.id) }
                        else { updated.selectedIDs.insert(option.id) }
                    } else { updated.selectedIDs = [option.id] }
                    updated.skipped = false
                    answers[question.id] = updated
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: answer.selectedIDs.contains(option.id) ? "checkmark.circle.fill" : "circle")
                            .padding(.top, 3).accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(option.title).font(.subheadline.weight(.semibold))
                            if let detail = option.detail { Text(detail).font(.footnote).foregroundStyle(.secondary) }
                        }
                        Spacer(minLength: 0)
                    }.padding(14).frame(minHeight: 48)
                        .background(answer.selectedIDs.contains(option.id) ? MizuPalette.recess : .clear, in: RoundedRectangle(cornerRadius: 16))
                        .contentShape(Rectangle())
                }.buttonStyle(MizuPressStyle()).foregroundStyle(.primary)
                    .accessibilityLabel(option.title)
                    .accessibilityHint(option.detail ?? "")
                    .accessibilityAddTraits(answer.selectedIDs.contains(option.id) ? .isSelected : [])
                    .mizuFeedback(.selection, trigger: answer.selectedIDs, isEnabled: answer.selectedIDs.contains(option.id))
            }
            if question.allowsOther {
                MizuInput(labels.other, text: Binding(
                    get: { answers[question.id]?.otherText ?? "" },
                    set: { var updated = answers[question.id] ?? .init(); updated.otherText = $0; updated.skipped = false; answers[question.id] = updated }
                ))
            }
            ViewThatFits(in: .horizontal) {
                HStack { navigation(question, hasAnswer: hasAnswer) }
                VStack(alignment: .leading) { navigation(question, hasAnswer: hasAnswer) }
            }
        }.padding(22).mizuSurface()
    }
    @ViewBuilder private func navigation(_ question: MizuQuestion, hasAnswer: Bool) -> some View {
        if index > 0 { MizuButton(labels.back, kind: .ghost) { currentIndex = index - 1 } }
        if question.skippable {
            MizuButton(labels.skip, kind: .ghost) { answers[question.id] = .init(skipped: true); advance() }
        }
        MizuButton(index == questions.count - 1 ? labels.finish : labels.next) { advance() }.disabled(!hasAnswer)
    }
    private func advance() {
        if index == questions.count - 1 { completed = true; onComplete(answers) }
        else { currentIndex = index + 1 }
    }
}
