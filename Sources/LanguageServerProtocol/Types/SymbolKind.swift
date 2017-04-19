//
//  SymbolKind.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 4/19/17.
//
//

import Argo
import Foundation
import Ogra

/// A symbol kind.
enum SymbolKind: UInt8 {
    case File = 1
    case Module = 2
    case Namespace = 3
    case Package = 4
    case Class = 5
    case Method = 6
    case Property = 7
    case Field = 8
    case Constructor = 9
    case Enum = 10
    case Interface = 11
    case Function = 12
    case Variable = 13
    case Constant = 14
    case String = 15
    case Number = 16
    case Boolean = 17
    case Array = 18
}

extension SymbolKind : Encodable {

    func encode() -> JSON {
        return JSON.number(NSNumber(value: rawValue))
    }

}
