//
//  TextDocumentContentChangeEvent.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/7/16.
//
//

import Argo
import Curry
import Runes

/// An event describing a change to a text document. If range and rangeLength are omitted the new
/// text is considered to be the full content of the document.
struct TextDocumentContentChangeEvent {

    /// The range of the document that changed.
    let range: TextDocumentRange?

    /// The length of the range that got replaced.
    let rangeLength: Int?

    /// The new text of the document.
    let text: String

}

extension TextDocumentContentChangeEvent : Decodable {

    static func decode(_ json: JSON) -> Decoded<TextDocumentContentChangeEvent> {
        let range: Decoded<TextDocumentRange?> = json <|? "range"
        let rangeLength: Decoded<Int?> = json <|? "rangeLength"
        let text: Decoded<String> = json <| "text"
        return curry(TextDocumentContentChangeEvent.init) <^> range <*> rangeLength <*> text
    }

}
