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

        #expect(request.url?.absoluteString == "https://api.example.com/api/source-note/create")
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

        #expect(request.url?.absoluteString == "http://127.0.0.1:5000/api/source-note/create")
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

    @MainActor
    @Test func responseMessageDecodesServerMessage() throws {
        let data = Data(#"{"message":"Source note accepted. Learning item generation has started."}"#.utf8)

        let message = try SourceNoteAPIClient.responseMessage(from: data)

        #expect(message == "Source note accepted. Learning item generation has started.")
    }

    @MainActor
    @Test func requestFailedUsesServerMessageAsErrorDescription() throws {
        let error = SourceNoteAPIClient.APIError.requestFailed(
            message: "Invalid API token.",
            statusCode: 401
        )

        #expect(error.localizedDescription == "Invalid API token.")
    }
}
