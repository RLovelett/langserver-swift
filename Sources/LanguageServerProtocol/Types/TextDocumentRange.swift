//
//  TextDocumentRange.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/23/16.
//
//

import Argo
import Curry
import Ogra
import Runes

/// A range in a text document expressed as (zero-based) start and end positions. A range is
/// comparable to a selection in an editor. Therefore the end position is exclusive.
struct TextDocumentRange {

    /// The range's start position.
    let start: Position

    /// The range's start position.
    let end: Position

}

extension TextDocumentRange : Argo.Decodable {

    static func decode(_ json: JSON) -> Decoded<TextDocumentRange> {
        let start: Decoded<Position> = json["start"]
        let end: Decoded<Position> = json["end"]
        return curry(TextDocumentRange.init) <^> start <*> end
    }

}

extension TextDocumentRange : Ogra.Encodable {

    public func encode() -> JSON {
        return JSON.object([
            "start" : start.encode(),
            "end" : end.encode()
        ])
    }

}
