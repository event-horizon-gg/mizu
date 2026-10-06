import SwiftUI

public struct MizuDropdown<Label: View, Content: View>: View {
    private let label: Label
    private let content: Content
    public init(@ViewBuilder content: () -> Content, @ViewBuilder label: () -> Label) {
        self.label = label(); self.content = content()
    }
    public var body: some View {
        Menu { content } label: { label.padding(.horizontal, 18).frame(minHeight: 48) }
            .menuStyle(.borderlessButton)
            .background(MizuPalette.recess, in: RoundedRectangle(cornerRadius: 16))
    }
}

public struct MizuDialog<Content: View>: View {
    private let title: String
    private let closeLabel: String
    private let content: Content
    @Environment(\.dismiss) private var dismiss
    public init(_ title: String, closeLabel: String = "Close", @ViewBuilder content: () -> Content) {
        self.title = title; self.closeLabel = closeLabel; self.content = content()
    }
    public var body: some View {
        NavigationStack {
            ScrollView { VStack(alignment: .leading, spacing: 20) { content }.padding(24).frame(maxWidth: .infinity, alignment: .leading) }
                .background(MizuPalette.canvas).navigationTitle(title)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button(closeLabel) { dismiss() } } }
        }
    }
}

public extension View {
    /// Native sheet semantics preserve focus, dismissal and accessibility.
    func mizuDialog<Content: View>(isPresented: Binding<Bool>, title: String, closeLabel: String = "Close",
                                  @ViewBuilder content: @escaping () -> Content) -> some View {
        sheet(isPresented: isPresented) { MizuDialog(title, closeLabel: closeLabel, content: content) }
    }
}

/// Touch-accessible help popover; macOS also exposes a native hover tooltip.
public struct MizuTooltip<Content: View>: View {
    private let message: String
    private let helpLabel: String
    private let content: Content
    @State private var presented = false
    public init(_ message: String, helpLabel: String = "More information", @ViewBuilder content: () -> Content) {
        self.message = message; self.helpLabel = helpLabel; self.content = content()
    }
    public var body: some View {
        HStack(spacing: 8) {
            content
            Button { presented = true } label: {
                Image(systemName: "info.circle").frame(width: 44, height: 44)
            }.buttonStyle(MizuPressStyle()).accessibilityLabel(helpLabel)
                .popover(isPresented: $presented) {
                    Text(message).padding(20).frame(maxWidth: 320).fixedSize(horizontal: false, vertical: true)
                        .presentationCompactAdaptation(.popover)
                }
        }
        #if os(macOS)
        .help(message)
        #endif
    }
}

public enum MizuTabsStyle: Sendable { case pill, subtle }

public struct MizuTabs<Value: Hashable, Content: View>: View {
    private let values: [Value]
    @Binding private var selection: Value
    private let title: (Value) -> String
    private let style: MizuTabsStyle
    private let content: (Value) -> Content
    @Namespace private var indicator
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.mizuReduceMotion) private var appReduceMotion
    public init(_ values: [Value], selection: Binding<Value>, style: MizuTabsStyle = .pill,
                title: @escaping (Value) -> String, @ViewBuilder content: @escaping (Value) -> Content) {
        self.values = values; self._selection = selection; self.title = title; self.style = style; self.content = content
    }
    public var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if style == .pill { MizuSegmentedControl(values, selection: $selection, title: title) }
            else {
                ScrollView(.horizontal) {
                    HStack(spacing: 18) {
                        ForEach(values, id: \.self) { value in
                            Button {
                                withAnimation(MizuMotion.selection(reduceMotion: systemReduceMotion || appReduceMotion)) { selection = value }
                            } label: {
                                Text(title(value)).font(.subheadline.weight(selection == value ? .semibold : .medium))
                                    .padding(.horizontal, 8).frame(minHeight: 48)
                                    .overlay(alignment: .bottom) {
                                        if selection == value {
                                            Capsule().fill(Color.primary).frame(height: 2).matchedGeometryEffect(id: "line", in: indicator)
                                        }
                                    }
                            }.buttonStyle(MizuPressStyle()).foregroundStyle(selection == value ? .primary : .secondary)
                                .accessibilityAddTraits(selection == value ? .isSelected : [])
                                .mizuFeedback(.selection, trigger: selection, isEnabled: selection == value)
                        }
                    }
                }.scrollIndicators(.hidden)
            }
            content(selection)
        }
    }
}

public struct MizuTableColumn<Row>: Identifiable {
    public let id: String
    public let title: String
    public let width: CGFloat
    let text: (Row) -> String
    let order: ((Row, Row) -> Bool)?
    public init(_ id: String, title: String, width: CGFloat = 160,
                text: @escaping (Row) -> String, order: ((Row, Row) -> Bool)? = nil) {
        self.id = id; self.title = title; self.width = max(80, width); self.text = text; self.order = order
    }
}

/// Horizontal scrolling keeps every column available on iPhone. Columns may opt into sorting.
public struct MizuTable<Row: Identifiable>: View {
    private let rows: [Row]
    private let columns: [MizuTableColumn<Row>]
    private let emptyLabel: String
    @State private var sortID: String?
    @State private var ascending = true
    public init(rows: [Row], columns: [MizuTableColumn<Row>], emptyLabel: String = "No rows") {
        self.rows = rows; self.columns = columns; self.emptyLabel = emptyLabel
    }
    private var ordered: [Row] {
        guard let column = columns.first(where: { $0.id == sortID }), let order = column.order else { return rows }
        return rows.enumerated().sorted { lhs, rhs in
            if order(lhs.element, rhs.element) { return ascending }
            if order(rhs.element, lhs.element) { return !ascending }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }
    public var body: some View {
        ScrollView(.horizontal) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(columns) { column in
                        Group {
                            if column.order != nil {
                                Button {
                                    if sortID == column.id { ascending.toggle() } else { sortID = column.id; ascending = true }
                                } label: {
                                    HStack { Text(column.title); if sortID == column.id { Image(systemName: ascending ? "chevron.up" : "chevron.down") } }
                                        .frame(width: column.width, alignment: .leading).frame(minHeight: 48).contentShape(Rectangle())
                                }.buttonStyle(MizuPressStyle())
                                    .accessibilityValue(sortID == column.id ? (ascending ? "Ascending" : "Descending") : "Unsorted")
                            } else { Text(column.title) }
                        }.font(.caption.weight(.semibold)).frame(width: column.width, alignment: .leading).frame(minHeight: 48)
                    }
                }.padding(.horizontal, 16).background(MizuPalette.recess)
                if rows.isEmpty { Text(emptyLabel).padding(20).foregroundStyle(.secondary) }
                ForEach(ordered) { row in
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(columns) { column in
                            Text(column.text(row)).font(.subheadline).textSelection(.enabled)
                                .frame(width: column.width, alignment: .leading).fixedSize(horizontal: false, vertical: true)
                                .accessibilityLabel("\(column.title): \(column.text(row))")
                        }
                    }.padding(16).accessibilityElement(children: .contain)
                    Divider()
                }
            }
        }.background(MizuPalette.surface, in: RoundedRectangle(cornerRadius: 20))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(MizuPalette.line))
    }
}
