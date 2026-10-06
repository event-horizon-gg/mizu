import SwiftUI

/// Persist the raw value in the app; Mizu never writes user preferences.
public enum MizuAppearance: String, CaseIterable, Identifiable, Sendable {
    case system = "System", light = "Light", dark = "Dark"
    public var id: String { rawValue }
    public var colorScheme: ColorScheme? {
        switch self { case .system: nil; case .light: .light; case .dark: .dark }
    }
}

public enum MizuMotion {
    public static func press(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .spring(response: 0.25, dampingFraction: 0.8)
    }
    public static func selection(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .spring(response: 0.34, dampingFraction: 0.86)
    }
}

private struct MizuReduceMotionKey: EnvironmentKey {
    static let defaultValue = false
}

public extension EnvironmentValues {
    /// App override can disable Mizu motion; it can never override system Reduce Motion.
    var mizuReduceMotion: Bool {
        get { self[MizuReduceMotionKey.self] }
        set { self[MizuReduceMotionKey.self] = newValue }
    }
}

public extension View {
    func mizuReduceMotion(_ disabled: Bool) -> some View {
        environment(\.mizuReduceMotion, disabled)
    }
}
