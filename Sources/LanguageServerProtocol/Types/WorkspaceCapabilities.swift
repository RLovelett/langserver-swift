//
//  WorkspaceCapabilities.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/23/16.
//
//

import JSONRPC

struct WorkspaceCapabilities : ServerCapabilities {

    /// Defines how text documents are synced.
    let textDocumentSync: TextDocumentSyncKind?

    /// The server provides hover support.
    let hoverProvider: Bool?

    /// The server provides goto definition support.
    let definitiionProvider: Bool?

    /// The server provides find references support.
    let referencesProvider: Bool?

    /// The server provides document highlight support.
    let documentHighlighProvider: Bool?

    /// The server provides document symbol support.
    let documentSymbolProvider: Bool?

    /// The server provides workspace symbol support.
    let workspaceSymbolProvider: Bool?

    /// The server provides code actions.
    let codeActionProvider: Bool?

    /// The server provides document formatting.
    let documentFormattingProvider: Bool?

    /// The server provides document range formatting.
    let documentRangeFormattingProvider: Bool?

    /// The server provides rename support.
    let renameProvider: Bool?

}
