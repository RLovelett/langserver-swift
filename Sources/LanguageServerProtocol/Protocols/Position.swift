//
//  Position.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/23/16.
//
//

import Argo
import JSONRPC
import Ogra

/// Position in a text document expressed as zero-based line and character offset. A position is
/// between two characters like an 'insert' cursor in a editor.
public protocol Position : Encodable {

    /// Line position in a document (zero-based).
    var line: Int { get }

    /// Character offset on a line in a document (zero-based).
    var character: Int { get }

}

extension Position {

    func encode() -> JSON {
        return JSON([
            "line" : line,
            "character" : character
        ])
    }

}
