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

    /// A collection of Ranges that denote the different byte position of lines in a document.
    let lines: LineCollection

}

extension TextDocument {

    /// Attempt to create an instance for a file location. It will fail to initialize if the file cannot be read.
    ///
    /// - Parameter file: The file, on the local file system, that should be read.
    init?(_ file: URL) {
        uri = file
        languageId = "swift"
        version = Int.min
        text = ""
        guard let lines = try? LineCollection(for: file) else { return nil }
        self.lines = lines
    }

    /// Create a text document instance from information sent by the client.
    ///
    /// - Parameters:
    ///   - uri: The source file's fully qualified path on the filesystem.
    ///   - languageId: The text document's language identifier, typically `"swift"`.
    ///   - version: The version number of this document.
    ///   - text: The content of the opened text document.
    fileprivate init(uri: URL, languageId: String, version: Int, text: String) {
        self.uri = uri
        self.languageId = languageId
        self.version = version
        self.text = text
        // TODO: Force cast 🤢
        self.lines = LineCollection(for: text)!
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

}

extension TextDocument : Decodable {

    /// Create a new text document from JSON sent by the client.
    ///
    /// - Parameter json: The JSON from the client.
    /// - Returns: The result of decoding the JSON.
    public static func decode(_ json: JSON) -> Decoded<TextDocument> {
        let uri: Decoded<URL> = json <| "uri"
        let languageId: Decoded<String> = json <| "languageId"
        let version: Decoded<Int> = json <| "version"
        let text: Decoded<String> = json <| "text"
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
