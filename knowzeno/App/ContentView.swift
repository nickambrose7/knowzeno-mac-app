//
//  ContentView.swift
//  knowzeno
//
//  Created by Nick Ambrose on 4/26/26.
//

import SwiftUI
import AppKit

struct ContentView: View {
    let capture: SelectedTextCapture
    let settings: AppSettings

    var body: some View {
        TabView {
            CaptureView(capture: capture, settings: settings)
                .tabItem {
                    Label("Capture", systemImage: "text.viewfinder")
                }

            LearningItemLibraryView(settings: settings)
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
        }
        .frame(minWidth: 520, minHeight: 520)
    }
}

private struct CaptureView: View {
    let capture: SelectedTextCapture
    let settings: AppSettings
    private let apiClient = SourceNoteAPIClient()
    @State private var isSendingSourceNote = false
    @State private var sendStatusMessage: String?
    @State private var sendStatusStyle = SendStatusStyle.neutral
    @FocusState private var focusedControl: CaptureFocusedControl?

    var body: some View {
        @Bindable var capture = capture

        VStack(alignment: .leading, spacing: 16) {
            Label {
                Text("knowzeno")
                    .font(.title2)
                    .bold()
            } icon: {
                Image(systemName: "text.viewfinder")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
            }

            Text(capture.statusMessage)
                .foregroundStyle(.secondary)

            Text("Global shortcut: \(settings.globalShortcut.displayText)")
                .foregroundStyle(.secondary)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $capture.lastCapturedText)
                    .font(.body.monospaced())
                    .lineSpacing(4)
                    .padding(8)
                    .focused($focusedControl, equals: .textEditor)
                    .accessibilityLabel("Captured text editor")

                if capture.lastCapturedText.isEmpty {
                    Text("No captured text")
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }
            }
            .frame(minWidth: 420, minHeight: 220)
            .overlay {
                Rectangle()
                    .stroke(.quaternary)
            }

            HStack {
                Button("Clear Editor", systemImage: "trash") {
                    capture.clearCapturedText()
                }

                Spacer()

                FocusableSendTextButton(
                    focusRequest: capture.sendButtonFocusRequest,
                    isDisabled: sendButtonIsDisabled,
                    action: sendTextToServer
                )
                .fixedSize()
            }

            if let sendStatusMessage {
                Label {
                    Text(sendStatusMessage)
                } icon: {
                    Image(systemName: sendStatusStyle.systemImage)
                }
                .foregroundStyle(sendStatusStyle.foregroundStyle)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(sendStatusStyle.backgroundStyle)
                .clipShape(.rect(cornerRadius: 8))
            }
        }
        .padding(24)
        .task(id: capture.textEditorFocusRequest) {
            focusTextEditorWhenRequested()
        }
        .onChange(of: capture.textEditorFocusRequest) { _, _ in
            focusTextEditorWhenRequested()
        }
        .task(id: capture.sendButtonFocusRequest) {
            focusSendButtonWhenRequested()
        }
        .onChange(of: capture.sendButtonFocusRequest) { _, _ in
            focusSendButtonWhenRequested()
        }
    }

    private var sendButtonIsDisabled: Bool {
        isSendingSourceNote
            || capture.lastCapturedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || settings.apiKey.isEmpty
    }

    private func sendTextToServer() {
        let text = capture.lastCapturedText
        sendStatusStyle = .neutral

        Task {
            await sendSourceNote(text)
        }
    }

    private func focusTextEditorWhenRequested() {
        guard capture.textEditorFocusRequest > 0 else {
            return
        }

        focusedControl = .textEditor
    }

    private func focusSendButtonWhenRequested() {
        guard capture.sendButtonFocusRequest > 0, sendButtonIsDisabled == false else {
            return
        }

        focusedControl = .sendButton
    }

    private func sendSourceNote(_ text: String) async {
        isSendingSourceNote = true
        sendStatusMessage = "Sending..."
        sendStatusStyle = .neutral

        do {
            let serverBaseURL = try AppConfiguration.sourceNoteServerBaseURL()

            _ = try await apiClient.createSourceNote(
                text: text,
                apiKey: settings.apiKey,
                serverBaseURL: serverBaseURL
            )
            capture.clearCapturedText()
            sendStatusMessage = "Source note sent successfully."
            sendStatusStyle = .success
            focusedControl = .textEditor
        } catch {
            sendStatusMessage = error.localizedDescription
            sendStatusStyle = .error
        }

        isSendingSourceNote = false
    }
}

private enum CaptureFocusedControl: Hashable {
    case textEditor
    case sendButton
}

private struct FocusableSendTextButton: NSViewRepresentable {
    let focusRequest: Int
    let isDisabled: Bool
    let action: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }

    func makeNSView(context: Context) -> NSButton {
        let button = ReturnActivatingButton(
            title: "Send text to server",
            target: context.coordinator,
            action: #selector(Coordinator.sendTextToServer)
        )
        button.bezelStyle = .rounded
        button.image = NSImage(systemSymbolName: "paperplane", accessibilityDescription: nil)
        button.imagePosition = .imageLeading
        button.setButtonType(.momentaryPushIn)
        button.refusesFirstResponder = false
        return button
    }

    func updateNSView(_ button: NSButton, context: Context) {
        context.coordinator.action = action
        button.isEnabled = isDisabled == false
        button.keyEquivalent = ""

        guard focusRequest > 0,
              focusRequest != context.coordinator.lastAppliedFocusRequest,
              isDisabled == false else {
            return
        }

        context.coordinator.lastAppliedFocusRequest = focusRequest

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(50))
            button.window?.makeFirstResponder(button)
        }
    }

    final class Coordinator: NSObject {
        var action: () -> Void
        var lastAppliedFocusRequest = 0

        init(action: @escaping () -> Void) {
            self.action = action
        }

        @objc func sendTextToServer() {
            action()
        }
    }
}

private final class ReturnActivatingButton: NSButton {
    override func keyDown(with event: NSEvent) {
        guard event.modifierFlags.intersection(.deviceIndependentFlagsMask).isEmpty else {
            super.keyDown(with: event)
            return
        }

        switch event.charactersIgnoringModifiers {
        case "\r", "\u{3}":
            performClick(nil)
        default:
            super.keyDown(with: event)
        }
    }
}

private enum SendStatusStyle {
    case neutral
    case success
    case error

    var systemImage: String {
        switch self {
        case .neutral:
            "info.circle"
        case .success:
            "checkmark.circle.fill"
        case .error:
            "exclamationmark.triangle.fill"
        }
    }

    var foregroundStyle: Color {
        switch self {
        case .neutral:
            .secondary
        case .success:
            .green
        case .error:
            .red
        }
    }

    var backgroundStyle: Color {
        switch self {
        case .neutral:
            .clear
        case .success:
            .green.opacity(0.12)
        case .error:
            .red.opacity(0.12)
        }
    }
}

#Preview {
    ContentView(capture: SelectedTextCapture(), settings: AppSettings())
}
