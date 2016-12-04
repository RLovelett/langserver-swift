//
//  CompletionOptions.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/26/16.
//
//

import Argo
import JSONRPC
import Ogra

/// Completion options
public struct CompletionOptions {

    /// The server provides support to resolve additional information for a completion item.
    let resolveProvider: Bool?

    /// The characters that trigger completion automatically.
    let triggerCharacters: [String]?

}

extension CompletionOptions : Encodable {

    public func encode() -> JSON {
        var obj: [String : Any] = [ : ]

        if let resolveProvider = self.resolveProvider {
            obj["resolveProvider"] = resolveProvider
        }

        if let triggerCharacters = self.triggerCharacters {
            obj["triggerCharacters"] = triggerCharacters
        }

        return JSON(obj)
    }

}
