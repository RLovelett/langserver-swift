//
//  WorkspaceLocation.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/23/16.
//
//

import Foundation

struct WorkspaceLocation : Location {

    public let uri: String

    public let range: TextDocumentRange
    
}
