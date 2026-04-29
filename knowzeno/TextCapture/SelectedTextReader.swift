//
//  SelectedTextReader.swift
//  knowzeno
//

import AppKit
import ApplicationServices

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

    static func readSelectedText(initiatingShortcut: GlobalKeyboardShortcut) -> Result<String, Error> {
        guard accessibilityPermissionIsGranted() else {
            return .failure(CaptureError.accessibilityPermissionMissing)
        }

        let pasteboard = NSPasteboard.general
        let snapshot = PasteboardSnapshot(pasteboard: pasteboard)
        let marker = "knowzeno-pasteboard-marker-\(UUID().uuidString)"

        pasteboard.clearContents()
        pasteboard.setString(marker, forType: .string)
        let markerChangeCount = pasteboard.changeCount

        sendCopyShortcut(initiatingShortcut: initiatingShortcut)

        let deadline = Date.now.addingTimeInterval(1.5)
        while pasteboard.changeCount == markerChangeCount && Date.now < deadline {
            RunLoop.current.run(mode: .default, before: Date.now.addingTimeInterval(0.02))
        }

        let copiedText = pasteboard.string(forType: .string)
        snapshot.restore(to: pasteboard)

        guard copiedText != marker else {
            return .failure(CaptureError.copyDidNotReachPasteboard)
        }

        return .success(copiedText ?? "")
    }

    private static func accessibilityPermissionIsGranted() -> Bool {
        let options = ["AXTrustedCheckOptionPrompt": true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    private static func sendCopyShortcut(initiatingShortcut: GlobalKeyboardShortcut) {
        waitForHotKeyModifiersToClear(initiatingShortcut: initiatingShortcut)

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

    private static func waitForHotKeyModifiersToClear(initiatingShortcut: GlobalKeyboardShortcut) {
        let shortcutModifiers = initiatingShortcut.modifiers.cgEventFlags
        let deadline = Date.now.addingTimeInterval(0.8)

        guard shortcutModifiers.isEmpty == false else {
            return
        }

        while Date.now < deadline {
            let pressedModifiers = CGEventSource.flagsState(.hidSystemState).intersection(shortcutModifiers)
            if pressedModifiers.isEmpty {
                return
            }

            RunLoop.current.run(mode: .default, before: Date.now.addingTimeInterval(0.02))
        }
    }
}
