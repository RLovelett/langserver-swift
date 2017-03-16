//
//  Location.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 10/25/16.
//
//

import Argo
import Ogra

/// Represents a location inside a resource, such as a line inside a text file.
public struct Location {

    let uri: String

    let range: TextDocumentRange

}

extension Location : Encodable {

    public func encode() -> JSON {
        return JSON.object([
            "uri" : JSON.string(uri),
            "range" : range.encode()
        ])
    }

}
