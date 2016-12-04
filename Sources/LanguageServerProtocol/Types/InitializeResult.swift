//
//  InitializeResult.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/21/16.
//
//

import Argo
import JSONRPC
import Ogra

/// The response to the 'initialize' request.
public struct InitializeResult {

    /// The capabilities the language server provides.
    let capabilities: ServerCapabilities

    public init(_ c: ServerCapabilities) {
        capabilities = c
    }

}

extension InitializeResult : Encodable {

    public func encode() -> JSON {
        return JSON.object([
            "capabilities": capabilities.encode()
        ])
    }

}
