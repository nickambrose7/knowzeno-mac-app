//
//  AppConfigurationTests.swift
//  knowzenoTests
//

import Testing
@testable import knowzeno

struct AppConfigurationTests {
    @MainActor
    @Test func sourceNoteServerBaseURLReadsValidInfoPlistValue() throws {
        let serverBaseURL = try AppConfiguration.sourceNoteServerBaseURL(
            infoDictionary: ["KnowzenoServerBaseURL": "https://api.example.com"]
        )

        #expect(serverBaseURL == "https://api.example.com")
    }

    @MainActor
    @Test func sourceNoteServerBaseURLRejectsMissingInfoPlistValue() {
        #expect(throws: AppConfiguration.ConfigurationError.missingServerBaseURL) {
            try AppConfiguration.sourceNoteServerBaseURL(infoDictionary: [:])
        }
    }

    @MainActor
    @Test func sourceNoteServerBaseURLRejectsInvalidInfoPlistValue() {
        #expect(throws: AppConfiguration.ConfigurationError.invalidServerBaseURL) {
            try AppConfiguration.sourceNoteServerBaseURL(
                infoDictionary: ["KnowzenoServerBaseURL": "not a url"]
            )
        }
    }
}
