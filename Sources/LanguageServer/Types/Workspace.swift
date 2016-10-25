//
//  Workspace.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 10/25/16.
//
//

import Foundation

struct SwiftSource {

}

struct Workspace {
    let root: URL
    private var sources: [ URL : SwiftSource ] = [ : ]

    init(at path: String) {
        root = URL(fileURLWithPath: path, isDirectory: true)
        let seq = WorkspaceSequence(root: root)
        let files = seq.lazy.flatMap { (possibleSource: URL) -> URL? in
            guard let resourceValues = try? possibleSource.resourceValues(forKeys: [.isDirectoryKey]), let isDirectory = resourceValues.isDirectory, !isDirectory else {
                return nil
            }
            guard possibleSource.pathExtension.lowercased() == "swift" else {
                return nil
            }
            return possibleSource
        }.map { (key: $0, value: SwiftSource()) }
        sources = Dictionary(files)
    }

    var isSwiftPackage: Bool {
        let pkg = root.appendingPathComponent("Package").appendingPathExtension("swift")
        return sources.keys.contains(pkg)
    }

    /// <#Description#>
    ///
    /// - Parameter document: <#document description#>
    /// - Returns: <#return value description#>
    mutating func open(_ document: TextDocumentItem) -> SwiftSource {
        let url = URL(fileURLWithPath: document.uri)
        return sources[url] ?? SwiftSource()
    }

    mutating func update(_ document: DidChangeTextDocumentParams) -> SwiftSource {
        return SwiftSource()
    }

}
