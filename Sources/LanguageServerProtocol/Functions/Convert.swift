//
//  Convert.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/10/16.
//
//

import Argo
import Foundation
import Regex

fileprivate let pattern = try! Regex(pattern: "<#T##([^#]+)#(?:#[^#]+#)?>", groupNames: "type")

/// Convert a SourceKit (read: Xcode) style snippet to a
/// [TextMate snippet syntax](https://manual.macromates.com/en/snippets).
///
/// Example:
/// ========
///
/// ```
/// let str = "fatalError(<#T##message: String##String#>)"
/// convert(str).value! // "fatalError({{1:message: String}})"
/// ```
///
/// - Parameter sourceKit: A `String` possibly containing an SourceKit style snippet.
/// - Returns: A `String` where any SourceKit style snippets have been converted to TextMate
/// snippets.
func convert(_ sourceKit: String) -> Decoded<String> {
    var cursorIndex = 0
    return pure(pattern.replaceAll(in: sourceKit) { match in
        guard let group = match.group(at: 1) else { return nil }
        cursorIndex += 1
        return "{{\(cursorIndex):\(group)}}"
    })
}
