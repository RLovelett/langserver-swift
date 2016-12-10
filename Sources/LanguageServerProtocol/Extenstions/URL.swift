//
//  URL.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/23/16.
//
//

import Argo
import Foundation

extension URL : TextDocumentIdentifier {

    init(_ identifier: TextDocumentIdentifier, relativeTo root: URL? = .none) {
        // Bar is here to handle a URI prefixed with a `file://` scheme
        // e.g., file:///Users/ryan/Source/langserver-swift/Fixtures/ValidLayouts/Simple/Sources/main.swift
        // and
        // /Users/ryan/Source/langserver-swift/Fixtures/ValidLayouts/Simple/Sources/main.swift
        let bar = URLComponents(string: identifier.uri)?.path ?? identifier.uri
        self = URL(fileURLWithPath: bar, isDirectory: false, relativeTo: root)
    }

    public var uri: String {
        return self.path
    }

}

extension URL : Decodable {

    public static func decode(_ json: JSON) -> Decoded<URL> {
        switch json {
        case .string(let uri):
            return URL(string: uri).map(pure)
                ?? .typeMismatch(expected: "rawValue for \(self)", actual: json)
        default:
            return .typeMismatch(expected: "String", actual: json)
        }
    }

}
