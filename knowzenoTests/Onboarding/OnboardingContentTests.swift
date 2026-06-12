//
//  OnboardingContentTests.swift
//  knowzenoTests
//

import Foundation
import Testing
@testable import knowzeno

@MainActor
struct OnboardingContentTests {
    @Test func privacyDisclosuresExplainUserSelectedTextOnly() {
        let disclosureText = Self.combinedText(from: OnboardingContent.privacyStatements)

        #expect(disclosureText.localizedStandardContains("only with text you selected"))
        #expect(disclosureText.localizedStandardContains("does not read your screen"))
        #expect(disclosureText.localizedStandardContains("monitor your typing") == true)
        #expect(disclosureText.localizedStandardContains("scan documents on its own") == true)
    }

    @Test func privacyDisclosuresExplainUserTriggeredCaptureOnly() {
        let disclosureText = Self.combinedText(from: OnboardingContent.privacyStatements)

        #expect(disclosureText.localizedStandardContains("only when you press your shortcut"))
        #expect(disclosureText.localizedStandardContains("choose Send Selected Text to knowzeno"))
    }

    @Test func privacyDisclosuresExplainBackendSubmissionOnlyAfterSend() {
        let disclosureText = Self.combinedText(from: OnboardingContent.privacyStatements)

        #expect(disclosureText.localizedStandardContains("Nothing is sent to the backend during capture"))
        #expect(disclosureText.localizedStandardContains("only after you press Send text to server"))
        #expect(disclosureText.localizedStandardContains("create source notes and learning notes"))
    }

    @Test func workflowShowsBasicAppUsage() {
        let workflowText = Self.combinedText(from: OnboardingContent.workflowStatements)

        #expect(workflowText.localizedStandardContains("Select text"))
        #expect(workflowText.localizedStandardContains("Capture it"))
        #expect(workflowText.localizedStandardContains("Review before sending"))
        #expect(workflowText.localizedStandardContains("Library tab"))
        #expect(workflowText.localizedStandardContains("delete accidental items"))
    }

    private static func combinedText(from statements: [OnboardingStatement]) -> String {
        statements
            .map { "\($0.title) \($0.detail)" }
            .joined(separator: " ")
    }
}
