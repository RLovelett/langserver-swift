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
public protocol InitializeResult : Encodable {

    /// The capabilities the language server provides.
    var capabilities: ServerCapabilities { get }

}

extension WorkspaceInitializationResult {

    public func encode() -> JSON {
        return JSON.object([
            "capabilities": capabilities.encode()
        ])
    }

}
