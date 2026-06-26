//
//  knowzenoApp.swift
//  knowzeno
//
//  Created by Nick Ambrose on 4/26/26.
//

import SwiftUI

@main
struct knowzenoApp: App {
    @Environment(\.openWindow) private var openWindow
    @State private var capture = SelectedTextCapture()
    @State private var navigation = AppNavigation()
    @State private var activeApplicationTracker = ActiveApplicationTracker()
    @State private var settings = AppSettings()
    @State private var hotKeyManager: HotKeyManager?
    @State private var softwareUpdateController = SoftwareUpdateController()
    @State private var isRestoringRegisteredShortcut = false

    var body: some Scene {
        Window("knowzeno", id: AppWindow.main) {
            Group {
                if settings.hasCompletedOnboarding {
                    ContentView(capture: capture, settings: settings, navigation: navigation)
                } else {
                    OnboardingView(settings: settings)
                }
            }
            .task {
                registerHotKey()
            }
            .onChange(of: settings.hasCompletedOnboarding) { _, isComplete in
                if isComplete {
                    registerHotKey()
                } else {
                    unregisterHotKey()
                }
            }
            .onChange(of: settings.globalShortcut) { _, newShortcut in
                if isRestoringRegisteredShortcut {
                    isRestoringRegisteredShortcut = false
                    return
                }

                registerHotKey(newShortcut)
            }
        }

        Settings {
            SettingsView(settings: settings)
        }
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Check for Updates...") {
                    softwareUpdateController.checkForUpdates()
                }
            }

            CommandGroup(after: .help) {
                Button("Show Onboarding") {
                    settings.showOnboardingAgain()
                    showMainWindow()
                }
            }
        }

        MenuBarExtra("knowzeno", systemImage: "text.viewfinder") {
            Button("Send Selected Text to knowzeno") {
                captureFromMenuBar()
            }
            .disabled(settings.hasCompletedOnboarding == false)

            Divider()

            Button("Show knowzeno") {
                showMainWindow()
            }

            Button("Quit knowzeno") {
                NSApp.terminate(nil)
            }
        }
    }

    private func captureFromMenuBar() {
        activeApplicationTracker.reactivateLastExternalApplication()

        Task {
            try? await Task.sleep(for: .milliseconds(250))
            capture.captureSelectedText(initiatingShortcut: settings.globalShortcut)
            showMainWindow(focusingSendButton: true)
        }
    }

    private func registerHotKey() {
        registerHotKey(settings.globalShortcut)
    }

    private func unregisterHotKey() {
        hotKeyManager?.unregister()
        settings.hotKeyStatusMessage = ""
    }

    private func registerHotKey(_ shortcut: GlobalKeyboardShortcut) {
        guard settings.hasCompletedOnboarding else {
            return
        }

        let manager: HotKeyManager
        if let hotKeyManager {
            manager = hotKeyManager
        } else {
            manager = HotKeyManager {
                capture.captureSelectedText(initiatingShortcut: settings.globalShortcut)
                showMainWindow(focusingSendButton: true)
            }
            hotKeyManager = manager
        }

        do {
            try manager.register(shortcut)
            settings.hotKeyStatusMessage = "Global shortcut registered as \(shortcut.displayText)."
        } catch {
            settings.hotKeyStatusMessage = error.localizedDescription

            if let registeredShortcut = manager.registeredShortcut {
                isRestoringRegisteredShortcut = true
                settings.restoreRegisteredShortcut(registeredShortcut)
            }
        }
    }

    private func showMainWindow(focusingSendButton: Bool = false) {
        if focusingSendButton {
            navigation.showCapture()
        }

        openWindow(id: AppWindow.main)
        NSApp.activate(ignoringOtherApps: true)

        if focusingSendButton {
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(100))
                capture.requestSendButtonFocus()
            }
        }
    }
}

private enum AppWindow {
    static let main = "main"
}
