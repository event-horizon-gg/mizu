import SwiftUI

/// Subtle feedback for an already styled control; size and label remain caller-owned.
public struct MizuPressStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.mizuReduceMotion) private var appReduceMotion
    private var reduceMotion: Bool { systemReduceMotion || appReduceMotion }
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label.contentShape(Capsule())
            .opacity(configuration.isPressed ? 0.65 : 1)
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.97 : 1))
            .animation(MizuMotion.press(reduceMotion: reduceMotion), value: configuration.isPressed)
    }
}

/// Primary and secondary actions with a minimum 48-point height.
public struct MizuActionStyle: ButtonStyle {
    public var secondary: Bool
    public var cornerRadius: CGFloat
    @Environment(\.isEnabled) private var enabled
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.mizuReduceMotion) private var appReduceMotion
    private var reduceMotion: Bool { systemReduceMotion || appReduceMotion }
    public init(secondary: Bool = false, cornerRadius: CGFloat = 16) {
        self.secondary = secondary
        self.cornerRadius = cornerRadius
    }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.subheadline.weight(.semibold))
            .padding(.horizontal, 18).frame(minHeight: 48)
            .foregroundStyle(secondary ? Color.primary : MizuPalette.invertedInk)
            .background(secondary ? MizuPalette.recess : Color.primary, in: RoundedRectangle(cornerRadius: cornerRadius))
            .opacity(enabled ? (configuration.isPressed ? 0.75 : 1) : 0.35)
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.98 : 1))
            .animation(MizuMotion.press(reduceMotion: reduceMotion), value: configuration.isPressed)
    }
}
