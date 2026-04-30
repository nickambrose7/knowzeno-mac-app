//
//  SourceNoteAPIClientTests.swift
//  knowzenoTests
//

import Foundation
import Testing
@testable import knowzeno

struct SourceNoteAPIClientTests {
    @MainActor
    @Test func makeRequestBuildsFlaskCreateSourceNoteRequest() throws {
        let request = try SourceNoteAPIClient.makeRequest(
            baseURLString: "https://api.example.com",
            apiKey: "test-token",
            text: "Captured text"
        )

        #expect(request.url?.absoluteString == "https://api.example.com/api/source-notes")
        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer test-token")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")

        let body = try #require(request.httpBody)
        let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: String])
        #expect(json == ["text": "Captured text"])
    }

    @MainActor
    @Test func makeRequestAllowsLocalHTTPDevelopmentServer() throws {
        let request = try SourceNoteAPIClient.makeRequest(
            baseURLString: "http://127.0.0.1:5000",
            apiKey: "test-token",
            text: "Captured text"
        )

        #expect(request.url?.absoluteString == "http://127.0.0.1:5000/api/source-notes")
    }

    @MainActor
    @Test func makeRequestRejectsInvalidBaseURL() {
        #expect(throws: SourceNoteAPIClient.APIError.invalidBaseURL) {
            try SourceNoteAPIClient.makeRequest(
                baseURLString: "not a url",
                apiKey: "test-token",
                text: "Captured text"
            )
        }
    }
}
