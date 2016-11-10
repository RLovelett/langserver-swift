//
//  ServerCapabilities.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/21/16.
//
//

import JSONRPC

/// The capabilities the language server provides.
public protocol ServerCapabilities : Messageable {

    /// Defines how text documents are synced.
    var textDocumentSync: TextDocumentSyncKind? { get }

    /// The server provides hover support.
    var hoverProvider: Bool? { get }

    /// The server provides goto definition support.
    var definitiionProvider: Bool? { get }

    /// The server provides find references support.
    var referencesProvider: Bool? { get }

    /// The server provides document highlight support.
    var documentHighlighProvider: Bool? { get }

    /// The server provides document symbol support.
    var documentSymbolProvider: Bool? { get }

    /// The server provides workspace symbol support.
    var workspaceSymbolProvider: Bool? { get }

    /// The server provides code actions.
    var codeActionProvider: Bool? { get }

    /// The server provides document formatting.
    var documentFormattingProvider: Bool? { get }

    /// The server provides document range formatting.
    var documentRangeFormattingProvider: Bool? { get }

    /// The server provides rename support.
    var renameProvider: Bool? { get }

}

extension WorkspaceCapabilities : Messageable {

    var message: [String : Any]? {
        var obj: [String : Any] = [ : ]

        if let textDocumentSync = self.textDocumentSync {
            obj["textDocumentSync"] = textDocumentSync.rawValue
        }

        if let hoverProvider = self.hoverProvider {
            obj["hoverProvider"] = hoverProvider
        }

        if let definitiionProvider = self.definitiionProvider {
            obj["definitionProvider"] = definitiionProvider
        }

        if let workspaceSymbolProvider = self.workspaceSymbolProvider {
            obj["workspaceSymbolProvider"] = workspaceSymbolProvider
        }

        return obj
    }

}
