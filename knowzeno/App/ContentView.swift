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
                KnowzenoLogoMark()
                    .frame(width: 40, height: 40)
            }

            Text(capture.statusMessage)
                .foregroundStyle(.secondary)

            Text("Global shortcut: \(settings.globalShortcut.displayText)")
                .foregroundStyle(.secondary)

            Text("The shortcut captures only your selected text into this editor. Nothing is sent to the backend until you press Send text to server.")
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
                Button {
                    capture.clearCapturedText()
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(CaptureActionButtonStyle(tint: .red))
                .accessibilityLabel("Clear Editor")
                .help("Clear Editor")

                Spacer()

                Button("Send text to server", systemImage: "paperplane") {
                    sendTextToServer()
                }
                .buttonStyle(CaptureActionButtonStyle())
                .disabled(sendButtonIsDisabled)
                .focused($focusedControl, equals: .sendButton)
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

private struct CaptureActionButtonStyle: ButtonStyle {
    var tint: Color = .accentColor

    func makeBody(configuration: Configuration) -> some View {
        CaptureActionButton(configuration: configuration, tint: tint)
    }
}

private struct CaptureActionButton: View {
    let configuration: ButtonStyle.Configuration
    let tint: Color

    @Environment(\.isEnabled) private var isEnabled
    @State private var isHovered = false

    var body: some View {
        configuration.label
            .font(.callout)
            .bold()
            .foregroundStyle(foregroundStyle)
            .padding(.horizontal, 12)
            .frame(minWidth: 36, minHeight: 30)
            .background(backgroundShape)
            .overlay(borderShape)
            .clipShape(.rect(cornerRadius: 7))
            .contentShape(.rect)
            .opacity(isEnabled ? 1 : 0.45)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: isHovered)
            .animation(.easeOut(duration: 0.08), value: configuration.isPressed)
            .onHover { isHovered = $0 }
    }

    private var foregroundStyle: Color {
        guard isEnabled else { return .secondary }
        return isHovered ? tint : .secondary
    }

    private var backgroundShape: some View {
        RoundedRectangle(cornerRadius: 7)
            .fill(backgroundColor)
    }

    private var borderShape: some View {
        RoundedRectangle(cornerRadius: 7)
            .stroke(borderColor, lineWidth: 1)
    }

    private var backgroundColor: Color {
        guard isEnabled else { return .clear }

        if configuration.isPressed {
            return tint.opacity(0.22)
        }

        return isHovered ? tint.opacity(0.14) : Color.secondary.opacity(0.08)
    }

    private var borderColor: Color {
        guard isEnabled else { return Color.secondary.opacity(0.12) }
        return isHovered ? tint.opacity(0.65) : Color.secondary.opacity(0.22)
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
