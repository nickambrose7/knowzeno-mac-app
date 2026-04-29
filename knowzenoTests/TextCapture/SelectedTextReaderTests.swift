//
//  SelectedTextReaderTests.swift
//  knowzenoTests
//

import Foundation
import Testing
@testable import knowzeno

struct SelectedTextReaderTests {

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
