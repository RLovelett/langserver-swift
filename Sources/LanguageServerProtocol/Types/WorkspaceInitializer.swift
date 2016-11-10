//
//  WorkspaceInitializer.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/23/16.
//
//

import Argo
import Curry
import Runes

public struct WorkspaceInitializer : InitializeParams {

    /// The process Id of the parent process that started the server. Is null if the process has not
    /// been started by another process.
    /// If the parent process is not alive then the server should exit (see exit notification) its
    /// process.
    public let processId: Int?

    /// The rootPath of the workspace. Is null if no folder is open.
    public let rootPath: String?

    /// User provided initialization options.
    public let initializationOptions: Any?

}

extension WorkspaceInitializer : Decodable {

    public static func decode(_ json: JSON) -> Decoded<WorkspaceInitializer> {
        let p: Decoded<Int?> = json <|? "processId"
        let r: Decoded<String?> = json <|? "rootPath"
        return curry(WorkspaceInitializer.init) <^> p <*> r <*> pure(.none)
    }

}
