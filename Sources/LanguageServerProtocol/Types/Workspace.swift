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
            .filter({ $0.isFileURL && $0.isFile })
            .filter({ $0.pathExtension.lowercased() == "swift" }) // Check if file is a Swift source file (e.g., has `.swift` extension)
            .flatMap(TextDocument.init)
            .map({ (key: $0.file, value: $0) })
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
            hoverProvider: true,
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

    private func getCursor(forText at: TextDocumentPositionParams) throws -> Cursor? {
        let url = URL(at.textDocument, relativeTo: root)
        let source = try getSource(url)
        let offset = try Int64(source.lines.byteOffset(at: at.position))

        // SourceKit may send back JSON that is an empty object. This is _not_ an error condition.
        // So we have to seperate SourceKit throwing an error from SourceKit sending back a
        // "malformed" Cursor structure.
        let json: Any = try Request.cursorInfo(file: at.textDocument.uri, offset: offset, arguments: arguments).failableSend()

        return Cursor.decode(JSON(json)).value
    }

    public func findDeclaration(forText at: TextDocumentPositionParams) throws -> [Location] {
        // If the JSON is "malformed" (e.g., empty object) just return an empty `Array`. No errors.
        guard let c = try getCursor(forText: at) else {
            return []
        }

        switch c.defined {
        case let .local(filepath, symbolOffset, symbolLength):
            let range = try getSource(filepath).lines.selection(startAt: Int(symbolOffset), length: Int(symbolLength))
            let location = Location(uri: filepath.absoluteString, range: range)
            return [location]
        case .system(_):
            return []
        }
    }

    public func cursor(forText at: TextDocumentPositionParams) throws -> Hover {
        // If the JSON is "malformed" (e.g., empty object) just return an empty `String`. No errors.
        guard let c = try getCursor(forText: at) else {
            return Hover(contents: [""], range: .none)
        }

        let contents = [c.annotatedDeclaration, c.fullyAnnotatedDeclaration, c.documentationAsXML].flatMap({ $0 })

        switch c.defined {
        case let .local(filepath, symbolOffset, symbolLength):
            let range = try getSource(filepath).lines.selection(startAt: Int(symbolOffset), length: Int(symbolLength))
            return Hover(contents: contents, range: range)
        case .system(_):
            return Hover(contents: contents, range: .none)
        }
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
