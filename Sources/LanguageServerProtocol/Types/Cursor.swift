//
//  Cursor.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/21/16.
//
//

import Argo
import Curry
import Foundation
import Runes

struct Cursor {

    /// UID for the declaration or reference kind (function, class, etc.).
    let kind: String

    /// Displayed name for the token.
    let name: String

    /// USR string for the token.
    let usr: String

    /// Path to the file.
    let filepath: String

    /// Byte offset of the token inside the souce contents.
    let offset: UInt64

    /// Length of the token.
    let length: UInt64

    // Text describing the type of the result.
    let typename: String

    /// XML representing how the token was declared.
    let annotatedDeclaration: String

    /// XML representing the token.
    let fullyAnnotatedDeclaration: String

    /// XML representing the token and its documentation.
    let documentationAsXML: String?

    /// USR string for the type.
    let typeusr: String

    var uri: URL {
        return URL(fileURLWithPath: filepath)
    }

}

extension Cursor : Decodable {

    static func decode(_ json: JSON) -> Decoded<Cursor> {
        let k: Decoded<String> = json <| "key.kind"
        let n: Decoded<String> = json <| "key.name"
        let u: Decoded<String> = json <| "key.usr"
        let f: Decoded<String> = json <| "key.filepath"
        let o: Decoded<UInt64> = json <| "key.offset"
        let l: Decoded<UInt64> = json <| "key.length"
        let t: Decoded<String> = json <| "key.typename"
        let a: Decoded<String> = json <| "key.annotated_decl"
        let fa: Decoded<String> = json <| "key.fully_annotated_decl"
        let df: Decoded<String?> = json <|? "key.doc.full_as_xml"
        let tu: Decoded<String> = json <| "key.typeusr"

        return curry(Cursor.init)
            <^> k
            <*> n
            <*> u
            <*> f
            <*> o
            <*> l
            <*> t
            <*> a
            <*> fa
            <*> df
            <*> tu
    }

}
