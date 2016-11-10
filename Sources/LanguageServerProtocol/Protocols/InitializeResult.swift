//
//  InitializeResult.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/21/16.
//
//

import JSONRPC

/// The response to the 'initialize' request.
public protocol InitializeResult : Messageable {

    /// The capabilities the language server provides.
    var capabilities: ServerCapabilities { get }

}

extension WorkspaceInitializationResult {

    public var message: [String : Any]? {
        // TODO: Probably need a better protocol here (i.e., the Optional is not really necessary)
        guard let c = capabilities.message else { return nil }
        return [
            "capabilities": c
        ]
    }

}
