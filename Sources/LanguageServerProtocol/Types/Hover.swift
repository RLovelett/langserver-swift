//
//  Hover.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/11/16.
//
//

import Argo
import Ogra

/// The marked string is rendered:
///  - as markdown if it is represented as a string
///  - as code block of the given langauge if it is represented as a pair of a language and a value
///
/// The pair of a language and a value is an equivalent to markdown:
/// ```${language}
/// ${value}
/// ```
///
/// `type MarkedString = string | { language: string; value: string };`
typealias MarkedString = String

/// The result of a hover request.
public struct Hover {

    /// The hover's content
    let contents: [MarkedString]

    /// An optional range is a range inside a text document that is used to visualize a hover,
    /// e.g. by changing the background color.
    let range: TextDocumentRange?

}

extension Hover : Ogra.Encodable {

    public func encode() -> JSON {
        var obj = [
            "contents" : contents.encode()
        ]

        if let range = range {
            obj["range"] = range.encode()
        }

        return JSON.object(obj)
    }

}
