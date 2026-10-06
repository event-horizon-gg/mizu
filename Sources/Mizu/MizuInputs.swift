import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// A labelled native field with caller-supplied validation. Does not validate on its own.
public struct MizuInput: View {
    private let title: String
    @Binding private var text: String
    private let prompt: String?
    private let secure: Bool
    private let error: String?
    public init(_ title: String, text: Binding<String>, prompt: String? = nil, secure: Bool = false, error: String? = nil) {
        self.title = title; self._text = text; self.prompt = prompt; self.secure = secure; self.error = error
    }
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption.weight(.medium)).foregroundStyle(.secondary)
            Group {
                if secure { SecureField(title, text: $text, prompt: prompt.map { Text($0) }) }
                else { TextField(title, text: $text, prompt: prompt.map { Text($0) }) }
            }.textFieldStyle(.plain).padding(14)
                .background(MizuPalette.recess, in: RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(error == nil ? MizuPalette.line : .red.opacity(0.6)))
                .mizuFeedback(.error, trigger: error, isEnabled: error != nil)
            if let error { Label(error, systemImage: "exclamationmark.circle").font(.footnote).foregroundStyle(.red) }
        }
    }
}

/// Compose labelled fields and custom leading/trailing content in a shared surface.
public struct MizuInputGroup<Content: View>: View {
    private let title: String?
    private let content: Content
    public init(_ title: String? = nil, @ViewBuilder content: () -> Content) { self.title = title; self.content = content() }
    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            if let title { Text(title).font(.headline) }
            content
        }.padding(20).mizuSurface(cornerRadius: 22)
    }
}

public struct MizuInputCopy: View {
    private let title: String
    private let value: String
    private let copyLabel: String
    private let copiedLabel: String
    @State private var copies = 0
    @State private var copied = false
    public init(_ title: String, value: String, copyLabel: String = "Copy", copiedLabel: String = "Copied") {
        self.title = title; self.value = value; self.copyLabel = copyLabel; self.copiedLabel = copiedLabel
    }
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            ViewThatFits(in: .horizontal) {
                HStack { valueText; Spacer(minLength: 12); copyButton }
                VStack(alignment: .leading, spacing: 12) { valueText; copyButton }
            }
        }.padding(18).mizuSurface(cornerRadius: 20)
            .task(id: copies) {
                guard copies > 0 else { return }
                do { try await Task.sleep(for: .seconds(2)); copied = false } catch {}
            }
    }
    private var valueText: some View { Text(value).font(.system(.body, design: .monospaced)).textSelection(.enabled).fixedSize(horizontal: false, vertical: true) }
    private var copyButton: some View {
        Button {
            #if canImport(UIKit)
            UIPasteboard.general.string = value
            #else
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(value, forType: .string)
            #endif
            copied = true; copies += 1
        } label: {
            Label(copied ? copiedLabel : copyLabel, systemImage: copied ? "checkmark" : "doc.on.doc")
        }.buttonStyle(MizuActionStyle(secondary: true))
            .mizuFeedback(.success, trigger: copies)
    }
}

public struct MizuInputMessage: View {
    private let title: String
    @Binding private var text: String
    private let sendLabel: String
    private let clearOnSend: Bool
    private let onSend: (String) -> Void
    public init(_ title: String = "Message", text: Binding<String>, sendLabel: String = "Send",
                clearOnSend: Bool = true, onSend: @escaping (String) -> Void) {
        self.title = title; self._text = text; self.sendLabel = sendLabel; self.clearOnSend = clearOnSend; self.onSend = onSend
    }
    private var trimmed: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            TextField(title, text: $text, axis: .vertical).lineLimit(1...5).textFieldStyle(.plain)
                .padding(.vertical, 10).accessibilityLabel(title)
            HStack {
                Spacer()
                MizuButton(sendLabel) {
                    let message = trimmed
                    guard !message.isEmpty else { return }
                    if clearOnSend { text = "" }
                    onSend(message)
                }.disabled(trimmed.isEmpty)
            }
        }.padding(18).mizuSurface(cornerRadius: 22)
    }
}
