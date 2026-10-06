import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Adaptive, neutral surfaces. Brand accents belong to the consuming app.
public enum MizuPalette {
    public static let canvas = neutral(light: 0.97, dark: 0.09)
    public static let surface = neutral(light: 1, dark: 0.145)
    public static let raised = neutral(light: 1, dark: 0.22)
    public static let recess = Color.primary.opacity(0.055)
    public static let ink = Color.primary
    public static let line = Color.primary.opacity(0.07)
    public static var invertedInk: Color {
        #if canImport(UIKit)
        Color(uiColor: .systemBackground)
        #else
        Color(nsColor: .windowBackgroundColor)
        #endif
    }
    public static func neutral(light: CGFloat, dark: CGFloat) -> Color {
        #if canImport(UIKit)
        Color(uiColor: UIColor { traits in
            UIColor(white: traits.userInterfaceStyle == .dark ? dark : light, alpha: 1)
        })
        #else
        Color(nsColor: NSColor(name: nil) { appearance in
            NSColor(white: appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? dark : light, alpha: 1)
        })
        #endif
    }
}
