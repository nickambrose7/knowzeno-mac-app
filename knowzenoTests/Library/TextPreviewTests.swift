//
//  TextPreviewTests.swift
//  knowzenoTests
//

import Testing
@testable import knowzeno

struct TextPreviewTests {
    @MainActor
    @Test func previewKeepsShortTextUnchanged() {
        let text = "First sentence. Second sentence."

        let preview = TextPreview.preview(for: text)

        #expect(preview == text)
    }

    @MainActor
    @Test func previewUsesFirstFewSentences() {
        let text = """
        First sentence. Second sentence. Third sentence. Fourth sentence has extra detail that should be hidden until the user expands the row.
        """

        let preview = TextPreview.preview(for: text, sentenceLimit: 3, characterLimit: 80)

        #expect(preview == "First sentence. Second sentence. Third sentence....")
    }

    @MainActor
    @Test func previewFallsBackToCharacterLimitForLongSentenceBlocks() {
        let text = "abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz abcdefghijklmnopqrstuvwxyz"

        let preview = TextPreview.preview(for: text, characterLimit: 40)

        #expect(preview == "abcdefghijklmnopqrstuvwxyz...")
    }
}
