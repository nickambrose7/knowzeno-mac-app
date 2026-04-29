//
//  ContentView.swift
//  knowzeno
//
//  Created by Nick Ambrose on 4/26/26.
//

import SwiftUI

struct ContentView: View {
    let capture: SelectedTextCapture
    let settings: AppSettings

    var body: some View {
        VStack(alignment: .leading) {
            Label {
                Text("knowzeno")
                    .font(.title2)
                    .bold()
            } icon: {
                Image(systemName: "text.viewfinder")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
            }

            Text(capture.statusMessage)
                .foregroundStyle(.secondary)

            Text("Global shortcut: \(settings.globalShortcut.displayText)")
                .foregroundStyle(.secondary)

            Button("Capture Selected Text", systemImage: "text.viewfinder") {
                capture.captureSelectedText(initiatingShortcut: settings.globalShortcut)
            }

            ScrollView {
                if capture.lastCapturedText.isEmpty {
                    ContentUnavailableView("No captured text", systemImage: "text.viewfinder")
                } else {
                    Text(capture.lastCapturedText)
                        .font(.body.monospaced())
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(minWidth: 420, minHeight: 220)
            .border(.quaternary)
            .accessibilityLabel("Last captured selected text")
        }
        .padding(24)
    }
}

#Preview {
    ContentView(capture: SelectedTextCapture(), settings: AppSettings())
}
