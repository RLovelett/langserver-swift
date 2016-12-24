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

/// A directory on the local filesystem that contains all of the sources of the Swift project.
public struct Workspace {

    /// The fully qualified location of the `Workspace` on the filesystem.
    let root: URL

    /// All the Swift source documents on the filesystem in the `Workspace`.
    fileprivate var index: [ URL : TextDocument ] = [ : ]

    /// Attempt to create a `Workspace` from parameters provided via the language server protocol.
    ///
    /// If the parameters do not provide a `rootPath` the `Workspace` cannot be initialized and
    /// this optional initializer fails.
    ///
    /// - Parameter parameters: The parameters sent to the server from the client.
    public init?(_ parameters: InitializeParams) {
        guard let rootPath = parameters.rootPath else {
            return nil
        }
        self = Workspace(inDirectory: URL(fileURLWithPath: rootPath, isDirectory: true))
    }

    /// Initailize an instance of the `Workspace` for a given directory`.
    ///
    /// - Parameter inDirectory: A fully qulified on the filesystem to the `Workspace`.
    init(inDirectory: URL) {
        root = inDirectory
        let s = WorkspaceSequence(root: root).lazy
            .filter({ $0.isFileURL && $0.isFile })
            .filter({ $0.pathExtension.lowercased() == "swift" }) // Check if file is a Swift source file (e.g., has `.swift` extension)
            .flatMap(TextDocument.init)
            .map({ (key: $0.uri, value: $0) })
        let i = Dictionary(s)
        index = i
    }

    var isSwiftPackage: Bool {
        let pkg = root.appendingPathComponent("Package").appendingPathExtension("swift")
        return index.keys.contains(pkg)
    }

    var arguments: [String] {
        return index.values.map({ $0.uri.path })
    }

    /// A description to the client of the types of services this language server provides.
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

    /// Find a `TextDocument` in the `Workspace`.
    ///
    /// Essentially this is a `throw`-ing `subscript` for the `index` Dictionary.
    ///
    /// - Parameter uri: Fully-qualified path to the `TextDocument` to find.
    /// - Returns: The found `TextDocument` or `throws` if not found.
    /// - Throws: `WorkspaceError.notFound` if it cannot find the `TextDocument` in the `Workspace` `index`.
    func getSource(_ uri: URL) throws -> TextDocument {
        guard let source = index[uri] else {
            throw WorkspaceError.notFound(uri)
        }

        return source
    }

    // MARK: - Language Server Protocol methods

    /// Notify the `Workspace` that the client has opened a document in the workspace.
    ///
    /// - Note: If the `TextDocument` cannot be found in the `Workspace` `index` it is automatically
    /// added to the `index`.
    ///
    /// - Parameter document: Information about which `TextDocument` was opened by the client.
    public mutating func open(byClient document: DidOpenTextDocumentParams) {
        let url = document.textDocument.uri
        index[url] = document.textDocument
    }

    /// Notify the `Workspace` that the client has modified the contents of a document in the workspace.
    ///
    /// - Parameter document: Information about which `TextDocument` was modified by the client.
    /// - Throws: `WorkspaceError.notFound` if it cannot find the `TextDocument` in the `Workspace` `index`.
    public mutating func update(byClient document: DidChangeTextDocumentParams) throws {
        guard let changes = document.contentChanges.first else { return }
        let url = document.textDocument.uri
        let updated = try getSource(url).update(version: document.textDocument.version, andText: changes.text)
        index[url] = updated
    }

    /// Notify the `Workspace` that the client has closed the `TextDocument` and that it can get the truth
    /// about the `TextDocument` from the file system.
    ///
    /// - Parameter document: Information about which `TextDocument` was closed by the client.
    public mutating func close(byClient document: DidCloseTextDocumentParams) {
        let url = document.textDocument.uri
        index[url] = TextDocument(url)
    }

    private func getCursor(forText at: TextDocumentPositionParams) throws -> Cursor? {
        let url = at.textDocument.uri
        let source = try getSource(url)
        let offset = try Int64(source.lines.byteOffset(at: at.position))

        // SourceKit may send back JSON that is an empty object. This is _not_ an error condition.
        // So we have to seperate SourceKit throwing an error from SourceKit sending back a
        // "malformed" Cursor structure.
        let json: Any = try Request.cursorInfo(file: at.textDocument.uri.path, offset: offset, arguments: arguments).failableSend()

        return Cursor.decode(JSON(json)).value
    }

    /// Find the definition of a symbol in the `Workspace` and provide the `Location` of same definition.
    ///
    /// - Parameter at: A `TextDocument` and a position inside that document.
    /// - Returns: `Location` of the definition of the symbol.
    /// - Throws: `WorkspaceError` for any of a number of reasons. See: `WorkspaceError` for more information.
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

    /// Find information about a symbol in the `Workspace`.
    ///
    /// - Parameter at: A `TextDocument` and a position inside that document.
    /// - Returns: `Hover` information about the requested symbol.
    /// - Throws: `WorkspaceError` for any of a number of reasons. See: `WorkspaceError` for more information.
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

    /// Provide information about possible code-completion items to be presented in the client.
    ///
    /// - Parameter at: A `TextDocument` and a position inside that document.
    /// - Returns: An `Array` of `CompletionItems` regarding information at the location.
    /// - Throws: `WorkspaceError` for any of a number of reasons. See: `WorkspaceError` for more information.
    public func complete(forText at: TextDocumentPositionParams) throws -> [CompletionItem] {
        let url = at.textDocument.uri
        let source = try getSource(url)
        let offset = try Int64(source.lines.byteOffset(at: at.position))
        let request = Request.codeCompletionRequest(
            file: at.textDocument.uri.path,
            contents: source.text,
            offset: offset,
            arguments: arguments)
        return request.decode().value ?? []
    }

}
