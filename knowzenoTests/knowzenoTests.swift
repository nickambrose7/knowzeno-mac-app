//
//  knowzenoTests.swift
//  knowzenoTests
//
//  Created by Nick Ambrose on 4/26/26.
//

import Foundation
import Testing
@testable import knowzeno

struct knowzenoTests {

    @MainActor
    @Test func selectedTextCaptureStartsWithEmptyState() {
        let capture = SelectedTextCapture()

        #expect(capture.lastCapturedText.isEmpty)
        #expect(capture.statusMessage == "Select text in another app, then press Control-Option-Command-K.")
    }

    @MainActor
    @Test func selectedTextReaderErrorsDescribeUserAction() throws {
        let permissionError = SelectedTextReader.CaptureError.accessibilityPermissionMissing
        let pasteboardError = SelectedTextReader.CaptureError.copyDidNotReachPasteboard
        let permissionDescription = try #require(permissionError.errorDescription)
        let pasteboardDescription = try #require(pasteboardError.errorDescription)

        #expect(permissionDescription.localizedStandardContains("accessibility permission"))
        #expect(pasteboardDescription.localizedStandardContains("text is selected"))
    }
}
