//
//  knowzenoApp.swift
//  knowzeno
//
//  Created by Nick Ambrose on 4/26/26.
//

import SwiftUI

@main
struct knowzenoApp: App {
    @StateObject private var capture = SelectedTextCapture()
    @StateObject private var activeApplicationTracker = ActiveApplicationTracker()
    @State private var hotKeyManager: HotKeyManager?

    var body: some Scene {
        WindowGroup {
            ContentView(capture: capture)
                .onAppear {
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

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            capture.captureSelectedText()
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
