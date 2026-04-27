//
//  HotKeyManager.swift
//  knowzeno
//

import Carbon
import Foundation

final class HotKeyManager {
    private var eventHandler: EventHandlerRef?
    private var hotKey: EventHotKeyRef?
    private let action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
    }

    func register() {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let selfPointer = Unmanaged.passUnretained(self).toOpaque()
        InstallEventHandler(
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    manager.action()
                }

                return noErr
            },
            1,
            &eventType,
            selfPointer,
            &eventHandler
        )

        let hotKeyID = EventHotKeyID(signature: fourCharacterCode("KZNO"), id: 1)
        RegisterEventHotKey(
            UInt32(kVK_ANSI_K),
            UInt32(cmdKey | optionKey | controlKey),
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKey
        )
    }

    deinit {
        if let hotKey {
            UnregisterEventHotKey(hotKey)
        }

        if let eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }
}

private func fourCharacterCode(_ string: String) -> OSType {
    string.utf8.reduce(0) { result, character in
        (result << 8) + OSType(character)
    }
}
