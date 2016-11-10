//
//  TextDocumentRange.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/23/16.
//
//

import JSONRPC

/// A range in a text document expressed as (zero-based) start and end positions. A range is
/// comparable to a selection in an editor. Therefore the end position is exclusive.
public protocol TextDocumentRange : Messageable {

    /// The range's start position.
    var start: Position { get }

    /// The range's start position.
    var end: Position { get }

}

extension TextDocumentRange {

    var message: [String : Any]? {
        // TODO: Probably need a better protocol here (i.e., the Optional is not really necessary)
        guard let start = self.start.message, let end = self.end.message else { return nil }
        return [
            "start" : start,
            "end" : end
        ]
    }

}
