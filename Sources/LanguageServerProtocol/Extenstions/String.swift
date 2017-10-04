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

}
