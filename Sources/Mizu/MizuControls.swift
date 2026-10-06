import SwiftUI

public enum MizuButtonKind: Sendable { case primary, secondary, tertiary, ghost }

/// Feedback follows an actual action, including keyboard and VoiceOver activation.
public struct MizuButton<Label: View>: View {
    private let kind: MizuButtonKind
    private let role: ButtonRole?
    private let action: () -> Void
    private let label: Label
    @State private var activation = 0
    public init(kind: MizuButtonKind = .primary, role: ButtonRole? = nil,
                action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.kind = kind; self.role = role; self.action = action; self.label = label()
    }
    public var body: some View {
        Group {
            if kind == .primary || kind == .secondary {
                button.buttonStyle(MizuActionStyle(secondary: kind == .secondary))
            } else {
                button.buttonStyle(MizuPressStyle())
                    .background(kind == .tertiary ? MizuPalette.recess : .clear, in: Capsule())
            }
        }.mizuFeedback(.activation, trigger: activation)
    }
    private var button: some View {
        Button(role: role) { activation += 1; action() } label: {
            if kind == .tertiary || kind == .ghost {
                label.padding(.horizontal, kind == .tertiary ? 18 : 8).frame(minHeight: 48).contentShape(Rectangle())
            } else { label }
        }
    }
}

public extension MizuButton where Label == Text {
    init(_ title: String, kind: MizuButtonKind = .primary, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.init(kind: kind, role: role, action: action) { Text(title) }
    }
}

public enum MizuBadgeTone: Sendable { case neutral, accent, positive, warning, negative }

public struct MizuBadge: View {
    private let title: String
    private let symbol: String?
    private let tone: MizuBadgeTone
    public init(_ title: String, symbol: String? = nil, tone: MizuBadgeTone = .neutral) {
        self.title = title; self.symbol = symbol; self.tone = tone
    }
    private var color: Color {
        switch tone { case .neutral: .primary; case .accent: .accentColor; case .positive: .green; case .warning: .orange; case .negative: .red }
    }
    public var body: some View {
        HStack(spacing: 5) {
            if let symbol { Image(systemName: symbol).accessibilityHidden(true) }
            Text(title)
        }.font(.caption.weight(.semibold)).foregroundStyle(color)
            .padding(.horizontal, 10).padding(.vertical, 6)
            .background(color.opacity(0.10), in: Capsule())
            .accessibilityElement(children: .combine)
    }
}

public struct MizuAccordion<Content: View>: View {
    private let title: String
    @Binding private var isExpanded: Bool
    private let content: Content
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.mizuReduceMotion) private var appReduceMotion
    public init(_ title: String, isExpanded: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.title = title; self._isExpanded = isExpanded; self.content = content()
    }
    public var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) { content.padding(.top, 12) } label: {
            Text(title).font(.subheadline.weight(.semibold)).frame(minHeight: 48)
        }.padding(18).mizuSurface(cornerRadius: 20)
            .animation(MizuMotion.selection(reduceMotion: systemReduceMotion || appReduceMotion), value: isExpanded)
            .mizuFeedback(.selection, trigger: isExpanded)
    }
}

public struct MizuCheckboxStyle: ToggleStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        Button { configuration.isOn.toggle() } label: {
            HStack(spacing: 12) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .font(.title3).foregroundStyle(configuration.isOn ? Color.accentColor : .secondary)
                    .accessibilityHidden(true)
                configuration.label
                Spacer(minLength: 0)
            }.padding(.horizontal, 14).frame(minHeight: 48)
                .contentShape(Rectangle())
        }.buttonStyle(MizuPressStyle())
            .accessibilityValue(configuration.isOn ? Text("Selected") : Text("Not selected"))
            .accessibilityAddTraits(configuration.isOn ? .isSelected : [])
            .mizuFeedback(.selection, trigger: configuration.isOn)
    }
}

/// Unique values, with caller-owned selection and localized labels.
public struct MizuCheckboxGroup<Value: Hashable>: View {
    private let values: [Value]
    @Binding private var selection: Set<Value>
    private let title: (Value) -> String
    public init(_ values: [Value], selection: Binding<Set<Value>>, title: @escaping (Value) -> String) {
        self.values = values; self._selection = selection; self.title = title
    }
    public var body: some View {
        VStack(spacing: 4) {
            ForEach(values, id: \.self) { value in
                Toggle(title(value), isOn: Binding(
                    get: { selection.contains(value) },
                    set: { if $0 { selection.insert(value) } else { selection.remove(value) } }
                )).toggleStyle(MizuCheckboxStyle())
            }
        }
    }
}

public struct MizuRadioGroup<Value: Hashable>: View {
    private let values: [Value]
    @Binding private var selection: Value
    private let title: (Value) -> String
    public init(_ values: [Value], selection: Binding<Value>, title: @escaping (Value) -> String) {
        self.values = values; self._selection = selection; self.title = title
    }
    public var body: some View {
        VStack(spacing: 4) {
            ForEach(values, id: \.self) { value in
                Button { selection = value } label: {
                    HStack(spacing: 12) {
                        Image(systemName: selection == value ? "largecircle.fill.circle" : "circle")
                            .foregroundStyle(selection == value ? Color.accentColor : .secondary).accessibilityHidden(true)
                        Text(title(value)); Spacer(minLength: 0)
                    }.padding(.horizontal, 14).frame(minHeight: 48).contentShape(Rectangle())
                }.buttonStyle(MizuPressStyle()).foregroundStyle(.primary)
                    .accessibilityAddTraits(selection == value ? .isSelected : [])
                    .mizuFeedback(.selection, trigger: selection, isEnabled: selection == value)
            }
        }
    }
}

public struct MizuSwitch: View {
    private let title: String
    @Binding private var isOn: Bool
    public init(_ title: String, isOn: Binding<Bool>) { self.title = title; self._isOn = isOn }
    public var body: some View {
        Toggle(title, isOn: $isOn).toggleStyle(.switch).frame(minHeight: 48)
            .mizuFeedback(.selection, trigger: isOn)
    }
}

public struct MizuSelect<Value: Hashable>: View {
    private let title: String
    private let values: [Value]
    @Binding private var selection: Value
    private let optionTitle: (Value) -> String
    public init(_ title: String, values: [Value], selection: Binding<Value>, optionTitle: @escaping (Value) -> String) {
        self.title = title; self.values = values; self._selection = selection; self.optionTitle = optionTitle
    }
    public var body: some View {
        Picker(title, selection: $selection) {
            ForEach(values, id: \.self) { Text(optionTitle($0)).tag($0) }
        }.pickerStyle(.menu).padding(14).mizuSurface(cornerRadius: 16)
            .mizuFeedback(.selection, trigger: selection)
    }
}

public struct MizuColorPicker: View {
    private let title: String
    @Binding private var selection: Color
    private let supportsOpacity: Bool
    public init(_ title: String, selection: Binding<Color>, supportsOpacity: Bool = true) {
        self.title = title; self._selection = selection; self.supportsOpacity = supportsOpacity
    }
    public var body: some View {
        ColorPicker(title, selection: $selection, supportsOpacity: supportsOpacity)
            .frame(minHeight: 48).padding(.horizontal, 14).mizuSurface(cornerRadius: 16)
    }
}

public struct MizuSlider: View {
    private let title: String
    @Binding private var value: Double
    private let range: ClosedRange<Double>
    private let step: Double
    private let format: (Double) -> String
    @State private var commits = 0
    public init(_ title: String, value: Binding<Double>, in range: ClosedRange<Double> = 0...1,
                step: Double = 0.01, format: @escaping (Double) -> String = { $0.formatted(.number.precision(.fractionLength(2))) }) {
        precondition(step > 0 && step.isFinite && range.lowerBound.isFinite && range.upperBound.isFinite && range.lowerBound < range.upperBound)
        self.title = title; self._value = value; self.range = range; self.step = step; self.format = format
    }
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack { Text(title); Spacer(); Text(format(value)).monospacedDigit().foregroundStyle(.secondary) }
            Slider(value: $value, in: range, step: step, onEditingChanged: { if !$0 { commits += 1 } }) { Text(title) }
                .accessibilityValue(format(value))
        }.padding(18).mizuSurface(cornerRadius: 20).mizuFeedback(.selection, trigger: commits)
    }
}
