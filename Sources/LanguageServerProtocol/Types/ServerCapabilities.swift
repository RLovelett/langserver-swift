//
//  ServerCapabilities.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/21/16.
//
//

import Argo
import Foundation
import Ogra

/// The capabilities the language server provides.
public struct ServerCapabilities {

    /// Defines how text documents are synced.
    let textDocumentSync: TextDocumentSyncKind?

    /// The server provides hover support.
    let hoverProvider: Bool?

    /// The server provides completion support.
    let completionProvider: CompletionOptions?

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

extension ServerCapabilities : Encodable {

    public func encode() -> JSON {
        var obj: [String : JSON] = [ : ]

        if let textDocumentSync = self.textDocumentSync {
            obj["textDocumentSync"] = JSON.number(NSNumber(value: textDocumentSync.rawValue))
        }

        if let hoverProvider = self.hoverProvider {
            obj["hoverProvider"] = JSON.bool(hoverProvider)
        }

        if let completionProvider = self.completionProvider {
            obj["completionProvider"] = completionProvider.encode()
        }

        if let definitiionProvider = self.definitiionProvider {
            obj["definitionProvider"] = JSON.bool(definitiionProvider)
        }

        if let workspaceSymbolProvider = self.workspaceSymbolProvider {
            obj["workspaceSymbolProvider"] = JSON.bool(workspaceSymbolProvider)
        }

        return JSON.object(obj)
    }

}
