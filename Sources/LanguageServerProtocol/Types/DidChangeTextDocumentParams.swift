//
//  DidChangeTextDocumentParams.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/7/16.
//
//

import Argo
import Curry
import Runes

public struct DidChangeTextDocumentParams {

    /// The document that did change. The version number points to the version after all provided
    /// content changes have been applied.
    let textDocument: VersionedTextDocumentIdentifier

    /// The actual content changes.
    let contentChanges: [TextDocumentContentChangeEvent]

}

extension DidChangeTextDocumentParams : Decodable {

    public static func decode(_ json: JSON) -> Decoded<DidChangeTextDocumentParams> {
        let textDocument: Decoded<VersionedTextDocumentIdentifier> = json <| "textDocument"
        let contentChanges: Decoded<[TextDocumentContentChangeEvent]> = json <|| "contentChanges"
        return curry(DidChangeTextDocumentParams.init) <^> textDocument <*> contentChanges
    }

}
