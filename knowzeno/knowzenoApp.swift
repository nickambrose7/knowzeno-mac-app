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
    }
}
