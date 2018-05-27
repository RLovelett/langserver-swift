//
//  DidCloseTextDocumentParams.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/5/16.
//
//

import Argo
import Curry
import Runes

/// The document close notification is sent from the client to the server when the document got
/// closed in the client. The document's truth now exists where the document's uri points to (e.g.
/// if the document's uri is a file uri the truth now exists on disk).
public struct DidCloseTextDocumentParams {

    /// The document that was closed.
    let textDocument: TextDocumentIdentifier

}

extension DidCloseTextDocumentParams : Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<DidCloseTextDocumentParams> {
        let textDocument: Decoded<TextDocument> = json["textDocument"]
        return curry(DidCloseTextDocumentParams.init) <^> textDocument
    }

}
