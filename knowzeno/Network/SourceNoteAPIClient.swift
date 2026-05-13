//
//  SourceNoteAPIClient.swift
//  knowzeno
//

import Foundation

struct SourceNoteAPIClient {
    enum APIError: Equatable, LocalizedError {
        case invalidBaseURL
        case invalidResponse
        case requestFailed(message: String, statusCode: Int)

        var errorDescription: String? {
            switch self {
            case .invalidBaseURL:
                "Enter a valid HTTP or HTTPS server URL."
            case .invalidResponse:
                "The server returned an invalid response."
            case .requestFailed(let message, _):
                message
            }
        }
    }

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func createSourceNote(text: String, apiKey: String, serverBaseURL: String) async throws -> String {
        let request = try Self.makeRequest(
            baseURLString: serverBaseURL,
            apiKey: apiKey,
            text: text
        )
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        let message = try Self.responseMessage(from: data)

        guard httpResponse.statusCode == 202 else {
            throw APIError.requestFailed(message: message, statusCode: httpResponse.statusCode)
        }

        return message
    }

    func learningItems(
        limit: LearningItemLimit,
        apiKey: String,
        serverBaseURL: String
    ) async throws -> [RecentLearningItemPair] {
        let request = try Self.makeLearningItemsRequest(
            baseURLString: serverBaseURL,
            apiKey: apiKey,
            limit: limit
        )
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let message = try Self.responseMessage(from: data)
            throw APIError.requestFailed(message: message, statusCode: httpResponse.statusCode)
        }

        return try Self.learningItemsResponse(from: data).items
    }

    func deleteLearningItem(
        id: UUID,
        apiKey: String,
        serverBaseURL: String
    ) async throws {
        let request = try Self.makeDeleteLearningItemRequest(
            baseURLString: serverBaseURL,
            apiKey: apiKey,
            id: id
        )
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 204 else {
            let message = try Self.responseMessage(from: data)
            throw APIError.requestFailed(message: message, statusCode: httpResponse.statusCode)
        }
    }

    static func makeRequest(baseURLString: String, apiKey: String, text: String) throws -> URLRequest {
        guard let baseURL = URL.validServerBaseURL(from: baseURLString) else {
            throw APIError.invalidBaseURL
        }

        var request = URLRequest(url: baseURL.appending(path: "api/source-note/create"))
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(SourceNoteCreateRequest(text: text))
        return request
    }

    static func makeLearningItemsRequest(
        baseURLString: String,
        apiKey: String,
        limit: LearningItemLimit
    ) throws -> URLRequest {
        guard let baseURL = URL.validServerBaseURL(from: baseURLString),
              var components = URLComponents(
                url: baseURL.appending(path: "api/source-note/learning-items"),
                resolvingAgainstBaseURL: false
              ) else {
            throw APIError.invalidBaseURL
        }

        components.queryItems = [
            URLQueryItem(name: "limit", value: String(limit.rawValue)),
        ]

        guard let url = components.url else {
            throw APIError.invalidBaseURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        return request
    }

    static func makeDeleteLearningItemRequest(
        baseURLString: String,
        apiKey: String,
        id: UUID
    ) throws -> URLRequest {
        guard let baseURL = URL.validServerBaseURL(from: baseURLString) else {
            throw APIError.invalidBaseURL
        }

        var request = URLRequest(
            url: baseURL.appending(path: "api/source-note/learning-items/\(id.uuidString)")
        )
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        return request
    }

    static func responseMessage(from data: Data) throws -> String {
        if let response = try? JSONDecoder().decode(ServerMessageResponse.self, from: data) {
            return response.message
        }

        if let response = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
            return response.error.message
        }

        throw APIError.invalidResponse
    }

    static func learningItemsResponse(from data: Data) throws -> RecentLearningItemsResponse {
        try JSONDecoder().decode(RecentLearningItemsResponse.self, from: data)
    }
}

private struct SourceNoteCreateRequest: Encodable {
    let text: String
}

private struct ServerMessageResponse: Decodable {
    let message: String
}

private struct ServerErrorResponse: Decodable {
    let error: ServerError
}

private struct ServerError: Decodable {
    let message: String
}

enum LearningItemLimit: Int, CaseIterable, Identifiable {
    case twenty = 20
    case fifty = 50
    case oneHundred = 100

    var id: Int {
        rawValue
    }

    var label: String {
        "\(rawValue)"
    }
}

struct RecentLearningItemsResponse: Decodable, Equatable {
    let items: [RecentLearningItemPair]
}

struct RecentLearningItemPair: Decodable, Equatable, Identifiable {
    let learningItemID: UUID
    let learningItemSummary: String
    let learningItemCreatedAt: String
    let sourceNoteID: UUID
    let sourceNoteText: String
    let sourceNoteCreatedAt: String

    var id: UUID {
        learningItemID
    }

    private enum CodingKeys: String, CodingKey {
        case learningItemID = "learning_item_id"
        case learningItemSummary = "learning_item_summary"
        case learningItemCreatedAt = "learning_item_created_at"
        case sourceNoteID = "source_note_id"
        case sourceNoteText = "source_note_text"
        case sourceNoteCreatedAt = "source_note_created_at"
    }
}

extension URL {
    static func validServerBaseURL(from string: String) -> URL? {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let url = URL(string: trimmedString),
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              url.host?.isEmpty == false else {
            return nil
        }

        return url
    }
}
