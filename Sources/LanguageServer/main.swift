import Dispatch
import Foundation
import JSONRPC

struct InitializeParams {
    let processId: Int
    let rootPath: String
    let initializationOptions: Any?

    init?(parse json: Any?) {
        guard let dict = json as? [String : Any] else {
            return nil
        }

        guard let id = dict["processId"] as? Int else {
            return nil
        }

        guard let path = dict["rootPath"] as? String else {
            return nil
        }

        self.processId = id
        self.rootPath = path
        self.initializationOptions = .none
    }
}

let capabilities = ServerCapabilities(textDocumentSync: .Full, hoverProvider: false, completionProvider: nil, signatureHelpProvider: nil, definitiionProvider: false, referencesProvider: false, documentHighlighProvider: false, documentSymbolProvider: false, workspaceSymbolProvider: false, codeActionProvider: false, codeLensProvider: nil, documentFormattingProvider: false, documentRangeFormattingProvider: false, documentOnTypeFormattingProvider: nil, renameProvider: nil)

let requestHandler: (JSONRPC.Request) -> (JSONRPC.Response) = { (request) in
    switch request.method {
    case "initialize":
        guard let parameters = InitializeParams(parse: request.params) else {
            let result = JSONRPC.Response.Result.Error(JSONRPC.PredefinedError.InvalidParams)
            return JSONRPC.Response(to: request.id, result: result)
        }
        let response = JSONRPC.Response.Result.Success(capabilities.toJSON)
        return JSONRPC.Response(to: request.id, result: response)
    case "shutdown":
        let response = JSONRPC.Response.Result.Success(nil)
        return JSONRPC.Response(to: request.id, result: response)
    default:
        print(request)
        let result = JSONRPC.Response.Result.Error(JSONRPC.PredefinedError.MethodNotFound)
        return JSONRPC.Response(to: request.id, result: result)
    }
}

do {
    let server = try Server(listen: 1337, closure: requestHandler)
    server.start()

    dispatchMain()
} catch {
    fatalError("TODO: Better error handling. \(error)")
}
