//
//  String.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/11/16.
//
//

import Foundation

extension String {

    /// Create a new `String` by adding the prefix, if defined, to the beginning of the `String`.
    ///
    /// Example:
    /// ========
    ///
    /// ```
    /// "base".prepend(Optional<String>.none, separator: "!!")           // Returns: "base"
    /// "base".prepend(Optional<String>.some("prefix"), separator: "!!") // Returns "prefix!!base"
    /// ```
    ///
    /// - Parameters:
    ///   - prefix: If this is `.some(String)` prepend it and the `separator` to the begining.
    ///   - separator: The value to go between the `prefix` and `base`.
    /// - Returns: A new `String` with the `prefix` and `separator` possibly prepended.
    func prepend(_ prefix: String?, separator: String) -> String {
        guard let p = prefix else { return self }
        return "\(p)\(separator)\(self)"
    }

    /// An `NSRange` that represents the full range of the `String`.
    var nsrange: NSRange {
        return NSRange(location: 0, length: utf16.count)
    }

    /// Returns a string object containing the characters of the `String` that lie within a given range.
    ///
    /// - Parameter nsrange: An `NSRange` that represents the indicies to copy.
    /// - Returns: A sub-`String` if the range can be converted to `String` indices`, or `.none` otherwise.
    func substring(with nsrange: NSRange) -> String? {
        guard let range = self.range(from: nsrange) else { return nil }
        return self.substring(with: range)
    }

    /// Convert `NSRange` to `Range<Index>` if the `NSRange.location` is within the index of the `String`.
    ///
    /// - Parameter nsrange: The `NSRange` to convert.
    /// - Returns: A range equivalent to the given `NSRange`, or `.none` if the `location`
    /// is beyond the `String` indicies.
    func range(from nsrange: NSRange) -> Range<Index>? {
        guard let start = Index(UTF16Index(nsrange.location), within: self) else {
            return .none
        }
        return start..<self.index(start, offsetBy: nsrange.length)
    }

}
