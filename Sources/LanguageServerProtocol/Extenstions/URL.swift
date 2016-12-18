//
//  URL.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/23/16.
//
//

import Argo
import Foundation

extension URL {

    /// Returns `true` if the URL is not a directory on the filesystem.
    var isFile: Bool {
        guard let resourceMap = try? self.resourceValues(forKeys: [.isDirectoryKey]), let isDirectory = resourceMap.isDirectory else {
            return false
        }
        return !isDirectory
    }

    /// Test if a `URL` is a child node of a parent.
    ///
    /// - Parameter child: The URL to test.
    /// - Returns: True if the argument is a child of this instance.
    func isParent(of child: URL) -> Bool {
        return child.path.hasPrefix(self.path)
    }

}

extension URL : TextDocumentIdentifier {

    public var uri: URL {
        return self
    }

}

extension URL : Decodable {

    /// Convert a `JSON.string` case into a `URL`.
    ///
    /// This decoder has intelligence about dealing with directories and `file://` scheme prefixed strings.
    ///
    /// - Parameter json: A `JSON.string` containing a valid `URL`.
    /// - Returns: The decoded `URL`.
    public static func decode(_ json: JSON) -> Decoded<URL> {
        switch json {
        case .string(let uri):
            let isDirectory = (uri as NSString).pathExtension.isEmpty
            // Bar is here to handle a URI prefixed with a `file://` scheme
            // e.g., file:///Users/ryan/Source/langserver-swift/Fixtures/ValidLayouts/Simple/Sources/main.swift
            // and
            // /Users/ryan/Source/langserver-swift/Fixtures/ValidLayouts/Simple/Sources/main.swift
            let bar = URLComponents(string: uri)?.path ?? uri
            return pure(URL(fileURLWithPath: bar, isDirectory: isDirectory))
        default:
            return .typeMismatch(expected: "String", actual: json)
        }
    }

}
