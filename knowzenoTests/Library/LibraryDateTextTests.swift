//
//  LibraryDateTextTests.swift
//  knowzenoTests
//

import Testing
@testable import knowzeno

struct LibraryDateTextTests {
    @MainActor
    @Test func dateOnlyFormatsIsoTimestampWithoutTime() {
        let date = LibraryDateText.dateOnly(from: "2026-05-03T09:00:00+00:00")

        #expect(date == "May 3, 2026")
    }

    @MainActor
    @Test func dateOnlyFormatsFractionalIsoTimestampWithoutTime() {
        let date = LibraryDateText.dateOnly(from: "2026-05-03T09:00:00.123Z")

        #expect(date == "May 3, 2026")
    }

    @MainActor
    @Test func dateOnlyKeepsUnknownTimestampReadable() {
        let timestamp = "not a timestamp"

        #expect(LibraryDateText.dateOnly(from: timestamp) == timestamp)
    }
}
