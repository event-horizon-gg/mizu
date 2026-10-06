import SwiftUI

public extension View {
    /// Apply after the content's padding. No content padding is added here.
    func mizuSurface(cornerRadius: CGFloat = 26, fill: Color = MizuPalette.surface) -> some View {
        self.frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(MizuPalette.ink)
            .background(fill, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).strokeBorder(MizuPalette.line, lineWidth: 1))
            .shadow(color: .black.opacity(0.025), radius: 12, y: 4)
    }
}
