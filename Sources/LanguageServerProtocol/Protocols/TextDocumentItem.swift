//
//  TextDocumentItem.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 12/4/16.
//
//

import Foundation

/// An item to transfer a text document from the client to the server.
protocol TextDocumentItem : TextDocumentIdentifier {

    /// The text document's URI.
    var uri: URL { get }

    /// The text document's language identifier.
    var languageId: String { get }

    /// The version number of this document (it will strictly increase after each
    /// change, including undo/redo).
    var version: Int { get }

    /// The content of the opened text document.
    var text: String { get }

}
