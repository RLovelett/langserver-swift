//
//  Workspace.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 10/25/16.
//
//

import Argo
import Foundation
import SourceKittenFramework

fileprivate let isFile: (URL) -> Bool = {
    guard let resourceMap = try? $0.resourceValues(forKeys: [.isDirectoryKey]), let isDirectory = resourceMap.isDirectory else {
        return false
    }
    return !isDirectory
}

fileprivate let isSwiftSource: (URL) -> Bool = {
    return $0.pathExtension.lowercased() == "swift"
}

fileprivate let extractSource: (URL) -> (key: URL, value: SwiftSource)? = {
    guard let src = SwiftSource($0) else {
        return nil
    }
    return (key: $0, value: src)
}

public struct Workspace {

    let root: URL

    fileprivate var index: [ URL : SwiftSource ] = [ : ]

    public init?(_ parameters: WorkspaceInitializer) {
        guard let rootPath = parameters.rootPath else {
            return nil
        }
        self = Workspace(inDirectory: URL(fileURLWithPath: rootPath, isDirectory: true))
    }

    init(inDirectory: URL) {
        root = inDirectory
        let s = WorkspaceSequence(root: root).lazy
            .filter(isFile)
            .filter(isSwiftSource)
            .flatMap(extractSource)
        let i = Dictionary(s)
        index = i
    }

    var isSwiftPackage: Bool {
        let pkg = root.appendingPathComponent("Package").appendingPathExtension("swift")
        return index.keys.contains(pkg)
    }

    var arguments: [String] {
        return index.values.map({ $0.file.path })
    }

}

extension Workspace {

    public var capabilities: ServerCapabilities {
        return WorkspaceCapabilities(
            textDocumentSync: TextDocumentSyncKind.Full,
            hoverProvider: false,
            definitiionProvider: true,
            referencesProvider: false,
            documentHighlighProvider: false,
            documentSymbolProvider: false,
            workspaceSymbolProvider: false,
            codeActionProvider: false,
            documentFormattingProvider: false,
            documentRangeFormattingProvider: false,
            renameProvider: false)
    }

}

extension Workspace {

    private func getSource(_ uri: URL) throws -> SwiftSource {
        guard let source = index[uri] else {
            throw WorkspaceError.notFound(uri)
        }

        return source
    }

    public func findDeclaration(forText at: SourcePosition) throws -> Location {
        let url = URL(at.textDocument, relativeTo: root)
        let source = try getSource(url)
        let offset = try Int64(source.lines.byteOffset(at: at.position))

        guard let c: Cursor = Request.cursorInfo(file: at.textDocument.uri, offset: offset, arguments: arguments).x().value else {
            throw WorkspaceError.sourceKit
        }

        let range = try getSource(c.uri).lines.selection(for: c)
        let location = WorkspaceLocation(uri: c.uri.absoluteString, range: range)
        return location
    }

}
