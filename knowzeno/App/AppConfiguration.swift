//
//  AppConfiguration.swift
//  knowzeno
//

import Foundation

enum AppConfiguration {
    enum ConfigurationError: Equatable, LocalizedError {
        case missingServerBaseURL
        case invalidServerBaseURL

        var errorDescription: String? {
            switch self {
            case .missingServerBaseURL:
                "The source note server URL is not configured."
            case .invalidServerBaseURL:
                "The configured source note server URL is invalid."
            }
        }
    }

    static func sourceNoteServerBaseURL(bundle: Bundle = .main) throws -> String {
        try sourceNoteServerBaseURL(infoDictionary: bundle.infoDictionary ?? [:])
    }

    static func sourceNoteServerBaseURL(infoDictionary: [String: Any]) throws -> String {
        guard let serverBaseURL = infoDictionary["KnowzenoServerBaseURL"] as? String,
              serverBaseURL.isEmpty == false else {
            throw ConfigurationError.missingServerBaseURL
        }

        guard URL.validServerBaseURL(from: serverBaseURL) != nil else {
            throw ConfigurationError.invalidServerBaseURL
        }

        return serverBaseURL
    }
}
