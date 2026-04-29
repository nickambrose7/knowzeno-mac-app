//
//  APIKeyStoring.swift
//  knowzeno
//

protocol APIKeyStoring {
    func loadAPIKey() throws -> String?
    func saveAPIKey(_ apiKey: String) throws
    func deleteAPIKey() throws
}
