//
//  AppSettings.swift
//  knowzeno
//

import Foundation
import Observation

@MainActor
@Observable
final class AppSettings {
    private enum DefaultsKey {
        static let globalShortcut = "globalShortcut"
        static let hasFinishedOnboarding = "hasFinishedOnboarding"
    }

    private let apiKeyStore: APIKeyStoring
    private let userDefaults: UserDefaults

    private(set) var apiKey = ""
    private(set) var globalShortcut: GlobalKeyboardShortcut
    private(set) var hasFinishedOnboarding: Bool
    var hotKeyStatusMessage = ""
    var settingsErrorMessage: String?

    var hasCompletedOnboarding: Bool {
        hasFinishedOnboarding && apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && globalShortcut.isValid
    }

    init(apiKeyStore: APIKeyStoring = KeychainAPIKeyStore(), userDefaults: UserDefaults = .standard) {
        self.apiKeyStore = apiKeyStore
        self.userDefaults = userDefaults
        globalShortcut = Self.loadShortcut(from: userDefaults)
        hasFinishedOnboarding = userDefaults.bool(forKey: DefaultsKey.hasFinishedOnboarding)
        reloadAPIKey()
    }

    func saveAPIKey(_ newAPIKey: String) {
        let trimmedKey = newAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            if trimmedKey.isEmpty {
                try apiKeyStore.deleteAPIKey()
            } else {
                try apiKeyStore.saveAPIKey(trimmedKey)
            }

            apiKey = trimmedKey
            settingsErrorMessage = nil
        } catch {
            settingsErrorMessage = error.localizedDescription
        }
    }

    func saveShortcut(_ shortcut: GlobalKeyboardShortcut) {
        globalShortcut = shortcut
        persistShortcut(shortcut)
    }

    func restoreRegisteredShortcut(_ shortcut: GlobalKeyboardShortcut) {
        globalShortcut = shortcut
        persistShortcut(shortcut)
    }

    func completeOnboarding(apiKey: String, shortcut: GlobalKeyboardShortcut) {
        saveAPIKey(apiKey)
        guard settingsErrorMessage == nil else {
            return
        }

        saveShortcut(shortcut)
        guard settingsErrorMessage == nil else {
            return
        }

        hasFinishedOnboarding = true
        userDefaults.set(true, forKey: DefaultsKey.hasFinishedOnboarding)
    }

    func showOnboardingAgain() {
        hasFinishedOnboarding = false
        userDefaults.set(false, forKey: DefaultsKey.hasFinishedOnboarding)
    }

    private func reloadAPIKey() {
        do {
            apiKey = try apiKeyStore.loadAPIKey() ?? ""
            settingsErrorMessage = nil
        } catch {
            apiKey = ""
            settingsErrorMessage = error.localizedDescription
        }
    }

    private func persistShortcut(_ shortcut: GlobalKeyboardShortcut) {
        do {
            let data = try JSONEncoder().encode(shortcut)
            userDefaults.set(data, forKey: DefaultsKey.globalShortcut)
            settingsErrorMessage = nil
        } catch {
            settingsErrorMessage = error.localizedDescription
        }
    }

    private static func loadShortcut(from userDefaults: UserDefaults) -> GlobalKeyboardShortcut {
        guard let data = userDefaults.data(forKey: DefaultsKey.globalShortcut),
              let shortcut = try? JSONDecoder().decode(GlobalKeyboardShortcut.self, from: data),
              shortcut.isValid else {
            return .default
        }

        return shortcut
    }
}
