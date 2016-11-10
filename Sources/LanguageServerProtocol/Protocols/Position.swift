//
//  Position.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/23/16.
//
//

import JSONRPC

/// Position in a text document expressed as zero-based line and character offset. A position is
/// between two characters like an 'insert' cursor in a editor.
public protocol Position : Messageable {

    /// Line position in a document (zero-based).
    var line: Int { get }

    /// Character offset on a line in a document (zero-based).
    var character: Int { get }

}

extension Position {

    var message: [String : Any]? {
        // TODO: Probably need a better protocol here (i.e., the Optional is not really necessary)
        return [
            "line" : line,
            "character" : character
        ]
    }

}
