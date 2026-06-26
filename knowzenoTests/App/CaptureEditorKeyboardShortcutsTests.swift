//
//  CaptureEditorKeyboardShortcutsTests.swift
//  knowzenoTests
//

import Testing
@testable import knowzeno

struct CaptureEditorKeyboardShortcutsTests {

    @MainActor
    @Test func normalTabFocusesSendButtonWhenSendButtonIsEnabled() {
        let action = CaptureEditorKeyboardShortcuts.tabAction(
            sendButtonIsDisabled: false
        )

        #expect(action == .focusSendButton)
    }

    @MainActor
    @Test func normalTabIsConsumedWhenSendButtonIsDisabled() {
        let action = CaptureEditorKeyboardShortcuts.tabAction(
            sendButtonIsDisabled: true
        )

        #expect(action == .consume)
    }
}

struct SourceNoteTextLimitTests {

    @MainActor
    @Test func textAtCharacterLimitCanBeSent() {
        let text = String(repeating: "a", count: SourceNoteTextLimit.maxCharacterCount)

        #expect(SourceNoteTextLimit.canSend(text))
    }

    @MainActor
    @Test func textOverCharacterLimitCannotBeSent() {
        let text = String(repeating: "a", count: SourceNoteTextLimit.maxCharacterCount + 1)

        #expect(SourceNoteTextLimit.canSend(text) == false)
    }

    @MainActor
    @Test func contextWindowErrorsUseBreakUpNoteMessage() {
        let message = SourceNoteTextLimit.userFacingMessage(
            for: SourceNoteAPIClient.APIError.requestFailed(
                message: "This model's maximum context length was exceeded.",
                statusCode: 400
            )
        )

        #expect(message == SourceNoteTextLimit.errorMessage)
    }
}

struct AppNavigationTests {

    @MainActor
    @Test func showCaptureSelectsCaptureTab() {
        let navigation = AppNavigation()
        navigation.selectedTab = .library

        navigation.showCapture()

        #expect(navigation.selectedTab == .capture)
    }
}
