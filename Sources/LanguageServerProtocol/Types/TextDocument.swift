//
//  TextDocument.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 10/25/16.
//
//

import Argo
import Curry
import Foundation
import Runes

/// The representation of a Swift source file.
///
/// This type is used by both the client and server to transfer a Swift source.
struct TextDocument : TextDocumentItem {

    /// The source file's fully qualified path on the filesystem.
    let uri: URL

    /// The text document's language identifier.
    let languageId: String

    /// The version number of this document (it will strictly increase after each change,
    /// including undo/redo).
    let version: Int

    /// The content of the opened text document.
    let text: String

}

extension TextDocument {

    /// Attempt to create an instance for a file location. It will fail to initialize if the file cannot be read.
    ///
    /// - Parameter file: The file, on the local file system, that should be read.
    init?(_ file: URL) {
        guard let contents = try? String(contentsOf: file, encoding: .utf8) else {
            return nil
        }
        uri = file
        languageId = "swift"
        version = Int.min
        text = contents
    }

    /// Create a new instance from the current instance, whild changing the version and text.
    ///
    /// - Parameters:
    ///   - version: The version to set the new text document to.
    ///   - andText: The content of the new text document.
    /// - Returns: A new copy of the current text document with the changed parameters.
    func update(version: Int, andText: String) -> TextDocument {
        return TextDocument(uri: uri, languageId: languageId, version: version, text: andText)
    }

    /// Converts the position to a zero-based byte offset in the TextDocument.
    ///
    /// - Parameter position: The position to convert.
    /// - Returns: The byte offset from the TextDocument start index.
    /// - Throws: WorkspaceError.positionNotFound if the Position is not within the bounds of the TextDocument.
    func byteOffset(at position: Position) throws -> Int {
        let seq = AnySequence { LineIterator(self.text) }
        guard let line = seq.first(where: { $0.number == position.line }) else {
            throw WorkspaceError.positionNotFound
        }
        let limit = (line.last) ? text.endIndex : text.index(before: line.end)
        guard let final = text.index(line.start, offsetBy: position.character, limitedBy: limit) else {
            throw WorkspaceError.positionNotFound
        }
        return text.distance(from: text.startIndex, to: final)
    }

    /// Create a Position in a TextDocument from a byte offset.
    ///
    /// - Parameter offset: The offset from the start of the TextDocument.
    /// - Returns: A new and valid Position.
    /// - Throws: WorkspaceError.positionNotFound if the offset is not within the bounds of the TextDocument.
    func position(for offset: Int) throws -> Position {
        guard offset >= 0 else {
            throw WorkspaceError.positionNotFound
        }
        guard let index = text.index(text.startIndex, offsetBy: offset, limitedBy: text.endIndex) else {
            throw WorkspaceError.positionNotFound
        }
        let seq = AnySequence { LineIterator(self.text) }
        guard let line = seq.first(where: { $0.contains(index) }) else {
            throw WorkspaceError.positionNotFound
        }
        let character = text.distance(from: line.start, to: index)
        return Position(line: line.number, character: character)
    }

    /// Create a TextDocumentRange in a TextDocument from a byte offset and number of bytes.
    ///
    /// - Parameters:
    ///   - offset: The offset from the start of the TextDocument.
    ///   - length: The number of bytes from the offset to include in the range.
    /// - Returns: A new and valid TextDocumentRange.
    /// - Throws: WorkspaceError.positionNotFound if the range is not within the bounds of the TextDocument.
    func selection(startAt offset: Int, length: Int) throws -> TextDocumentRange {
        let endOffset = Int(offset + length)
        let start = try position(for: offset)
        let end = try position(for: endOffset)
        return TextDocumentRange(start: start, end: end)
    }

}

extension TextDocument : Argo.Decodable {

    /// Create a new text document from JSON sent by the client.
    ///
    /// - Parameter json: The JSON from the client.
    /// - Returns: The result of decoding the JSON.
    public static func decode(_ json: JSON) -> Decoded<TextDocument> {
        let uri: Decoded<URL> = json["uri"]
        let languageId: Decoded<String> = json["languageId"]
        let version: Decoded<Int> = json["version"]
        let text: Decoded<String> = json["text"]
        return curry(TextDocument.init) <^> uri <*> languageId <*> version <*> text
    }

}

extension TextDocument : Hashable {

    var hashValue: Int {
        return uri.hashValue
    }

}

extension TextDocument : Equatable {

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    static func ==(lhs: TextDocument, rhs: TextDocument) -> Bool {
        return lhs.uri == rhs.uri
            && lhs.languageId == rhs.languageId
            && lhs.version == rhs.version
    }

}
