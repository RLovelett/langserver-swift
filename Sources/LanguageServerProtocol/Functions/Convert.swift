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
    var result = ""
    var lastRange = sourceKit.startIndex..<sourceKit.startIndex
    var cursorIndex = 0
    regex.enumerateMatches(in: sourceKit, options: [], range: sourceKit.nsrange) { (x: NSTextCheckingResult?, _, _) -> Void in
        guard
            let matchRange = (x?.rangeAt(0)).flatMap({ sourceKit.range(from: $0) }),
            let group = (x?.rangeAt(1)).flatMap({ sourceKit.substring(with: $0) })
        else {
            return
        }
        cursorIndex += 1
        let leading = lastRange.upperBound..<matchRange.lowerBound
        result += sourceKit.substring(with: leading)
        result += "{{\(cursorIndex):\(group)}}"
        lastRange = matchRange
    }
    result += sourceKit.substring(from: lastRange.upperBound)
    return pure(result)
}
