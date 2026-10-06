import SwiftUI

/// A labelled selection control. Values must be unique and include the current selection.
/// Use short labels; the layout stacks vertically at accessibility text sizes.
public struct MizuSegmentedControl<Value: Hashable>: View {
    private let values: [Value]
    @Binding private var selection: Value
    private let title: (Value) -> String
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.mizuReduceMotion) private var appReduceMotion
    private var reduceMotion: Bool { systemReduceMotion || appReduceMotion }
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Namespace private var highlight
    public init(_ values: [Value], selection: Binding<Value>, title: @escaping (Value) -> String) {
        self.values = values
        self._selection = selection
        self.title = title
    }
    public var body: some View {
        let stacked = dynamicTypeSize.isAccessibilitySize
        let layout = stacked ? AnyLayout(VStackLayout(spacing: 4)) : AnyLayout(HStackLayout(spacing: 4))
        layout {
            ForEach(values, id: \.self) { value in
                Button {
                    withAnimation(MizuMotion.selection(reduceMotion: reduceMotion)) { selection = value }
                } label: {
                    Text(title(value))
                        .font(.subheadline.weight(selection == value ? .semibold : .medium))
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .frame(maxWidth: .infinity).frame(minHeight: 46)
                        .background {
                            if selection == value {
                                RoundedRectangle(cornerRadius: stacked ? 18 : 100)
                                    .fill(MizuPalette.raised)
                                    .shadow(color: .black.opacity(0.06), radius: 3, y: 2)
                                    .matchedGeometryEffect(id: "selection", in: highlight)
                            }
                        }
                }.buttonStyle(MizuPressStyle())
                    .foregroundStyle(selection == value ? MizuPalette.ink : .secondary)
                    .accessibilityAddTraits(selection == value ? .isSelected : [])
            }
        }.padding(5)
            .background(MizuPalette.recess, in: RoundedRectangle(cornerRadius: stacked ? 23 : 100))
    }
}
