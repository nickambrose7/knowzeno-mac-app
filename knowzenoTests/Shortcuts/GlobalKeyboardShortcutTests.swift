//
//  GlobalKeyboardShortcutTests.swift
//  knowzenoTests
//

import Carbon
import Testing
@testable import knowzeno

struct GlobalKeyboardShortcutTests {

    @MainActor
    @Test func defaultShortcutUsesControlOptionK() {
        let shortcut = GlobalKeyboardShortcut.default

        #expect(shortcut.keyCode == UInt32(kVK_ANSI_K))
        #expect(shortcut.modifiers == [.control, .option])
        #expect(shortcut.displayText == "Control-Option-K")
    }

    @MainActor
    @Test func shortcutDisplayTextFormatsModifiersAndKey() {
        let shortcut = GlobalKeyboardShortcut(
            keyCode: UInt32(kVK_ANSI_S),
            keyDisplayName: "S",
            modifiers: [.control, .option, .shift, .command]
        )

        #expect(shortcut.displayText == "Control-Option-Shift-Command-S")
    }
}
