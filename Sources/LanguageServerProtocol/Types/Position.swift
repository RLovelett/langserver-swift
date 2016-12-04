//
//  Position.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/23/16.
//
//

import Argo
import Curry
import Foundation
import JSONRPC
import Ogra
import Runes

/// Position in a text document expressed as zero-based line and character offset. A position is
/// between two characters like an 'insert' cursor in a editor.
public struct Position {

    /// Line position in a document (zero-based).
    let line: Int

    /// Character offset on a line in a document (zero-based).
    let character: Int

}

extension Position : Decodable {

    public static func decode(_ json: JSON) -> Decoded<Position> {
        let l: Decoded<Int> = json <| "line"
        let c: Decoded<Int> = json <| "character"
        return curry(Position.init) <^> l <*> c
    }

}

extension Position : Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: Position, rhs: Position) -> Bool {
        return lhs.line == rhs.line && lhs.character == rhs.character
    }
}

extension Position : Encodable {

    public func encode() -> JSON {
        return JSON.object([
            "line" : JSON.number(NSNumber(value: line)),
            "character" : JSON.number(NSNumber(value: character))
        ])
    }

}
