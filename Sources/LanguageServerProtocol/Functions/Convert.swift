//
//  Convert.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/10/16.
//
//

import Argo
import Foundation

fileprivate let regex = try! NSRegularExpression(pattern: "<#T##([^#]+)#(?:#[^#]+#)?>", options: [])

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
    let matches = regex.matches(in: sourceKit, options: [], range: NSRange(sourceKit.startIndex..., in: sourceKit))
    var result = matches.enumerated().reduce(into: ("", sourceKit.startIndex)) { (previous: inout (String, String.Index), next: (offset: Int, element: NSTextCheckingResult)) in
        guard
            let matchRange = Range(next.element.range(at: 0), in: sourceKit),
            let groupRange = Range(next.element.range(at: 1), in: sourceKit)
        else {
            return
        }
        let group = sourceKit[groupRange]
        let cursorIndex = next.offset + 1
        previous.0 += sourceKit[previous.1..<matchRange.lowerBound]
        previous.0 += "{{\(cursorIndex):\(group)}}"
        previous.1 = matchRange.upperBound
    }
    result.0 += sourceKit[result.1...]
    return pure(result.0)
}
