//
//  handle.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/22/16.
//
//

import Foundation
import JSONRPC
import LanguageServerProtocol

var workspace: Workspace?
var exitCode: Int32 = 1

func handle(_ request: Request) -> Response {
    do {
        switch request.method {
        case "initialize":
            let parameters: WorkspaceInitializer = try request.parse()
            workspace = Workspace(parameters)
            let response = Response(is: WorkspaceInitializationResult(workspace!.capabilities), for: request.id)
            return response
        case "textDocument/didOpen":
            fatalError("Not implemented yet.")
        case "textDocument/didChange":
            fatalError("Not implemented yet.")
        case "textDocument/didClose":
            fatalError("Not implemented yet.")
        case "textDocument/didSave":
            fatalError("Not implemented yet.")
        case "textDocument/definition":
            let parameters: SourcePosition = try request.parse()
            let location = try workspace!.findDeclaration(forText: parameters)
            let response = Response(is: location, for: request.id)
            return response
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
            return Response(is: EmptyMessage(), for: request.id)
        case "exit":
            exit(exitCode)
        default:
            throw PredefinedError.methodNotFound
        }
    } catch let error as ServerError {
        return Response(is: error, for: request.id)
    } catch {
        return Response(is: PredefinedError.invalidParams, for: request.id)
    }
}
