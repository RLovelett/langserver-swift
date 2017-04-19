//
//  WorkspaceSymbolParams.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 4/19/17.
//
//

import Argo
import Curry
import Runes

/// The parameters of a Workspace Symbol Request.
public struct WorkspaceSymbolParams {
    /// A non-empty query string
    let query: String
}

extension WorkspaceSymbolParams : Decodable {

    public static func decode(_ json: JSON) -> Decoded<WorkspaceSymbolParams> {
        let query: Decoded<String> = json <| "query"
        return curry(WorkspaceSymbolParams.init) <^> query
    }

}
