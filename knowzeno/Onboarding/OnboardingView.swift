//
//  OnboardingView.swift
//  knowzeno
//

import SwiftUI

struct OnboardingView: View {
    private let contentSpacing: CGFloat = 16
    private let setupControlSpacing: CGFloat = 20

    @Bindable var settings: AppSettings
    @State private var apiKeyDraft: String
    @State private var shortcutDraft: GlobalKeyboardShortcut

    private var canContinue: Bool {
        apiKeyDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && shortcutDraft.isValid
    }

    init(settings: AppSettings) {
        self.settings = settings
        _apiKeyDraft = State(initialValue: settings.apiKey)
        _shortcutDraft = State(initialValue: settings.globalShortcut)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: contentSpacing) {
            Label {
                Text("Set Up knowzeno")
                    .font(.title2)
                    .bold()
            } icon: {
                Image(systemName: "text.viewfinder")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
            }

            Text("Add your API key and choose the global shortcut used to send notes to knowzeno.")
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: setupControlSpacing) {
                SecureField("API Key", text: $apiKeyDraft)
                    .textFieldStyle(.roundedBorder)

                ShortcutRecorderView(shortcut: $shortcutDraft)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let settingsErrorMessage = settings.settingsErrorMessage {
                Text(settingsErrorMessage)
                    .foregroundStyle(.red)
            }

            Spacer()

            HStack {
                Spacer()

                Button("Continue", action: saveOnboarding)
                    .buttonStyle(.borderedProminent)
                    .disabled(canContinue == false)
            }
        }
        .padding()
        .frame(minWidth: 460, minHeight: 320)
    }

    private func saveOnboarding() {
        settings.saveAPIKey(apiKeyDraft)
        settings.saveShortcut(shortcutDraft)
    }
}

#Preview {
    OnboardingView(settings: AppSettings())
}
