//
//  SettingsView.swift
//  knowzeno
//

import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings
    @State private var apiKeyDraft: String
    @State private var shortcutDraft: GlobalKeyboardShortcut

    init(settings: AppSettings) {
        self.settings = settings
        _apiKeyDraft = State(initialValue: settings.apiKey)
        _shortcutDraft = State(initialValue: settings.globalShortcut)
    }

    var body: some View {
        Form {
            Section {
                SecureField("API Key", text: $apiKeyDraft)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Button("Save API Key", systemImage: "key", action: saveAPIKey)

                    Button("Clear API Key", systemImage: "trash", action: clearAPIKey)
                        .disabled(settings.apiKey.isEmpty && apiKeyDraft.isEmpty)
                }
            } header: {
                Text("API Key")
            }

            Section {
                ShortcutRecorderView(shortcut: $shortcutDraft)

                HStack {
                    Button("Save Shortcut", systemImage: "keyboard", action: saveShortcut)

                    Button("Reset to Default", systemImage: "arrow.counterclockwise", action: resetShortcut)
                }

                if settings.hotKeyStatusMessage.isEmpty == false {
                    Text(settings.hotKeyStatusMessage)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text("Global Shortcut")
            }

            if let settingsErrorMessage = settings.settingsErrorMessage {
                Text(settingsErrorMessage)
                    .foregroundStyle(.red)
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(minWidth: 440, minHeight: 300)
        .onChange(of: settings.apiKey) { _, newValue in
            apiKeyDraft = newValue
        }
        .onChange(of: settings.globalShortcut) { _, newValue in
            shortcutDraft = newValue
        }
    }

    private func saveAPIKey() {
        settings.saveAPIKey(apiKeyDraft)
    }

    private func clearAPIKey() {
        apiKeyDraft = ""
        settings.saveAPIKey("")
    }

    private func saveShortcut() {
        settings.saveShortcut(shortcutDraft)
    }

    private func resetShortcut() {
        shortcutDraft = .default
        settings.saveShortcut(.default)
    }
}

#Preview {
    SettingsView(settings: AppSettings())
}
