//
//  ContentView.swift
//  knowzeno
//
//  Created by Nick Ambrose on 4/26/26.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var capture: SelectedTextCapture

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "text.viewfinder")
                    .imageScale(.large)
                    .foregroundStyle(.tint)

                Text("knowzeno")
                    .font(.title2)
                    .fontWeight(.semibold)
            }

            Text(capture.statusMessage)
                .foregroundStyle(.secondary)

            Button("Capture Selected Text") {
                capture.captureSelectedText()
            }
            .keyboardShortcut("k", modifiers: [.control, .option, .command])

            TextEditor(text: .constant(capture.lastCapturedText))
                .font(.body.monospaced())
                .frame(minWidth: 420, minHeight: 220)
                .border(.quaternary)
                .accessibilityLabel("Last captured selected text")
        }
        .padding(24)
    }
}

#Preview {
    ContentView(capture: SelectedTextCapture())
}
