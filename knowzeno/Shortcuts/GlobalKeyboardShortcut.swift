//
//  GlobalKeyboardShortcut.swift
//  knowzeno
//

import AppKit
import Carbon

struct GlobalKeyboardShortcut: Codable, Equatable, Sendable {
    var keyCode: UInt32
    var keyDisplayName: String
    var modifiers: ShortcutModifiers

    static let `default` = GlobalKeyboardShortcut(
        keyCode: UInt32(kVK_ANSI_K),
        keyDisplayName: "K",
        modifiers: .defaultModifiers
    )

    var isValid: Bool {
        keyDisplayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    var displayText: String {
        (modifiers.displayComponents + [keyDisplayName]).joined(separator: "-")
    }

    init(keyCode: UInt32, keyDisplayName: String, modifiers: ShortcutModifiers) {
        self.keyCode = keyCode
        self.keyDisplayName = keyDisplayName
        self.modifiers = modifiers
    }

    init?(event: NSEvent) {
        guard event.type == .keyDown else {
            return nil
        }

        let displayName = Self.displayName(for: event)
        guard displayName.isEmpty == false else {
            return nil
        }

        keyCode = UInt32(event.keyCode)
        keyDisplayName = displayName
        modifiers = ShortcutModifiers(eventModifierFlags: event.modifierFlags)
    }

    private static func displayName(for event: NSEvent) -> String {
        if let namedKey = namedKeys[Int(event.keyCode)] {
            return namedKey
        }

        let characters = event.charactersIgnoringModifiers ?? event.characters ?? ""
        return characters.uppercased()
    }

    private static let namedKeys: [Int: String] = [
        kVK_Return: "Return",
        kVK_Tab: "Tab",
        kVK_Space: "Space",
        kVK_Delete: "Delete",
        kVK_Escape: "Escape",
        kVK_Command: "Command",
        kVK_Shift: "Shift",
        kVK_CapsLock: "Caps Lock",
        kVK_Option: "Option",
        kVK_Control: "Control",
        kVK_RightCommand: "Right Command",
        kVK_RightShift: "Right Shift",
        kVK_RightOption: "Right Option",
        kVK_RightControl: "Right Control",
        kVK_F1: "F1",
        kVK_F2: "F2",
        kVK_F3: "F3",
        kVK_F4: "F4",
        kVK_F5: "F5",
        kVK_F6: "F6",
        kVK_F7: "F7",
        kVK_F8: "F8",
        kVK_F9: "F9",
        kVK_F10: "F10",
        kVK_F11: "F11",
        kVK_F12: "F12",
        kVK_F13: "F13",
        kVK_F14: "F14",
        kVK_F15: "F15",
        kVK_F16: "F16",
        kVK_F17: "F17",
        kVK_F18: "F18",
        kVK_F19: "F19",
        kVK_F20: "F20",
        kVK_Home: "Home",
        kVK_End: "End",
        kVK_PageUp: "Page Up",
        kVK_PageDown: "Page Down",
        kVK_LeftArrow: "Left Arrow",
        kVK_RightArrow: "Right Arrow",
        kVK_DownArrow: "Down Arrow",
        kVK_UpArrow: "Up Arrow",
        kVK_ForwardDelete: "Forward Delete"
    ]
}
