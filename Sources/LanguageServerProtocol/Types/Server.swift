//
//  Workspace.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 10/25/16.
//
//

import Argo
import struct Basic.AbsolutePath
import class Basic.DiagnosticsEngine
import class Basic.Process
import struct Build.BuildParameters
import class Build.BuildPlan
import enum Build.TargetDescription
import Commands
import Foundation
#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
import os.log
#endif
import struct PackageGraph.PackageGraphRootInput
import class PackageLoading.ManifestLoader
import class PackageModel.ResolvedTarget
import SourceKitter
import struct Utility.BuildFlags
import class Workspace.Workspace

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
@available(macOS 10.12, *)
private let log = OSLog(subsystem: "me.lovelett.langserver-swift", category: "Workspace")
#endif

/// Find the bin directory that contains the Swift compiler.
///
/// - Warning: This is only really working on macOS.
///
/// - Returns: The absolute path to the bin directory containing the Swift compiler.
func findBinDirectory() -> AbsolutePath {
    #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    let whichSwiftcArgs = ["xcrun", "--find", "swiftc"]
    // No value in env, so search for `clang`.
    let foundPath = (try? Process.checkNonZeroExit(arguments: whichSwiftcArgs).chomp()) ?? ""
    guard !foundPath.isEmpty else {
        // If `xcrun` fails just use a "default"; still might not work.
        return AbsolutePath("/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin")
    }
    return AbsolutePath(foundPath).parentDirectory
    #else
    return AbsolutePath("/usr/bin/swiftc").parentDirectory
    #endif
}

/// A directory on the local filesystem that contains all of the sources of the Swift project.
public class Server {

    /// All the Swift source documents on the filesystem in the `Workspace`.
    fileprivate var modules: Set<SwiftModule> = []

    private let sourceKitSession: SourceKit.Session

    /// Initialize using parameters provided by the client.
    ///
    /// If the parameters do not provide a `rootPath` the `Workspace` cannot be initialized and
    /// this optional initializer fails.
    ///
    /// - Parameter parameters: The parameters sent to the server from the client.
    public convenience init?(_ parameters: InitializeParams) {
        guard let rootPath = parameters.rootPath.map(AbsolutePath.init) else {
            return nil
        }
        self.init(inDirectory: rootPath)
    }

    /// Initailize the server for a given directory on the local filesystem.
    ///
    /// - Parameter inDirectory: A fully qulified on the filesystem to the `Server`.
    init(inDirectory path: AbsolutePath) {
        let buildPath = path.appending(component: ".build")
        let edit = path.appending(component: "Packages")
        let pins = path.appending(component: "Package.resolved")
        let binDirectory = findBinDirectory()
        let destination = try! Destination.hostDestination(binDirectory)
        let toolchain = try! UserToolchain(destination: destination)
        let manifestLoader = ManifestLoader(resources: toolchain.manifestResources)
        let delegate = ToolWorkspaceDelegate()
        let ws = Workspace(dataPath: buildPath, editablesPath: edit, pinsFile: pins, manifestLoader: manifestLoader, delegate: delegate)
        let root = PackageGraphRootInput(packages: [path])
        let engine = DiagnosticsEngine()
        let pg = ws.loadPackageGraph(root: root, diagnostics: engine)
        let buildFlags = BuildFlags()
        let parameters = BuildParameters(dataPath: buildPath, configuration: .debug, toolchain: toolchain, flags: buildFlags)
        let plan = try! BuildPlan(buildParameters: parameters, graph: pg)
        modules = Set(plan.targetMap.map { SwiftModule(target: $0.key, description: $0.value) })
        sourceKitSession = SourceKit.Session()
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

    /// Find a `TextDocument`.
    ///
    /// Essentially this is a `throw`-ing `subscript` for the `index` Dictionary.
    ///
    /// - Parameter uri: Fully-qualified path to the `TextDocument` to find.
    /// - Returns: The found `TextDocument` or `throws` if not found.
    /// - Throws: `WorkspaceError.notFound` if it cannot find the `TextDocument` in the `Workspace` `index`.
    func getSource(_ uri: URL) throws -> (SwiftModule, TextDocument) {
        for module in modules {
            guard let source = module.sources[uri] else { continue }
            return (module, source)
        }
        throw WorkspaceError.notFound(uri)
    }

    // MARK: - Language Server Protocol methods

    public func receive(notification parameters: DidChangeWatchedFilesParams) {

    }

    /// Notify the `Server` that the client has opened a document in the workspace.
    ///
    /// - Parameter document: Information about which `TextDocument` was opened by the client.
    public func client(opened document: DidOpenTextDocumentParams) {
        let url = document.textDocument.uri
        if var module = modules.lazy.first(where: { $0.root.isParent(of: url) }) {
            module.sources[url] = document.textDocument
            modules.update(with: module)
        }
    }

    /// Notify the `Server` that the client has modified the contents of a document in the workspace.
    ///
    /// - Parameter document: Information about which `TextDocument` was modified by the client.
    /// - Throws: `WorkspaceError.notFound` if it cannot find the `TextDocument` in the `Server` `index`.
    public func client(modified document: DidChangeTextDocumentParams) throws {
        guard let changes = document.contentChanges.first else { return }
        let url = document.textDocument.uri
        var (module, source) = try getSource(url)
        let updated = source.update(version: document.textDocument.version, andText: changes.text)
        module.sources[url] = updated
        modules.update(with: module)
    }

    /// Notify the `Server` that the client has closed the `TextDocument` and that it can get the truth
    /// about the `TextDocument` from the file system.
    ///
    /// - Parameter document: Information about which `TextDocument` was closed by the client.
    public func client(closed document: DidCloseTextDocumentParams) {
        let url = document.textDocument.uri
        let document = TextDocument(url)
        if var module = modules.lazy.first(where: { $0.root.isParent(of: url) }) {
            module.sources[url] = document
            modules.update(with: module)
        }
    }

    private func getCursor(forText at: TextDocumentPositionParams) throws -> Cursor? {
        let url = at.textDocument.uri
        let (module, source) = try getSource(url)
        let offset = try Int64(source.lines.byteOffset(at: at.position))

        // SourceKit may send back JSON that is an empty object. This is _not_ an error condition.
        // So we have to seperate SourceKit throwing an error from SourceKit sending back a
        // "malformed" Cursor structure.
        let result = SourceKit.CursorInfo(source: source.text, source: at.textDocument.uri, offset: offset, args: module.arguments)
            .request()
            .flatMap(Cursor.decode)
        return result.value
    }

    /// Find the definition of a symbol and provide the `Location` of same definition.
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
            let (_, source) = try getSource(filepath)
            let range = try source.lines.selection(startAt: Int(symbolOffset), length: Int(symbolLength))
            let location = Location(uri: filepath.absoluteString, range: range)
            return [location]
        case .system(_):
            return []
        }
    }

    /// Find information about a symbol.
    ///
    /// - Parameter at: A `TextDocument` and a position inside that document.
    /// - Returns: `Hover` information about the requested symbol.
    /// - Throws: `WorkspaceError` for any of a number of reasons. See: `WorkspaceError` for more information.
    public func cursor(forText at: TextDocumentPositionParams) throws -> Hover {
        // If the JSON is "malformed" (e.g., empty object) just return an empty `String`. No errors.
        guard let c = try getCursor(forText: at) else {
            return Hover(contents: [""], range: .none)
        }

        let contents = [c.annotatedDeclaration, c.fullyAnnotatedDeclaration, c.documentationAsXML].compactMap { $0 }

        switch c.defined {
        case let .local(filepath, symbolOffset, symbolLength):
            let (_, source) = try getSource(filepath)
            let range = try source.lines.selection(startAt: Int(symbolOffset), length: Int(symbolLength))
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
        let (module, source) = try getSource(url)
        let offset = try Int64(source.lines.byteOffset(at: at.position))
        #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
        if #available(macOS 10.12, *) {
            os_log("%{public}@", log: log, type: .default, url as NSURL)
            os_log("Line %d, character %d, byte %d", log: log, type: .default, at.position.line, at.position.character, offset)
            os_log("%{public}@", log: log, type: .default, module.arguments.joined(separator: ", "))
        }
        #endif
        let result = SourceKit.CodeComplete(source: source.text, source: url, offset: offset, args: module.arguments)
            .request()
            .flatMap({ decodedJSON($0, forKey: "key.results") })
            .flatMap({ [CompletionItem].decode($0) })
        return result.value ?? []
    }

}
