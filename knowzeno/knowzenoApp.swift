//
//  knowzenoApp.swift
//  knowzeno
//
//  Created by Nick Ambrose on 4/26/26.
//

import SwiftUI

@main
struct knowzenoApp: App {
    @State private var capture = SelectedTextCapture()
    @State private var activeApplicationTracker = ActiveApplicationTracker()
    @State private var hotKeyManager: HotKeyManager?

    var body: some Scene {
        WindowGroup {
            ContentView(capture: capture)
                .task(registerHotKey)
        }

        MenuBarExtra("knowzeno", systemImage: "text.viewfinder") {
            Button("Send Selected Text to knowzeno") {
                captureFromMenuBar()
            }

            Divider()

            Button("Show knowzeno") {
                NSApp.activate(ignoringOtherApps: true)
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
            capture.captureSelectedText()
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func registerHotKey() async {
        guard hotKeyManager == nil else {
            return
        }

        let manager = HotKeyManager {
            capture.captureSelectedText()
        }
        manager.register()
        hotKeyManager = manager
    }
}
