//
//  InitializeParams.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/21/16.
//
//

/// The initialize request is sent as the first request from the client to the server.
public protocol InitializeParams {

    /// The process Id of the parent process that started the server. Is null if the process has not
    /// been started by another process.
    /// If the parent process is not alive then the server should exit (see exit notification) its
    /// process.
    var processId: Int? { get }

    /// The rootPath of the workspace. Is null if no folder is open.
    var rootPath: String? { get }

    /// User provided initialization options.
    var initializationOptions: Any? { get }

}
