//
//  CommonRoot.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/24/16.
//
//

import Foundation

/// Extract the Swift module root directory.
///
/// The module root directory is the longest common path between two sources in the module. Or
/// if there is only 1 source then its just the last directory.
///
/// ```
/// let urls = [
///   URL(fileURLWithPath: "/module/Sources/dir1/dir1.A/foo.swift", isDirectory: false),
///   URL(fileURLWithPath: "/module/Sources/dir1/bar.swift", isDirectory: false)
/// ]
/// commonRoot(urls) // Returns /module/Sources/dir1/
/// ```
///
/// - Precondition: The collection cannot be empty.
///
/// - Parameter sources: A collection of fully qualified paths to Swift sources in a module.
/// - Returns: The root directory of the collection.
func commonRoot<C: Collection>(_ sources: C) -> URL
    where C.Iterator.Element == URL
{
    precondition(!sources.isEmpty, "A module must have at least 1 source.")
    if sources.count == 1, let single = sources.first {
        return single.deletingLastPathComponent()
    } else {
        let first = sources[sources.startIndex]
        let second = sources[sources.index(after: sources.startIndex)]
        return URL(fileURLWithPath: first.path.commonPrefix(with: second.path), isDirectory: true)
    }
}
