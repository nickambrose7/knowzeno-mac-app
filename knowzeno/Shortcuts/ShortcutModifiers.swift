//
//  ShortcutModifiers.swift
//  knowzeno
//

import AppKit
import Carbon

struct ShortcutModifiers: OptionSet, Codable, Equatable, Sendable {
    let rawValue: Int

    static let control = ShortcutModifiers(rawValue: 1 << 0)
    static let option = ShortcutModifiers(rawValue: 1 << 1)
    static let shift = ShortcutModifiers(rawValue: 1 << 2)
    static let command = ShortcutModifiers(rawValue: 1 << 3)

    static let defaultModifiers: ShortcutModifiers = [.control, .option]

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    init(eventModifierFlags: NSEvent.ModifierFlags) {
        var modifiers: ShortcutModifiers = []

        if eventModifierFlags.contains(.control) {
            modifiers.insert(.control)
        }

        if eventModifierFlags.contains(.option) {
            modifiers.insert(.option)
        }

        if eventModifierFlags.contains(.shift) {
            modifiers.insert(.shift)
        }

        if eventModifierFlags.contains(.command) {
            modifiers.insert(.command)
        }

        self = modifiers
    }

    var carbonFlags: UInt32 {
        var flags = UInt32(0)

        if contains(.control) {
            flags |= UInt32(controlKey)
        }

        if contains(.option) {
            flags |= UInt32(optionKey)
        }

        if contains(.shift) {
            flags |= UInt32(shiftKey)
        }

        if contains(.command) {
            flags |= UInt32(cmdKey)
        }

        return flags
    }

    var cgEventFlags: CGEventFlags {
        var flags: CGEventFlags = []

        if contains(.control) {
            flags.insert(.maskControl)
        }

        if contains(.option) {
            flags.insert(.maskAlternate)
        }

        if contains(.shift) {
            flags.insert(.maskShift)
        }

        if contains(.command) {
            flags.insert(.maskCommand)
        }

        return flags
    }

    var displayComponents: [String] {
        var components: [String] = []

        if contains(.control) {
            components.append("Control")
        }

        if contains(.option) {
            components.append("Option")
        }

        if contains(.shift) {
            components.append("Shift")
        }

        if contains(.command) {
            components.append("Command")
        }

        return components
    }
}
