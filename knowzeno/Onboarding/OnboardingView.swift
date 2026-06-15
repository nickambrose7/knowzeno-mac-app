//
//  OnboardingView.swift
//  knowzeno
//

import SwiftUI

struct OnboardingView: View {
    private let contentSpacing: CGFloat = 18

    @Bindable var settings: AppSettings
    @State private var apiKeyDraft: String
    @State private var shortcutDraft: GlobalKeyboardShortcut
    @State private var currentStep = OnboardingStep.privacy

    private var canContinueFromCurrentStep: Bool {
        switch currentStep {
        case .privacy:
            true
        case .shortcut:
            shortcutDraft.isValid
        case .apiKey:
            apiKeyDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        case .finish:
            apiKeyDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && shortcutDraft.isValid
        }
    }

    init(settings: AppSettings) {
        self.settings = settings
        _apiKeyDraft = State(initialValue: settings.apiKey)
        _shortcutDraft = State(initialValue: settings.globalShortcut)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: contentSpacing) {
            OnboardingHeader(currentStep: currentStep)

            currentStepContent
            .frame(maxWidth: .infinity, alignment: .leading)

            if let settingsErrorMessage = settings.settingsErrorMessage {
                Text(settingsErrorMessage)
                    .foregroundStyle(.red)
            }

            Spacer()

            HStack {
                Button("Back", action: moveBack)
                    .disabled(currentStep == .privacy)

                Spacer()

                Button(currentStep.primaryButtonTitle, action: moveForward)
                    .buttonStyle(.borderedProminent)
                    .disabled(canContinueFromCurrentStep == false)
            }
        }
        .padding()
        .frame(minWidth: 560, minHeight: 520)
    }

    @ViewBuilder
    private var currentStepContent: some View {
        switch currentStep {
        case .privacy:
            OnboardingDisclosureList(statements: OnboardingContent.privacyStatements)
        case .shortcut:
            VStack(alignment: .leading, spacing: 16) {
                OnboardingDisclosureList(statements: OnboardingContent.shortcutStatements)
                Divider()
                ShortcutRecorderView(shortcut: $shortcutDraft)
            }
        case .apiKey:
            VStack(alignment: .leading, spacing: 16) {
                OnboardingDisclosureList(statements: OnboardingContent.apiKeyStatements)
                SecureField("API Key", text: $apiKeyDraft)
                    .textFieldStyle(.roundedBorder)
            }
        case .finish:
            OnboardingDisclosureList(statements: OnboardingContent.workflowStatements)
        }
    }

    private func moveBack() {
        guard let previousStep = currentStep.previous else {
            return
        }

        currentStep = previousStep
    }

    private func moveForward() {
        guard currentStep == .finish else {
            currentStep = currentStep.next ?? .finish
            return
        }

        saveOnboarding()
    }

    private func saveOnboarding() {
        settings.completeOnboarding(apiKey: apiKeyDraft, shortcut: shortcutDraft)
    }
}

enum OnboardingContent {
    static let privacyStatements = [
        OnboardingStatement(
            systemImage: "selection.pin.in.out",
            title: "You choose the text",
            detail: "knowzeno works only with text you selected in another app. It does not read your screen, monitor your typing, or scan documents on its own."
        ),
        OnboardingStatement(
            systemImage: "keyboard",
            title: "You trigger every capture",
            detail: "A capture starts only when you press your shortcut or choose Send Selected Text to knowzeno from the menu bar."
        ),
        OnboardingStatement(
            systemImage: "square.and.pencil",
            title: "Capture is not submit",
            detail: "The shortcut copies the selected text into knowzeno's editor so you can review or edit it first. Nothing is sent to the backend during capture."
        ),
        OnboardingStatement(
            systemImage: "paperplane",
            title: "Submit sends the note",
            detail: "Selected text is sent to the knowzeno backend only after you press Send text to server. The backend uses submitted text to create source notes and learning notes."
        ),
    ]

    static let shortcutStatements = [
        OnboardingStatement(
            systemImage: "command",
            title: "Choose a shortcut you control",
            detail: "Use this shortcut after selecting text in Safari, Obsidian, Notes, a PDF, or any other app that supports text selection."
        ),
        OnboardingStatement(
            systemImage: "lock.shield",
            title: "Accessibility permission",
            detail: "macOS may ask for Accessibility permission so knowzeno can send Command-C to the active app after you trigger the shortcut."
        ),
    ]

    static let apiKeyStatements = [
        OnboardingStatement(
            systemImage: "key",
            title: "Connect your account",
            detail: "Paste the API key from your knowzeno account. The key is stored in your Mac keychain and is sent with submitted notes so the backend can save them to your account."
        ),
    ]

    static let workflowStatements = [
        OnboardingStatement(
            systemImage: "text.cursor",
            title: "1. Select text",
            detail: "Highlight only the text you want to turn into a learning note."
        ),
        OnboardingStatement(
            systemImage: "keyboard",
            title: "2. Capture it",
            detail: "Press your shortcut or use the menu bar item. The text appears in the Capture tab editor."
        ),
        OnboardingStatement(
            systemImage: "checkmark.square",
            title: "3. Review before sending",
            detail: "Edit or clear the captured text. It stays local until you press Send text to server."
        ),
        OnboardingStatement(
            systemImage: "books.vertical",
            title: "4. Review generated notes",
            detail: "Open the Library tab to see recent learning notes and delete accidental items."
        ),
    ]
}

struct OnboardingStatement: Identifiable {
    let id = UUID()
    let systemImage: String
    let title: String
    let detail: String
}

private enum OnboardingStep: CaseIterable {
    case privacy
    case shortcut
    case apiKey
    case finish

    var title: String {
        switch self {
        case .privacy:
            "How knowzeno handles text"
        case .shortcut:
            "Set your capture shortcut"
        case .apiKey:
            "Connect to your account"
        case .finish:
            "You are ready to capture"
        }
    }

    var subtitle: String {
        switch self {
        case .privacy:
            "Review exactly what the app can do before setup."
        case .shortcut:
            "The shortcut captures selected text into the local editor."
        case .apiKey:
            "Your API key lets submitted notes reach your knowzeno account."
        case .finish:
            "The everyday workflow is select, capture, review, then submit."
        }
    }

    var primaryButtonTitle: String {
        self == .finish ? "Finish Setup" : "Continue"
    }

    var progressText: String {
        let steps = Self.allCases
        let currentIndex = steps.firstIndex(of: self) ?? 0
        return "Step \(currentIndex + 1) of \(steps.count)"
    }

    var previous: OnboardingStep? {
        step(offset: -1)
    }

    var next: OnboardingStep? {
        step(offset: 1)
    }

    private func step(offset: Int) -> OnboardingStep? {
        let steps = Self.allCases
        guard let currentIndex = steps.firstIndex(of: self) else {
            return nil
        }

        let nextIndex = currentIndex + offset
        guard steps.indices.contains(nextIndex) else {
            return nil
        }

        return steps[nextIndex]
    }
}

private struct OnboardingHeader: View {
    let currentStep: OnboardingStep

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                KnowzenoLogoMark()
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Set Up knowzeno")
                        .font(.title2)
                        .bold()

                    Text(currentStep.progressText)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(currentStep.title)
                    .font(.title3)
                    .bold()

                Text(currentStep.subtitle)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct OnboardingDisclosureList: View {
    let statements: [OnboardingStatement]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(statements) { statement in
                OnboardingStatementRow(statement: statement)
            }
        }
    }
}

private struct OnboardingStatementRow: View {
    let statement: OnboardingStatement

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: statement.systemImage)
                .frame(width: 24)
                .foregroundStyle(Color.accentColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(statement.title)
                    .bold()

                Text(statement.detail)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    OnboardingView(settings: AppSettings())
}
