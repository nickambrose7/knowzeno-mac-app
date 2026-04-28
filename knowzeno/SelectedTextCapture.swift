//
//  SelectedTextCapture.swift
//  knowzeno
//

import Foundation
import Observation

@MainActor
@Observable
final class SelectedTextCapture {
    private(set) var lastCapturedText = ""
    private(set) var statusMessage = "Select text in another app, then press Control-Option-Command-K."

    func captureSelectedText() {
        switch SelectedTextReader.readSelectedText() {
        case .success(let text) where !text.isEmpty:
            lastCapturedText = text
            statusMessage = "Captured \(text.count) characters."
            print("knowzeno captured selected text:")
            print(text)

        case .success:
            statusMessage = "No selected text was found."
            print("knowzeno captured selected text: <empty>")

        case .failure(let error):
            statusMessage = error.localizedDescription
            print("knowzeno failed to capture selected text: \(error.localizedDescription)")
        }
    }
}
