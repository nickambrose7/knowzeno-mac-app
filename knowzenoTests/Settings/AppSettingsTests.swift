//
//  AppSettingsTests.swift
//  knowzenoTests
//

import Carbon
import Testing
@testable import knowzeno

struct AppSettingsTests {

    @MainActor
    @Test func shortcutPersistenceRoundTripsThroughUserDefaults() {
        let userDefaults = TestUserDefaultsFactory.make()
        let store = InMemoryAPIKeyStore()
        let firstSettings = AppSettings(apiKeyStore: store, userDefaults: userDefaults)
        let shortcut = GlobalKeyboardShortcut(
            keyCode: UInt32(kVK_ANSI_P),
            keyDisplayName: "P",
            modifiers: [.control, .option, .shift]
        )

        firstSettings.saveShortcut(shortcut)
        let secondSettings = AppSettings(apiKeyStore: store, userDefaults: userDefaults)

        #expect(secondSettings.globalShortcut == shortcut)
        #expect(secondSettings.globalShortcut.displayText == "Control-Option-Shift-P")
    }

    @MainActor
    @Test func onboardingRequiresAPIKeyAndShortcut() {
        let settings = AppSettings(
            apiKeyStore: InMemoryAPIKeyStore(),
            userDefaults: TestUserDefaultsFactory.make()
        )

        #expect(settings.hasCompletedOnboarding == false)

        settings.saveShortcut(.default)
        #expect(settings.hasCompletedOnboarding == false)

        settings.saveAPIKey("test-api-key")
        #expect(settings.hasCompletedOnboarding)
    }

    @MainActor
    @Test func clearingAPIKeyReturnsOnboardingToIncomplete() {
        let settings = AppSettings(
            apiKeyStore: InMemoryAPIKeyStore(),
            userDefaults: TestUserDefaultsFactory.make()
        )

        settings.saveAPIKey("test-api-key")
        settings.saveShortcut(.default)
        #expect(settings.hasCompletedOnboarding)

        settings.saveAPIKey("")
        #expect(settings.hasCompletedOnboarding == false)
    }
}
