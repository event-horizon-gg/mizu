import SwiftUI
import Mizu

@main
struct ShowcaseApp: App {
    var body: some Scene { WindowGroup {
        if ProcessInfo.processInfo.arguments.contains("--large-text") {
            ShowcaseView().dynamicTypeSize(.accessibility3)
        } else { ShowcaseView() }
    } }
}

struct ShowcaseView: View {
    @State private var appearance: MizuAppearance = .system
    @State private var selection = "Overview"
    @State private var feedback = "Try an action"
    @State private var rounded = true
    @State private var previewReduceMotion = ProcessInfo.processInfo.arguments.contains("--reduce-motion")
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    private var reduceMotion: Bool { systemReduceMotion || previewReduceMotion }
    private var launchAppearance: MizuAppearance? {
        if ProcessInfo.processInfo.arguments.contains("--dark") { return .dark }
        if ProcessInfo.processInfo.arguments.contains("--light") { return .light }
        return nil
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("MIZU").font(.caption.weight(.semibold)).tracking(3).foregroundStyle(.secondary)
                    Text("A little more fluid.").font(.largeTitle.weight(.semibold)).tracking(-1)
                    Text("Native surfaces. Quiet motion. Your app’s identity.").foregroundStyle(.secondary)
                }
                MizuSegmentedControl(["Overview", "Controls"], selection: $selection, title: { $0 })
                VStack(alignment: .leading, spacing: 16) {
                    Label(selection, systemImage: selection == "Overview" ? "square.stack.3d.up" : "slider.horizontal.3")
                        .font(.title3.weight(.semibold)).accessibilityIdentifier("selected-section")
                    Text("Adaptive layers, a soft outline and a small shadow give content room to breathe.")
                        .foregroundStyle(.secondary)
                    HStack {
                        Text("Raised surface").font(.subheadline)
                        Spacer()
                        Image(systemName: "sparkle")
                    }.padding(18).mizuSurface(cornerRadius: rounded ? 18 : 8, fill: MizuPalette.raised)
                    Text(feedback).font(.subheadline).accessibilityIdentifier("action-feedback")
                    Button("Primary action") { feedback = "Primary action selected" }
                        .buttonStyle(MizuActionStyle(cornerRadius: rounded ? 16 : 8))
                    Button("Secondary action") { feedback = "Secondary action selected" }
                        .buttonStyle(MizuActionStyle(secondary: true, cornerRadius: rounded ? 16 : 8))
                    Button("Unavailable action") {}.buttonStyle(MizuActionStyle()).disabled(true)
                }.padding(22).mizuSurface(cornerRadius: rounded ? 26 : 10)
                VStack(alignment: .leading, spacing: 20) {
                    Text("Appearance").font(.title3.weight(.semibold))
                    MizuSegmentedControl(MizuAppearance.allCases, selection: $appearance, title: { $0.rawValue })
                    Toggle("Rounded surfaces", isOn: $rounded)
                    Toggle("Preview Reduce Motion", isOn: $previewReduceMotion)
                    Text(systemReduceMotion ? "System Reduce Motion is enabled." : "Motion also follows the system accessibility setting.")
                        .font(.footnote).foregroundStyle(.secondary)
                }.padding(22).mizuSurface()
            }.padding(24).frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
        }.background(MizuPalette.canvas)
            .preferredColorScheme(appearance.colorScheme)
            .mizuReduceMotion(previewReduceMotion)
            .onAppear { if let launchAppearance { appearance = launchAppearance } }
    }
}

#Preview { ShowcaseView() }
