//
//  SourceNoteAPIClient.swift
//  knowzeno
//

import Foundation

struct SourceNoteAPIClient {
    enum APIError: Equatable, LocalizedError {
        case invalidBaseURL
        case invalidResponse
        case requestFailed(statusCode: Int)

        var errorDescription: String? {
            switch self {
            case .invalidBaseURL:
                "Enter a valid HTTP or HTTPS server URL."
            case .invalidResponse:
                "The server returned an invalid response."
            case .requestFailed(let statusCode):
                "The server rejected the source note with status \(statusCode)."
            }
        }
    }

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func createSourceNote(text: String, apiKey: String, serverBaseURL: String) async throws {
        let request = try Self.makeRequest(
            baseURLString: serverBaseURL,
            apiKey: apiKey,
            text: text
        )
        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 202 else {
            throw APIError.requestFailed(statusCode: httpResponse.statusCode)
        }
    }

    static func makeRequest(baseURLString: String, apiKey: String, text: String) throws -> URLRequest {
        guard let baseURL = URL.validServerBaseURL(from: baseURLString) else {
            throw APIError.invalidBaseURL
        }

        var request = URLRequest(url: baseURL.appending(path: "api/source-notes"))
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(SourceNoteCreateRequest(text: text))
        return request
    }
}

private struct SourceNoteCreateRequest: Encodable {
    let text: String
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
