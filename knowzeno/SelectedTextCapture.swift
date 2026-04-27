//
//  SelectedTextCapture.swift
//  knowzeno
//

import AppKit
import ApplicationServices
import Combine
import SwiftUI

@MainActor
final class SelectedTextCapture: ObservableObject {
    @Published private(set) var lastCapturedText = ""
    @Published private(set) var statusMessage = "Select text in another app, then press Control-Option-Command-K."

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

@MainActor
enum SelectedTextReader {
    enum CaptureError: LocalizedError {
        case accessibilityPermissionMissing
        case copyDidNotReachPasteboard

        var errorDescription: String? {
            switch self {
            case .accessibilityPermissionMissing:
                "Accessibility permission is required so knowzeno can send Command-C to the active app."
            case .copyDidNotReachPasteboard:
                "Copy did not update the pasteboard. Make sure text is selected in the active app."
            }
        }
    }

    static func readSelectedText() -> Result<String, Error> {
        guard accessibilityPermissionIsGranted() else {
            return .failure(CaptureError.accessibilityPermissionMissing)
        }

        let pasteboard = NSPasteboard.general
        let snapshot = PasteboardSnapshot(pasteboard: pasteboard)
        let marker = "knowzeno-pasteboard-marker-\(UUID().uuidString)"

        pasteboard.clearContents()
        pasteboard.setString(marker, forType: .string)
        let markerChangeCount = pasteboard.changeCount

        sendCopyShortcut()

        let deadline = Date().addingTimeInterval(1.5)
        while pasteboard.changeCount == markerChangeCount && Date() < deadline {
            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.02))
        }

        let copiedText = pasteboard.string(forType: .string)
        snapshot.restore(to: pasteboard)

        guard copiedText != marker else {
            return .failure(CaptureError.copyDidNotReachPasteboard)
        }

        return .success(copiedText ?? "")
    }

    private static func accessibilityPermissionIsGranted() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    private static func sendCopyShortcut() {
        waitForHotKeyModifiersToClear()

        let source = CGEventSource(stateID: .hidSystemState)
        let keyCodeForC = CGKeyCode(8)
        let flags: CGEventFlags = .maskCommand

        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCodeForC, keyDown: true)
        keyDown?.flags = flags
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCodeForC, keyDown: false)
        keyUp?.flags = flags

        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }

    private static func waitForHotKeyModifiersToClear() {
        let shortcutModifiers: CGEventFlags = [.maskCommand, .maskAlternate, .maskControl]
        let deadline = Date().addingTimeInterval(0.8)

        while Date() < deadline {
            let pressedModifiers = CGEventSource.flagsState(.hidSystemState).intersection(shortcutModifiers)
            if pressedModifiers.isEmpty {
                return
            }

            RunLoop.current.run(mode: .default, before: Date().addingTimeInterval(0.02))
        }
    }
}

@MainActor
private struct PasteboardSnapshot {
    private let items: [PasteboardItemSnapshot]

    init(pasteboard: NSPasteboard) {
        items = pasteboard.pasteboardItems?.map(PasteboardItemSnapshot.init(item:)) ?? []
    }

    func restore(to pasteboard: NSPasteboard) {
        pasteboard.clearContents()
        pasteboard.writeObjects(items.map(\.pasteboardItem))
    }
}

@MainActor
private struct PasteboardItemSnapshot {
    private let valuesByType: [(NSPasteboard.PasteboardType, Data)]

    init(item: NSPasteboardItem) {
        valuesByType = item.types.compactMap { type in
            guard let data = item.data(forType: type) else {
                return nil
            }

            return (type, data)
        }
    }

    var pasteboardItem: NSPasteboardItem {
        let item = NSPasteboardItem()
        for (type, data) in valuesByType {
            item.setData(data, forType: type)
        }
        return item
    }
}
