//
//  ContentView.swift
//  knowzeno
//
//  Created by Nick Ambrose on 4/26/26.
//

import SwiftUI

struct ContentView: View {
    let capture: SelectedTextCapture
    let settings: AppSettings
    private let apiClient = SourceNoteAPIClient()
    @State private var isSendingSourceNote = false
    @State private var sendStatusMessage: String?
    @State private var sendStatusStyle = SendStatusStyle.neutral
    @FocusState private var textEditorIsFocused: Bool

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
                    .focused($textEditorIsFocused)
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

                Button("Send text to server", systemImage: "paperplane", action: sendTextToServer)
                    .disabled(sendButtonIsDisabled)
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

        textEditorIsFocused = true
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
            capture.lastCapturedText = ""
            sendStatusMessage = "Source note sent successfully."
            sendStatusStyle = .success
        } catch {
            sendStatusMessage = error.localizedDescription
            sendStatusStyle = .error
        }

        isSendingSourceNote = false
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
