//
//  TextDocumentPositionParams.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/22/16.
//
//

import Argo
import Curry
import Foundation
import Runes

/// A parameter literal used in requests to pass a text document and a position inside that document.
public struct TextDocumentPositionParams {

    /// The text document.
    let textDocument: TextDocumentIdentifier

    /// The position inside the text document.
    let position: Position

}

extension TextDocumentPositionParams : Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<TextDocumentPositionParams> {
        let td: Decoded<URL> = json["textDocument", "uri"]
        let p: Decoded<Position> = json["position"]
        return curry(TextDocumentPositionParams.init) <^> td <*> p
    }

}
