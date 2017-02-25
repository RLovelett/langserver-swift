//
//  StandardTypes.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/18/16.
//
//

import Argo
import Foundation
import Runes
import Yams

extension String: YamlConvertable {

    public static func decode(_ yaml: Node) -> Decoded<String> {
        switch yaml {
        case .scalar(let s): return pure(s)
        default: return .typeMismatch(expected: "String", actual: "???")
        }
    }

}

extension URL: YamlConvertable {

    public static func decode(_ yaml: Node) -> Decoded<URL> {
        switch yaml {
        case .scalar(let s): return pure(URL(fileURLWithPath: s))
        default: return .typeMismatch(expected: "String", actual: "???")
        }
    }

}

public extension Optional where Wrapped: YamlConvertable, Wrapped == Wrapped.DecodedType {

    static func decode(_ yaml: Node) -> Decoded<Wrapped?> {
        return Wrapped.decode(yaml) >>- { .success(.some($0)) }
    }

}

public extension Collection where Iterator.Element: YamlConvertable, Iterator.Element == Iterator.Element.DecodedType {

    static func decode(_ yaml: Node) -> Decoded<[Iterator.Element]> {
        switch yaml {
        case .mapping(let o): return sequence(o.map({ Iterator.Element.decode($0.1) }))
        case .sequence(let a): return sequence(a.map(Iterator.Element.decode))
        default: return .typeMismatch(expected: "Array", actual: "???")
        }
    }

}
