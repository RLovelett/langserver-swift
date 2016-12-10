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
import SourceKittenFramework

struct TextDocument : TextDocumentItem {

    /// The text document's language identifier.
    let languageId: String

    /// The version number of this document (it will strictly increase after each change,
    /// including undo/redo).
    let version: Int

    /// The content of the opened text document.
    let text: String

    let file: URL

    let lines: LineCollection

}

extension TextDocument {

    init?(_ file: URL) {
        languageId = "swift"
        version = Int.min
        text = ""
        self.file = file
        guard let lines = try? LineCollection(for: file) else { return nil }
        self.lines = lines
    }

    fileprivate init(languageId: String, version: Int, text: String, file: URL) {
        self.languageId = languageId
        self.version = version
        self.text = text
        self.file = file
        // TODO: Force cast 🤢
        self.lines = LineCollection(for: text)!
    }

    func update(version: Int, andText: String) -> TextDocument {
        return TextDocument(languageId: languageId, version: version, text: andText, file: file)
    }

}

extension TextDocument : TextDocumentIdentifier {

    /// The text document's URI.
    var uri: String {
        return file.uri
    }

}


extension TextDocument : Decodable {

    private init(uri: String, languageId: String, version: Int, text: String) {
        self.languageId = languageId
        self.version = version
        self.text = text
        // TODO: Force cast 🤢
        self.file = URL(string: uri)!
        self.lines = LineCollection(for: text)!
    }

    public static func decode(_ json: JSON) -> Decoded<TextDocument> {
        let uri: Decoded<String> = json <| "uri"
        let languageId: Decoded<String> = json <| "languageId"
        let version: Decoded<Int> = json <| "version"
        let text: Decoded<String> = json <| "text"
        return curry(TextDocument.init) <^> uri <*> languageId <*> version <*> text
    }

}
