//
//  LineIterator.swift
//  LanguageServerProtocol
//
//  Created by Ryan Lovelett on 5/30/18.
//

private extension Character {

    var isLineEnding: Bool {
        return self == "\r\n" || self == "\r" || self == "\n"
    }

}

struct Line {
    let number: Int
    let start: String.Index
    let end: String.Index
    let last: Bool

    func contains(_ index: String.Index) -> Bool {
        if last {
            return (start...end).contains(index)
        } else {
            return (start..<end).contains(index)
        }
    }
}

struct LineIterator: IteratorProtocol {

    private let text: String

    private var cursor: String.Index

    private var lineNumber: Int

    private var handleTrailingNewLine: Bool

    init(_ text: String) {
        self.text = text
        cursor = text.startIndex
        handleTrailingNewLine = text[text.index(before: text.endIndex)].isLineEnding
        lineNumber = 0
    }

    mutating func next() -> Line? {
        guard cursor < text.endIndex else {
            if handleTrailingNewLine {
                handleTrailingNewLine = false
                return Line(number: lineNumber, start: text.endIndex, end: text.endIndex, last: true)
            }
            // If here we are at EOF
            return nil
        }
        // Make sure to increment the line number
        defer { lineNumber += 1 }
        let start = cursor
        guard !text[cursor].isLineEnding else {
            // If the first character on a line is a new line character
            cursor = text.index(after: cursor)
            return Line(number: lineNumber, start: start, end: cursor, last: false)
        }
        var isLineEding: Bool = false
        var isEOF: Bool = false
        while !isLineEding && !isEOF {
            cursor = text.index(after: cursor)
            isEOF = cursor == text.endIndex
            isLineEding = (isEOF) ? true : text[cursor].isLineEnding
        }
        if isLineEding && !isEOF {
            cursor = text.index(after: cursor)
        }
        return Line(number: lineNumber, start: start, end: cursor, last: isEOF)
    }

}
