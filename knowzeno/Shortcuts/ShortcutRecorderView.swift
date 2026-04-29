//
//  ShortcutRecorderView.swift
//  knowzeno
//

import SwiftUI

struct ShortcutRecorderView: View {
    @Binding var shortcut: GlobalKeyboardShortcut
    @State private var isRecording = false

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Keyboard Shortcut")
                    .bold()

                Text(shortcut.displayText)
                    .foregroundStyle(.secondary)
                    .monospaced()
            }

            Spacer()

            Button(isRecording ? "Press Shortcut" : "Change", systemImage: isRecording ? "keyboard.badge.ellipsis" : "keyboard") {
                isRecording.toggle()
            }
        }
        .background {
            ShortcutCaptureView(isRecording: $isRecording) { capturedShortcut in
                shortcut = capturedShortcut
                isRecording = false
            }
            .frame(width: 0, height: 0)
        }
    }
}

private struct ShortcutCaptureView: NSViewRepresentable {
    @Binding var isRecording: Bool
    let onCapture: (GlobalKeyboardShortcut) -> Void

    func makeNSView(context: Context) -> RecorderNSView {
        let view = RecorderNSView()
        view.onCapture = onCapture
        return view
    }

    func updateNSView(_ nsView: RecorderNSView, context: Context) {
        nsView.isRecording = isRecording
        nsView.onCapture = onCapture

        if isRecording {
            Task { @MainActor in
                nsView.window?.makeFirstResponder(nsView)
            }
        }
    }
}

private final class RecorderNSView: NSView {
    var isRecording = false
    var onCapture: ((GlobalKeyboardShortcut) -> Void)?

    override var acceptsFirstResponder: Bool {
        true
    }

    override func keyDown(with event: NSEvent) {
        guard isRecording, let shortcut = GlobalKeyboardShortcut(event: event) else {
            super.keyDown(with: event)
            return
        }

        onCapture?(shortcut)
    }
}

#Preview {
    @Previewable @State var shortcut = GlobalKeyboardShortcut.default
    ShortcutRecorderView(shortcut: $shortcut)
        .padding()
}
