//
//  InMemoryAPIKeyStore.swift
//  knowzenoTests
//

@testable import knowzeno

final class InMemoryAPIKeyStore: APIKeyStoring {
    var apiKey: String?

    func loadAPIKey() throws -> String? {
        apiKey
    }

    func saveAPIKey(_ apiKey: String) throws {
        self.apiKey = apiKey
    }

    func deleteAPIKey() throws {
        apiKey = nil
    }
}
