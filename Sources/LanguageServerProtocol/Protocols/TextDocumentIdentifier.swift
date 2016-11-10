//
//  TextDocumentIdentifier.swift
//  langserver-swift
//
//  Created by Ryan Lovelett on 11/22/16.
//
//

/// Text documents are identified using a URI. On the protocol level, URIs are passed as strings.
/// The corresponding JSON structure looks like this:
public protocol TextDocumentIdentifier {

    /// The text document's URI.
    var uri: String { get }

}
