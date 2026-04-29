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
        @Bindable var capture = capture

        VStack(alignment: .leading, spacing: 16) {
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

            ZStack(alignment: .topLeading) {
                TextEditor(text: $capture.lastCapturedText)
                    .font(.body.monospaced())
                    .lineSpacing(4)
                    .padding(8)
                    .accessibilityLabel("Captured text editor")

                if capture.lastCapturedText.isEmpty {
                    Text("No captured text")
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 8)
                        .allowsHitTesting(false)
                }
            }
            .frame(minWidth: 420, minHeight: 220)
            .overlay {
                Rectangle()
                    .stroke(.quaternary)
            }

            HStack {
                Button("Clear Editor", systemImage: "trash") {
                    capture.clearCapturedText()
                }

                Spacer()

                Button("Send text to server", systemImage: "paperplane") {
                    print("Send text to the server")
                }
            }
        }
        .padding(24)
    }
}

#Preview {
    ContentView(capture: SelectedTextCapture(), settings: AppSettings())
}
