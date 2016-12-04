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

fileprivate let extractSource: (URL) -> (key: URL, value: TextDocument)? = {
    guard let src = TextDocument($0) else {
        return nil
    }
    return (key: $0, value: src)
}

public struct Workspace {

    let root: URL

    fileprivate var index: [ URL : TextDocument ] = [ : ]

    public init?(_ parameters: InitializeParams) {
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
        let completion = CompletionOptions(resolveProvider: false, triggerCharacters: [
            " ", ".", ":", "<", "("
        ])

        return ServerCapabilities(
            textDocumentSync: TextDocumentSyncKind.Full,
            hoverProvider: false,
            completionProvider: completion,
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

    func getSource(_ uri: URL) throws -> TextDocument {
        guard let source = index[uri] else {
            throw WorkspaceError.notFound(uri)
        }

        return source
    }

    public func findDeclaration(forText at: TextDocumentPositionParams) throws -> Location {
        let url = URL(at.textDocument, relativeTo: root)
        let source = try getSource(url)
        let offset = try Int64(source.lines.byteOffset(at: at.position))

        guard let c: Cursor = Request.cursorInfo(file: at.textDocument.uri, offset: offset, arguments: arguments).decode().value else {
            throw WorkspaceError.sourceKit
        }

        let range = try getSource(c.uri).lines.selection(for: c)
        let location = Location(uri: c.uri.absoluteString, range: range)
        return location
    }

}

extension Workspace {

    public func complete(forText at: TextDocumentPositionParams) throws -> [CompletionItem] {
        let url = URL(at.textDocument, relativeTo: root)
        let source = try getSource(url)
        let offset = try Int64(source.lines.byteOffset(at: at.position))
        let request = Request.codeCompletionRequest(
            file: at.textDocument.uri,
            contents: source.text,
            offset: offset,
            arguments: arguments)
        return request.decode().value ?? []
    }

}

extension Workspace {

    public mutating func open(byClient document: DidOpenTextDocumentParams) {
        let url = URL(document.textDocument, relativeTo: root)
        index[url] = document.textDocument
    }

    public mutating func update(byClient document: DidChangeTextDocumentParams) throws {
        guard let changes = document.contentChanges.first else { return }
        let url = URL(document.textDocument, relativeTo: root)
        let updated = try getSource(url).update(version: document.textDocument.version, andText: changes.text)
        index[url] = updated
    }

    public mutating func close(byClient document: DidCloseTextDocumentParams) {
        let url = URL(document.textDocument, relativeTo: root)
        index[url] = TextDocument(url)
    }

}
