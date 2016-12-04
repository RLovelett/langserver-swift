//
//  DidOpenTextDocumentParams.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/4/16.
//
//

import Argo
import Curry
import Runes

/// The document open notification is sent from the client to the server to signal newly opened text
/// documents. The document's truth is now managed by the client and the server must not try to read
/// the document's truth using the document's uri.
public struct DidOpenTextDocumentParams {

    /// The document that was opened.
    let textDocument: TextDocument

}

extension DidOpenTextDocumentParams : Decodable {

    public static func decode(_ json: JSON) -> Decoded<DidOpenTextDocumentParams> {
        let textDocument: Decoded<TextDocument> = json <| "textDocument"
        return curry(DidOpenTextDocumentParams.init) <^> textDocument
    }

}
