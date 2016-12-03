//
//  Location.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 10/25/16.
//
//

import Argo
import JSONRPC
import Ogra

/// Represents a location inside a resource, such as a line inside a text file.
public protocol Location : Encodable {

    var uri: String { get }

    var range: TextDocumentRange { get }

}

extension Location {

    public func encode() -> JSON {
        return JSON.object([
            "uri" : JSON.string(uri),
            "range" : range.encode()
        ])
    }

}
