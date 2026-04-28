//
//  PasteboardSnapshot.swift
//  knowzeno
//

import AppKit

@MainActor
struct PasteboardSnapshot {
    private let items: [PasteboardItemSnapshot]

    init(pasteboard: NSPasteboard) {
        items = pasteboard.pasteboardItems?.map(PasteboardItemSnapshot.init(item:)) ?? []
    }

    func restore(to pasteboard: NSPasteboard) {
        pasteboard.clearContents()
        pasteboard.writeObjects(items.map(\.pasteboardItem))
    }
}
