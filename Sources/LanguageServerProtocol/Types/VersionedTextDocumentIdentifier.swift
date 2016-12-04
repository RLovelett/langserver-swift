//
//  VersionedTextDocumentIdentifier.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/7/16.
//
//

import Argo
import Curry
import Runes

struct VersionedTextDocumentIdentifier : TextDocumentIdentifier {

    /// The text document's URI.
    let uri: String

    /// The version number of this document.
    let version: Int

}

extension VersionedTextDocumentIdentifier : Decodable {

    static func decode(_ json: JSON) -> Decoded<VersionedTextDocumentIdentifier> {
        let uri: Decoded<String> = json <| "uri"
        let version: Decoded<Int> = json <| "version"
        return curry(VersionedTextDocumentIdentifier.init) <^> uri <*> version
    }

}
