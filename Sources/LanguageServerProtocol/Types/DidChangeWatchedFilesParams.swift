//
//  DidChangeWatchedFilesParams.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/17/16.
//
//

import Argo
import Curry
import Runes

public struct DidChangeWatchedFilesParams {

    /// The actual file events.
    let changes: [FileEvent]

}

extension DidChangeWatchedFilesParams : Decodable {

    public static func decode(_ json: JSON) -> Decoded<DidChangeWatchedFilesParams> {
        return curry(DidChangeWatchedFilesParams.init(changes:)) <^> (json <|| "changes")
    }

}
