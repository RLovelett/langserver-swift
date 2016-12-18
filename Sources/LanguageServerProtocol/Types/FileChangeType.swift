//
//  FileChangeType.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/17/16.
//
//

import Argo

/// The file event type
enum FileChangeType: Int {

    /// The file got created.
    case Created = 1

    /// The file got changed.
    case Changed = 2

    /// The file got deleted.
    case Deleted = 3

}

extension FileChangeType : Decodable { }
