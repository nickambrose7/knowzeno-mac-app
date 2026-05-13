//
//  LibraryDateText.swift
//  knowzeno
//

import Foundation

enum LibraryDateText {
    static func dateOnly(from timestamp: String) -> String {
        if let date = isoDatePrefixFormatter.date(from: String(timestamp.prefix(10))) {
            return displayFormatter.string(from: date)
        }

        if let date = isoDateTimeFormatter.date(from: timestamp) {
            return displayFormatter.string(from: date)
        }

        return timestamp
    }

    private static let isoDatePrefixFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let isoDateTimeFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
