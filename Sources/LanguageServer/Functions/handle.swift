//
//  handle.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/22/16.
//
//

import Argo
import BaseProtocol
import Foundation
import LanguageServerProtocol

var workspace: Workspace!
var exitCode: Int32 = 1

func handle(_ request: Request) -> Response {
    do {
        switch request.method {
        case "initialize":
            let parameters: InitializeParams = try request.parse()
            workspace = Workspace(parameters)
            let response = Response(to: request, is: InitializeResult(workspace.capabilities))
            return response
        case "workspace/didChangeWatchedFiles":
            let parameters: DidChangeWatchedFilesParams = try request.parse()
            workspace.receive(notification: parameters)
            return Response(to: request, is: JSON.null)
        case "textDocument/didChange":
            let document: DidChangeTextDocumentParams = try request.parse()
            try workspace.client(modified: document)
            return Response(to: request, is: JSON.null)
        case "textDocument/didClose":
            let document: DidCloseTextDocumentParams = try request.parse()
            workspace.client(closed: document)
            return Response(to: request, is: JSON.null)
        case "textDocument/didOpen":
            let document: DidOpenTextDocumentParams = try request.parse()
            workspace.client(opened: document)
            return Response(to: request, is: JSON.null)
//        case "textDocument/didSave":
//            fatalError("\(request.method) is not implemented yet.")
        case "textDocument/completion":
            let parameters: TextDocumentPositionParams = try request.parse()
            let items = try workspace.complete(forText: parameters)
            let response = Response(to: request, is: items)
            return response
        case "textDocument/definition":
            let parameters: TextDocumentPositionParams = try request.parse()
            let location = try workspace.findDeclaration(forText: parameters)
            let response = Response(to: request, is: location)
            return response
        case "textDocument/hover":
            let parameters: TextDocumentPositionParams = try request.parse()
            let hover = try workspace.cursor(forText: parameters)
            let response = Response(to: request, is: hover)
            return response
//        case "textDocument/documentSymbol":
//            fatalError("\(request.method) is not implemented yet.")
//        case "textDocument/references":
//            fatalError("\(request.method) is not implemented yet.")
//        case "workspace/symbol":
//            fatalError("\(request.method) is not implemented yet.")
        case "shutdown":
            workspace = nil
            // The server should exit with `success` code 0 if the shutdown request has been received
            // before; otherwise with `error` code 1.
            exitCode = 0
            return Response(to: request, is: JSON.null)
        case "exit":
            exit(exitCode)
        default:
            throw PredefinedError.methodNotFound
        }
    } catch let error as ServerError {
        return Response(to: request, is: error)
    } catch {
        return Response(to: request, is: PredefinedError.invalidParams)
    }
}
