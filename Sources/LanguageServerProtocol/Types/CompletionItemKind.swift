//
//  CompletionItemKind.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/2/16.
//
//

import Argo
import Runes

/// The kind of a completion entry.
public enum CompletionItemKind : Int {
    case Text = 1
    case Method = 2
    case Function = 3
    case Constructor = 4
    case Field = 5
    case Variable = 6
    case Class = 7
    case Interface = 8
    case Module = 9
    case Property = 10
    case Unit = 11
    case Value = 12
    case Enum = 13
    case Keyword = 14
    case Snippet = 15
    case Color = 16
    case File = 17
    case Reference = 18

    init(_ str: String) {
        switch str {
        case "source.lang.swift.decl.function.free",
             "source.lang.swift.decl.function.method.instance":
            self = .Function
        case "source.lang.swift.decl.function.constructor":
            self = .Constructor
        case "source.lang.swift.decl.var.global",
             "source.lang.swift.decl.var.instance":
            self = .Variable
        case "source.lang.swift.decl.class":
            self = .Class
        case "source.lang.swift.decl.protocol":
            self = .Interface
        case "source.lang.swift.decl.struct":
            self = .Value //Maybe?
        case "source.lang.swift.decl.enum":
            self = .Enum
        case "source.lang.swift.keyword",
             "source.lang.swift.decl.function.operator.infix":
            self = .Keyword
        case "source.lang.swift.literal.color":
            self = .Color
        case "source.lang.swift.literal.image":
            self = .File
        case "source.lang.swift.decl.typealias":
            self = .Reference
        default:
            self = .Text
        }
    }
}

extension CompletionItemKind : Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<CompletionItemKind> {
        switch json {
        case .string(let kind):
            return pure(CompletionItemKind(kind))
        default:
            return .typeMismatch(expected: "String", actual: json)
        }
    }

}
