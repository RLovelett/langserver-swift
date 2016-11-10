//
//  WorkspaceInitializationResult.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/23/16.
//
//

import JSONRPC

public struct WorkspaceInitializationResult : InitializeResult {

    public let capabilities: ServerCapabilities

    public init(_ c: ServerCapabilities) {
        capabilities = c
    }

}
