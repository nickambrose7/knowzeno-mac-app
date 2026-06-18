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
    @Test func makeLearningItemsRequestBuildsFlaskListRequest() throws {
        let request = try SourceNoteAPIClient.makeLearningItemsRequest(
            baseURLString: "https://api.example.com",
            apiKey: "test-token",
            limit: .fifty
        )

        #expect(request.url?.absoluteString == "https://api.example.com/api/source-note/learning-items?limit=50")
        #expect(request.httpMethod == "GET")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer test-token")
    }

    @MainActor
    @Test func makeDeleteLearningItemRequestBuildsFlaskDeleteRequest() throws {
        let learningItemID = try #require(UUID(uuidString: "0196b7f0-6c2f-7000-8000-000000000001"))

        let request = try SourceNoteAPIClient.makeDeleteLearningItemRequest(
            baseURLString: "https://api.example.com",
            apiKey: "test-token",
            id: learningItemID
        )

        #expect(request.url?.absoluteString == "https://api.example.com/api/source-note/learning-items/0196B7F0-6C2F-7000-8000-000000000001")
        #expect(request.httpMethod == "DELETE")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer test-token")
    }

    @MainActor
    @Test func makeUpdateLearningItemRequestBuildsFlaskPatchRequest() throws {
        let learningItemID = try #require(UUID(uuidString: "0196b7f0-6c2f-7000-8000-000000000001"))

        let request = try SourceNoteAPIClient.makeUpdateLearningItemRequest(
            baseURLString: "https://api.example.com",
            apiKey: "test-token",
            id: learningItemID,
            title: "Updated title",
            summary: "Updated summary."
        )

        #expect(request.url?.absoluteString == "https://api.example.com/api/source-note/learning-items/0196B7F0-6C2F-7000-8000-000000000001")
        #expect(request.httpMethod == "PATCH")
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer test-token")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")

        let body = try #require(request.httpBody)
        let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: String])
        #expect(json == ["title": "Updated title", "summary": "Updated summary."])
    }

    @MainActor
    @Test func makeLifecycleRequestBuildsFlaskArchiveAndUnarchiveRequests() throws {
        let learningItemID = try #require(UUID(uuidString: "0196b7f0-6c2f-7000-8000-000000000001"))

        let archiveRequest = try SourceNoteAPIClient.makeLifecycleRequest(
            baseURLString: "https://api.example.com",
            apiKey: "test-token",
            id: learningItemID,
            action: .archive
        )
        let unarchiveRequest = try SourceNoteAPIClient.makeLifecycleRequest(
            baseURLString: "https://api.example.com",
            apiKey: "test-token",
            id: learningItemID,
            action: .unarchive
        )

        #expect(archiveRequest.url?.absoluteString == "https://api.example.com/api/source-note/learning-items/0196B7F0-6C2F-7000-8000-000000000001/archive")
        #expect(unarchiveRequest.url?.absoluteString == "https://api.example.com/api/source-note/learning-items/0196B7F0-6C2F-7000-8000-000000000001/unarchive")
        #expect(archiveRequest.httpMethod == "POST")
        #expect(unarchiveRequest.httpMethod == "POST")
        #expect(archiveRequest.value(forHTTPHeaderField: "Authorization") == "Bearer test-token")
        #expect(unarchiveRequest.value(forHTTPHeaderField: "Authorization") == "Bearer test-token")
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
    @Test func responseMessageDecodesServerErrorMessage() throws {
        let data = Data(#"{"error":{"message":"Learning item not found.","code":"NotFoundError"}}"#.utf8)

        let message = try SourceNoteAPIClient.responseMessage(from: data)

        #expect(message == "Learning item not found.")
    }

    @MainActor
    @Test func learningItemsResponseDecodesRepeatedSourceNotes() throws {
        let data = Data(
            """
            {
              "items": [
                {
                  "learning_item_id": "0196b7f0-6c2f-7000-8000-000000000001",
                  "learning_item_title": "First title",
                  "learning_item_summary": "First summary.",
                  "learning_item_lifecycle_state": "active",
                  "learning_item_created_at": "2026-05-03T09:00:00+00:00",
                  "source_note_id": "0196b7f0-6c2f-7000-8000-000000000010",
                  "source_note_text": "Shared source note.",
                  "source_note_created_at": "2026-05-01T09:00:00+00:00"
                },
                {
                  "learning_item_id": "0196b7f0-6c2f-7000-8000-000000000002",
                  "learning_item_title": "Second title",
                  "learning_item_summary": "Second summary.",
                  "learning_item_lifecycle_state": "archived",
                  "learning_item_created_at": "2026-05-02T09:00:00+00:00",
                  "source_note_id": "0196b7f0-6c2f-7000-8000-000000000010",
                  "source_note_text": "Shared source note.",
                  "source_note_created_at": "2026-05-01T09:00:00+00:00"
                }
              ]
            }
            """.utf8
        )

        let response = try SourceNoteAPIClient.learningItemsResponse(from: data)

        #expect(response.items.count == 2)
        #expect(response.items[0].learningItemTitle == "First title")
        #expect(response.items[0].learningItemSummary == "First summary.")
        #expect(response.items[0].learningItemLifecycleState == .active)
        #expect(response.items[1].learningItemLifecycleState == .archived)
        #expect(response.items[1].sourceNoteID == response.items[0].sourceNoteID)
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
