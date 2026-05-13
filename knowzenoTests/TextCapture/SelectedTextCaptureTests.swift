//
//  SelectedTextCaptureTests.swift
//  knowzenoTests
//

import Testing
@testable import knowzeno

struct SelectedTextCaptureTests {

    @MainActor
    @Test func selectedTextCaptureStartsWithEmptyState() {
        let capture = SelectedTextCapture()

        #expect(capture.lastCapturedText.isEmpty)
        #expect(capture.textEditorFocusRequest == 0)
        #expect(capture.statusMessage == "Select text in another app, then use the configured shortcut.")
    }

    @MainActor
    @Test func textEditorFocusRequestChangesEveryTimeFocusIsRequested() {
        let capture = SelectedTextCapture()

        capture.requestTextEditorFocus()
        let firstRequest = capture.textEditorFocusRequest
        capture.requestTextEditorFocus()

        #expect(firstRequest == 1)
        #expect(capture.textEditorFocusRequest == 2)
    }

    @MainActor
    @Test func capturedTextAppendsToExistingEditorText() {
        let capture = SelectedTextCapture()

        capture.appendCapturedText("First source excerpt.")
        capture.appendCapturedText("Second source excerpt.")

        #expect(capture.lastCapturedText == "First source excerpt.\n\nSecond source excerpt.")
    }

    @MainActor
    @Test func clearCapturedTextRemovesEditorText() {
        let capture = SelectedTextCapture()

        capture.appendCapturedText("Source excerpt.")
        capture.clearCapturedText()

        #expect(capture.lastCapturedText.isEmpty)
        #expect(capture.statusMessage == "Editor cleared.")
    }
}
