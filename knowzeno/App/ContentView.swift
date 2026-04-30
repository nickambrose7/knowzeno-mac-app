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
                Text(sendStatusMessage)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(24)
    }

    private var sendButtonIsDisabled: Bool {
        isSendingSourceNote
            || capture.lastCapturedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || settings.apiKey.isEmpty
    }

    private func sendTextToServer() {
        let text = capture.lastCapturedText

        Task {
            await sendSourceNote(text)
        }
    }

    private func sendSourceNote(_ text: String) async {
        isSendingSourceNote = true
        sendStatusMessage = "Sending..."

        do {
            let serverBaseURL = try AppConfiguration.sourceNoteServerBaseURL()

            try await apiClient.createSourceNote(
                text: text,
                apiKey: settings.apiKey,
                serverBaseURL: serverBaseURL
            )
            sendStatusMessage = "Source note sent."
        } catch {
            sendStatusMessage = error.localizedDescription
        }

        isSendingSourceNote = false
    }
}

#Preview {
    ContentView(capture: SelectedTextCapture(), settings: AppSettings())
}
