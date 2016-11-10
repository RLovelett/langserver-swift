//
//  SourcePosition.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/23/16.
//
//

import Argo
import Curry
import Foundation
import Runes

public struct SourcePosition : TextDocumentPositionParams {

    /// The text document.
    public let textDocument: TextDocumentIdentifier

    /// The position inside the text document.
    public let position: Position

}

extension SourcePosition : Decodable {

    public static func decode(_ json: JSON) -> Decoded<SourcePosition> {
        let td: Decoded<URL> = json <| ["textDocument", "uri"]
        let p: Decoded<LinePosition> = json <| "position"
        return curry(SourcePosition.init) <^> td <*> p
    }

}
