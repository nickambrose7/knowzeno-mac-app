//
//  HotKeyManager.swift
//  knowzeno
//

import Carbon
import Foundation

@MainActor
final class HotKeyManager {
    private var eventHandler: EventHandlerRef?
    private var hotKey: EventHotKeyRef?
    private(set) var registeredShortcut: GlobalKeyboardShortcut?
    private let action: @MainActor () -> Void

    init(action: @MainActor @escaping () -> Void) {
        self.action = action
    }

    func register(_ shortcut: GlobalKeyboardShortcut) throws {
        try installEventHandlerIfNeeded()

        let hotKeyID = EventHotKeyID(signature: fourCharacterCode("KZNO"), id: 1)
        var newHotKey: EventHotKeyRef?
        let status = RegisterEventHotKey(
            shortcut.keyCode,
            shortcut.modifiers.carbonFlags,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &newHotKey
        )

        guard status == noErr, let newHotKey else {
            throw HotKeyError.registrationFailed(status)
        }

        if let hotKey {
            UnregisterEventHotKey(hotKey)
        }

        hotKey = newHotKey
        registeredShortcut = shortcut
    }

    func unregister() {
        if let hotKey {
            UnregisterEventHotKey(hotKey)
        }

        hotKey = nil
        registeredShortcut = nil
    }

    private func installEventHandlerIfNeeded() throws {
        guard eventHandler == nil else {
            return
        }

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let selfPointer = Unmanaged.passUnretained(self).toOpaque()
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData in
                guard let event, let userData else {
                    return noErr
                }

                var hotKeyID = EventHotKeyID()
                GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )

                guard hotKeyID.id == 1 else {
                    return noErr
                }

                let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
                Task { @MainActor in
                    try? await Task.sleep(for: .milliseconds(150))
                    manager.action()
                }

                return noErr
            },
            1,
            &eventType,
            selfPointer,
            &eventHandler
        )

        guard status == noErr else {
            throw HotKeyError.eventHandlerInstallationFailed(status)
        }
    }

    deinit {
        MainActor.assumeIsolated {
            unregister()

            if let eventHandler {
                RemoveEventHandler(eventHandler)
            }
        }
    }
}

enum HotKeyError: LocalizedError {
    case eventHandlerInstallationFailed(OSStatus)
    case registrationFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case .eventHandlerInstallationFailed(let status):
            "Could not install the global shortcut handler. Carbon returned status \(status)."
        case .registrationFailed(let status):
            "Could not register that global shortcut. It may already be used by another app. Carbon returned status \(status)."
        }
    }
}

private func fourCharacterCode(_ string: String) -> OSType {
    string.utf8.reduce(0) { result, character in
        (result << 8) + OSType(character)
    }
}
