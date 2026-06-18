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
