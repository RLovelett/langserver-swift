import Dispatch
import Foundation
import JSONRPC
import XCGLogger

// Create a logger object with no destinations
let log = XCGLogger(identifier: "advancedLogger", includeDefaultDestinations: false)

// Create a destination for the system console log (via NSLog)
let systemDestination = AppleSystemLogDestination(identifier: "advancedLogger.systemDestination")

// Optionally set some configuration options
systemDestination.outputLevel = .verbose
systemDestination.showLogIdentifier = false
systemDestination.showFunctionName = true
systemDestination.showThreadName = true
systemDestination.showLevel = true
systemDestination.showFileName = true
systemDestination.showLineNumber = true
systemDestination.showDate = true

// Add the destination to the logger
log.add(destination: systemDestination)

// Add basic app info, version info etc, to the start of the logs
log.logAppDetails()

let capabilities = ServerCapabilities(
    textDocumentSync: .Full,
    hoverProvider: nil,
    completionProvider: nil,
    signatureHelpProvider: nil,
    definitiionProvider: false,
    referencesProvider: false,
    documentHighlighProvider: false,
    documentSymbolProvider: false,
    workspaceSymbolProvider: false,
    codeActionProvider: false,
    codeLensProvider: nil,
    documentFormattingProvider: false,
    documentRangeFormattingProvider: false,
    documentOnTypeFormattingProvider: nil,
    renameProvider: nil)
let initResult = InitializeResult(capabilities)

var workspace: Workspace?
var exitCode: Int32 = 1

let requestHandler: (JSONRPC.Request) -> (JSONRPC.Response) = { (request) in
    switch request.method {
    case "initialize":
        guard let parameters = InitializeParams(parse: request.params) else {
            let result = JSONRPC.Response.Result.Error(JSONRPC.PredefinedError.InvalidParams)
            return JSONRPC.Response(to: request.id, result: result)
        }
        workspace = parameters.rootPath.map(Workspace.init(at:))
        let response = JSONRPC.Response.Result.Success(initResult.toJSON)
        return JSONRPC.Response(to: request.id, result: response)
    case "textDocument/didOpen":
        guard let parameters = DidOpenTextDocumentParams(parse: request.params) else {
            let result = JSONRPC.Response.Result.Error(JSONRPC.PredefinedError.InvalidParams)
            return JSONRPC.Response(to: request.id, result: result)
        }
        _ = workspace?.open(parameters.textDocument)
        let response = JSONRPC.Response.Result.Success(nil)
        return JSONRPC.Response(to: request.id, result: response)
    case "textDocument/didChange":
        guard let parameters = DidChangeTextDocumentParams(parse: request.params) else {
            let result = JSONRPC.Response.Result.Error(JSONRPC.PredefinedError.InvalidParams)
            return JSONRPC.Response(to: request.id, result: result)
        }
        _ = workspace?.update(parameters)
        let response = JSONRPC.Response.Result.Success(nil)
        return JSONRPC.Response(to: request.id, result: response)
    case "textDocument/didClose":
        guard let parameters = DidCloseTextDocumentParams(parse: request.params) else {
            let result = JSONRPC.Response.Result.Error(JSONRPC.PredefinedError.InvalidParams)
            return JSONRPC.Response(to: request.id, result: result)
        }
        let response = JSONRPC.Response.Result.Success(nil)
        return JSONRPC.Response(to: request.id, result: response)
    case "textDocument/didSave":
        guard let parameters = DidSaveTextDocumentParams(parse: request.params) else {
            let result = JSONRPC.Response.Result.Error(JSONRPC.PredefinedError.InvalidParams)
            return JSONRPC.Response(to: request.id, result: result)
        }
        let response = JSONRPC.Response.Result.Success(nil)
        return JSONRPC.Response(to: request.id, result: response)
    case "textDocument/definition":
        fatalError("Not implemented yet.")
    case "textDocument/hover":
        fatalError("Not implemented yet.")
    case "textDocument/documentSymbol":
        fatalError("Not implemented yet.")
    case "textDocument/references":
        fatalError("Not implemented yet.")
    case "workspace/symbol":
        fatalError("Not implemented yet.")
    case "shutdown":
        workspace = nil
        // The server should exit with `success` code 0 if the shutdown request has been received
        // before; otherwise with `error` code 1.
        exitCode = 0
        let response = JSONRPC.Response.Result.Success(nil)
        return JSONRPC.Response(to: request.id, result: response)
    case "exit":
        exit(exitCode)
    default:
        let result = JSONRPC.Response.Result.Error(JSONRPC.PredefinedError.MethodNotFound)
        return JSONRPC.Response(to: request.id, result: result)
    }
}


private let header: [String : String] = [
    "Content-Type": "application/vscode-jsonrpc; charset=utf8"
]

let main = OperationQueue.main
let stdin = FileHandle.standardInput
stdin.waitForDataInBackgroundAndNotify()

// When new data is available
var dataAvailable : NSObjectProtocol!
dataAvailable = NotificationCenter.default.addObserver(forName: .NSFileHandleDataAvailable, object: stdin, queue: main) { (notification) -> Void in
    let buffer = stdin.availableData

    guard !buffer.isEmpty else {
        return stdin.waitForDataInBackgroundAndNotify()
    }

    let str = String(data: buffer, encoding: .utf8) ?? "Expected UTF-8 encoding."
    log.verbose(str)

    do {
        let message = try IncomingMessage(buffer)
        let response = requestHandler(message.content)
        let toSend = OutgoingMessage(header: header, content: response)
        /// If the request id is null then it is a notification and not a request
        if case RequestID.Null = message.content.id {}
        else {
            log.debug(toSend)
            FileHandle.standardOutput.write(toSend.data)
        }
    } catch let error as PredefinedError {
        let response = Response(to: .Null, result: .Error(error))
        let toSend = OutgoingMessage(header: header, content: response)
        log.debug(toSend)
        FileHandle.standardOutput.write(toSend.data)
    } catch {
        fatalError("TODO: Better error handeling. \(error)")
    }

    return stdin.waitForDataInBackgroundAndNotify()
}

// Launch the task
RunLoop.main.run()
//while RunLoop.main.run(mode: .defaultRunLoopMode, before: .distantFuture) {}
