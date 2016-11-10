//
//  TextDocumentPositionParams.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/22/16.
//
//

import Argo

/// A parameter literal used in requests to pass a text document and a position inside that document.
public protocol TextDocumentPositionParams : Decodable {

    /// The text document.
    var textDocument: TextDocumentIdentifier { get }

    /// The position inside the text document.
    var position: Position { get }

}
