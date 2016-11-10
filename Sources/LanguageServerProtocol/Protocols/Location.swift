//
//  Location.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 10/25/16.
//
//

import JSONRPC

/// Represents a location inside a resource, such as a line inside a text file.
public protocol Location : Messageable {

    var uri: String { get }

    var range: TextDocumentRange { get }

}

extension Location {

    public var message: [ String : Any ]? {
        guard let message = range.message else { return nil }
        return [
            "uri" : uri,
            "range" : message
        ]
    }

}
