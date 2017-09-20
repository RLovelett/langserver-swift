//
//  InitializeParams.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/21/16.
//
//

import Argo
import Curry
import Runes

/// The initialize request is sent as the first request from the client to the server.
public struct InitializeParams {

    /// The process Id of the parent process that started the server. Is null if the process has not
    /// been started by another process.
    /// If the parent process is not alive then the server should exit (see exit notification) its
    /// process.
    let processId: Int?

    /// The rootPath of the workspace. Is null if no folder is open.
    let rootPath: String?

    /// User provided initialization options.
    let initializationOptions: Any?

}

extension InitializeParams : Argo.Decodable {

    public static func decode(_ json: JSON) -> Decoded<InitializeParams> {
        let p: Decoded<Int?> = json <|? "processId"
        let r: Decoded<String?> = json <|? "rootPath"
        return curry(InitializeParams.init) <^> p <*> r <*> pure(.none)
    }
    
}
