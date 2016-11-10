//
//  WorkspaceSequence.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 10/25/16.
//
//

import Foundation

/// Provide a type to iterate over the contents of a directory on the file system.
struct WorkspaceSequence : Sequence {

    let root: URL

    func makeIterator() -> AnyIterator<URL> {
        guard let enumerator = FileManager.default.enumerator(at: self.root, includingPropertiesForKeys: [.isDirectoryKey], options: .skipsHiddenFiles, errorHandler: nil) else {
            return AnyIterator { nil }
        }
        return AnyIterator {
            return enumerator.nextObject() as? URL
        }
    }

}
