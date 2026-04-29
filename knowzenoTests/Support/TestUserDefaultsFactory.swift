//
//  TestUserDefaultsFactory.swift
//  knowzenoTests
//

import Foundation

enum TestUserDefaultsFactory {
    static func make() -> UserDefaults {
        let suiteName = "knowzenoTests-\(UUID().uuidString)"

        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            fatalError("Could not create isolated test user defaults.")
        }

        userDefaults.removePersistentDomain(forName: suiteName)
        return userDefaults
    }
}
