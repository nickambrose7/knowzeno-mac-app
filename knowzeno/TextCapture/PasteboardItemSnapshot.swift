//
//  PasteboardItemSnapshot.swift
//  knowzeno
//

import AppKit

@MainActor
struct PasteboardItemSnapshot {
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
