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

    enum DefinitionLocation {
        case local(filepath: URL, offset: UInt64, length: UInt64)
        case system(moduleName: String, groupName: String, isSystem: Bool)
    }

    /// UID for the declaration or reference kind (function, class, etc.).
    let kind: String

    /// Displayed name for the token.
    let name: String

    /// USR string for the token.
    let usr: String

    /// Text describing the type of the result.
    let typename: String

    /// XML representing how the token was declared.
    let annotatedDeclaration: String

    /// XML representing the token.
    let fullyAnnotatedDeclaration: String

    /// XML representing the token and its documentation.
    let documentationAsXML: String?

    /// USR string for the type.
    let typeusr: String

    let defined: DefinitionLocation

}

extension Cursor : Decodable {

    static func decode(_ json: JSON) -> Decoded<Cursor> {
        return curry(Cursor.init)
            <^> json <| "key.kind"
            <*> json <| "key.name"
            <*> json <| "key.usr"
            <*> json <| "key.typename"
            <*> json <| "key.annotated_decl"
            <*> json <| "key.fully_annotated_decl"
            <*> json <|? "key.doc.full_as_xml"
            <*> json <| "key.typeusr"
            <*> Cursor.DefinitionLocation.decode(json)
    }

}

extension Cursor.DefinitionLocation : Decodable {

    static func decode(_ json: JSON) -> Decoded<Cursor.DefinitionLocation> {
        let filepath: String? = (json <| "key.filepath").value
        let offset: UInt64? = (json <| "key.offset").value
        let length: UInt64? = (json <| "key.length").value
        let isSystem: Bool = (json <| "key.is_system").value ?? false
        let moduleName: String? = (json <| "key.modulename").value
        let groupName: String? = (json <| "key.groupname").value

        switch (filepath, offset, length, moduleName, groupName) {
        case let (f?, o?, l?, _, _):
            return pure(Cursor.DefinitionLocation.local(filepath: URL(fileURLWithPath: f), offset: o, length: l))
        case let (_, _, _, mn?, gn?):
            return pure(Cursor.DefinitionLocation.system(moduleName: mn, groupName: gn, isSystem: isSystem))
        default:
            return .customError("Could not determine if this is a system or local module.")
        }
    }

}

