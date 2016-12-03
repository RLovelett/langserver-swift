//
//  TextDocumentRange.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/23/16.
//
//

import Argo
import JSONRPC
import Ogra

/// A range in a text document expressed as (zero-based) start and end positions. A range is
/// comparable to a selection in an editor. Therefore the end position is exclusive.
public protocol TextDocumentRange : Encodable {

    /// The range's start position.
    var start: Position { get }

    /// The range's start position.
    var end: Position { get }

}

extension TextDocumentRange {

    public func encode() -> JSON {
        return JSON.object([
            "start" : start.encode(),
            "end" : end.encode()
        ])
    }

}
