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
        #expect(capture.statusMessage == "Select text in another app, then use the configured shortcut.")
    }
}
