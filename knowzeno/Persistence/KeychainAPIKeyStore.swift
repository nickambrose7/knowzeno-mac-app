//
//  KeychainAPIKeyStore.swift
//  knowzeno
//

import Foundation
import Security

struct KeychainAPIKeyStore: APIKeyStoring {
    enum KeychainError: LocalizedError {
        case unexpectedStatus(OSStatus)
        case invalidStoredData

        var errorDescription: String? {
            switch self {
            case .unexpectedStatus(let status):
                "Keychain returned status \(status)."
            case .invalidStoredData:
                "The saved API key could not be read from Keychain."
            }
        }
    }

    private let service = "com.knowzeno.knowzeno"
    private let account = "apiKey"

    func loadAPIKey() throws -> String? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }

        guard let data = result as? Data,
              let apiKey = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidStoredData
        }

        return apiKey
    }

    func saveAPIKey(_ apiKey: String) throws {
        let data = Data(apiKey.utf8)

        if try loadAPIKey() != nil {
            let attributes = [kSecValueData as String: data]
            let status = SecItemUpdate(baseQuery as CFDictionary, attributes as CFDictionary)

            guard status == errSecSuccess else {
                throw KeychainError.unexpectedStatus(status)
            }
        } else {
            var query = baseQuery
            query[kSecValueData as String] = data
            query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

            let status = SecItemAdd(query as CFDictionary, nil)
            guard status == errSecSuccess else {
                throw KeychainError.unexpectedStatus(status)
            }
        }
    }

    func deleteAPIKey() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
