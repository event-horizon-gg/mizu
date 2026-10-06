import SwiftUI
import Pow

public struct MizuFeedbackConfiguration: Equatable, Sendable {
    public var effectsEnabled: Bool
    public var hapticsEnabled: Bool
    public init(effectsEnabled: Bool = true, hapticsEnabled: Bool = true) {
        self.effectsEnabled = effectsEnabled
        self.hapticsEnabled = hapticsEnabled
    }
}

private struct MizuFeedbackKey: EnvironmentKey {
    static let defaultValue = MizuFeedbackConfiguration()
}

public extension EnvironmentValues {
    var mizuFeedbackConfiguration: MizuFeedbackConfiguration {
        get { self[MizuFeedbackKey.self] }
        set { self[MizuFeedbackKey.self] = newValue }
    }
}

public enum MizuFeedback: Sendable { case activation, selection, success, error }

public extension View {
    /// Configure a subtree. Reduced motion always suppresses visual effects.
    func mizuFeedback(_ configuration: MizuFeedbackConfiguration) -> some View {
        environment(\.mizuFeedbackConfiguration, configuration)
    }
    /// Trigger semantic feedback on a value change, never merely on initial appearance.
    func mizuFeedback<V: Equatable>(_ kind: MizuFeedback, trigger: V, isEnabled: Bool = true) -> some View {
        modifier(MizuFeedbackModifier(kind: kind, trigger: trigger, requested: isEnabled))
    }
}

private struct MizuFeedbackModifier<Value: Equatable>: ViewModifier {
    let kind: MizuFeedback
    let trigger: Value
    let requested: Bool
    @Environment(\.mizuFeedbackConfiguration) private var configuration
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @Environment(\.mizuReduceMotion) private var appReduceMotion
    @Environment(\.isEnabled) private var enabled
    private var visual: Bool { requested && enabled && configuration.effectsEnabled && !systemReduceMotion && !appReduceMotion }
    private var haptics: Bool { requested && enabled && configuration.hapticsEnabled }
    // Routine actions, selections and successes do not draw expanding outlines.
    // Controls already provide press/selection feedback; retain only error motion here.
    @ViewBuilder private func visualContent(_ content: Content) -> some View {
        switch kind {
        case .activation, .selection, .success:
            content
        case .error:
            content.changeEffect(.shake, value: trigger, isEnabled: visual)
        }
    }
    func body(content: Content) -> some View {
        #if os(iOS)
        visualContent(content).changeEffect(haptic, value: trigger, isEnabled: haptics)
        #else
        visualContent(content)
        #endif
    }
    #if os(iOS)
    private var haptic: AnyChangeEffect {
        switch kind {
        case .activation: .feedback(hapticImpact: .soft)
        case .selection: .feedbackHapticSelection
        case .success: .feedback(hapticNotification: .success)
        case .error: .feedback(hapticNotification: .error)
        }
    }
    #endif
}
