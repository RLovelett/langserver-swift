//
//  FileEvent.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/17/16.
//
//

import Argo
import Curry
import Foundation
import Runes

/// An event describing a file change.
struct FileEvent {

    /// The file's URI
    let uri: URL

    /// The change type.
    let type: FileChangeType

}

extension FileEvent : Decodable {

    static func decode(_ json: JSON) -> Decoded<FileEvent> {
        return curry(FileEvent.init)
            <^> json <| "uri"
            <*> json <| "type"
    }

}
