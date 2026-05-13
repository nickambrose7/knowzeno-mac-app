//
//  TextPreview.swift
//  knowzeno
//

import Foundation

enum TextPreview {
    static func preview(
        for text: String,
        sentenceLimit: Int = 3,
        characterLimit: Int = 320
    ) -> String {
        let normalizedText = text
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")

        guard normalizedText.count > characterLimit else {
            return normalizedText
        }

        let sentencePreview = firstSentences(
            in: normalizedText,
            sentenceLimit: sentenceLimit,
            characterLimit: characterLimit
        )
        if let sentencePreview {
            return sentencePreview
        }

        let prefix = normalizedText.prefix(characterLimit)
        if let lastSpace = prefix.lastIndex(of: " ") {
            return String(prefix[..<lastSpace]) + "..."
        }

        return String(prefix) + "..."
    }

    private static func firstSentences(
        in text: String,
        sentenceLimit: Int,
        characterLimit: Int
    ) -> String? {
        var sentenceCount = 0
        var index = text.startIndex

        while index < text.endIndex {
            let character = text[index]
            if ".!?".contains(character) {
                sentenceCount += 1

                if sentenceCount == sentenceLimit {
                    let endIndex = text.index(after: index)
                    guard text.distance(from: text.startIndex, to: endIndex) <= characterLimit else {
                        return nil
                    }

                    return String(text[..<endIndex]).trimmingCharacters(in: .whitespaces) + "..."
                }
            }

            index = text.index(after: index)
        }

        return nil
    }
}
