//
//  SymbolInformation.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 4/19/17.
//
//

import Argo
import Foundation
import Ogra

/**
 * Represents information about programming constructs like variables, classes,
 * interfaces etc.
 */
public struct SymbolInformation {
    /**
     * The name of this symbol.
     */
    let name: String

    /**
     * The kind of this symbol.
     */
    let kind: SymbolKind

    /**
     * The location of this symbol.
     */
    let location: Location

    /**
     * The name of the symbol containing this symbol.
     */
    let containerName: String?
}

extension SymbolInformation : Encodable {

    public func encode() -> JSON {
        var obj = [
            "name" : name.encode(),
            "kind" : kind.encode(),
            "location" : location.encode(),
        ]

        if let containerName = containerName {
            obj["containerName"] = containerName.encode()
        }

        return JSON.object(obj)
    }

}
